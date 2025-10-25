//
//  EmotionLogViewer.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Emotion/EmotionLogViewer.swift
//
//  🎯 目的:
//      カレンダーホルダー「おでかけ」に保存されたログを読み込み、感想と写真を分離表示。
//      - text.comment → 感想
//      - image.base64 → 写真
//
//  🔗 関連:
//      - EmotionLogFileWriter.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import SwiftUI

struct EmotionLogViewer: View {
    @State private var logs: [EmotionLogFile] = []

    var body: some View {
        NavigationView {
            List(logs) { log in
                VStack(alignment: .leading, spacing: 8) {
                    Text(log.placeName)
                        .font(.headline)

                    Text("日時: \(formattedDate(log.timestamp))")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("座標: \(log.latitude), \(log.longitude)")
                        .font(.caption2)

                    if let comment = log.comment {
                        Text("感想: \(comment)")
                            .font(.body)
                    }

                    if let image = log.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(8)
                    }
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("おでかけログ")
        }
        .onAppear {
            logs = loadLogs()
        }
    }

    // MARK: - ログ読み込み
    private func loadLogs() -> [EmotionLogFile] {
        let folderURL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Calendars/おでかけ", isDirectory: true)

        guard let files = try? FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
        else { return [] }

        return files.compactMap { url in
            guard url.pathExtension == "json",
                  let data = try? Data(contentsOf: url),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let timestampStr = json["timestamp"] as? String,
                  let placeName = json["placeName"] as? String,
                  let lat = json["latitude"] as? Double,
                  let lng = json["longitude"] as? Double
            else { return nil }

            let timestamp = ISO8601DateFormatter().date(from: timestampStr) ?? Date()
            let comment = (json["text"] as? [String: Any])?["comment"] as? String

            var image: UIImage? = nil
            if let base64 = (json["image"] as? [String: Any])?["base64"] as? String,
               let data = Data(base64Encoded: base64.replacingOccurrences(of: "data:image/jpeg;base64,", with: "")),
               let uiImage = UIImage(data: data) {
                image = uiImage
            }

            return EmotionLogFile(id: url.lastPathComponent,
                                  timestamp: timestamp,
                                  placeName: placeName,
                                  latitude: lat,
                                  longitude: lng,
                                  comment: comment,
                                  image: image)
        }
        .sorted { $0.timestamp > $1.timestamp }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - ログ構造
struct EmotionLogFile: Identifiable {
    let id: String
    let timestamp: Date
    let placeName: String
    let latitude: Double
    let longitude: Double
    let comment: String?
    let image: UIImage?
}
