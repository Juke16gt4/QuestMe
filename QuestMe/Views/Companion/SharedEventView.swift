//
//  SharedEventView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Calendar/SharedEventView.swift
//
//  🎯 ファイルの目的:
//      ユーザーがその日のイベントをQRコードやURLで共有できるビュー。
//      - 家族・医師・介護者との共有を想定。
//      - EventItem を JSON化 → QR表示 or URL生成。
//      - ScheduleAndEventDialogView.swift から起動。
//
//  🔗 依存:
//      - EventItem.swift
//      - QRCodeGenerator.swift（別途）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月9日

import SwiftUI

struct SharedEventView: View {
    let date: Date
    @State private var sharedText: String = ""
    @State private var showQR = false

    var body: some View {
        VStack(spacing: 24) {
            Text("🤝 イベント共有")
                .font(.title2)
                .bold()

            Text("以下のイベントを共有できます")
                .font(.body)

            Text(sharedText)
                .font(.caption)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            Button("QRコード表示") {
                showQR = true
            }

            Spacer()
        }
        .padding()
        .onAppear {
            loadEvents()
        }
        .sheet(isPresented: $showQR) {
            QRCodeView(content: sharedText)
        }
    }

    func loadEvents() {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dateStr = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none).replacingOccurrences(of: "/", with: "-")
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let root = docs.appendingPathComponent("Calendar/\(year)年/\(month)月")

        var allEvents: [EventItem] = []

        do {
            let folders = try fm.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)
            for folder in folders where folder.hasDirectoryPath {
                let file = folder.appendingPathComponent("\(dateStr).json")
                if let data = try? Data(contentsOf: file),
                   let item = try? JSONDecoder().decode(EventItem.self, from: data) {
                    allEvents.append(item)
                }
            }
        } catch {
            sharedText = "イベント読み込み失敗"
            return
        }

        if let data = try? JSONEncoder().encode(allEvents),
           let json = String(data: data, encoding: .utf8) {
            sharedText = json
        }
    }
}
