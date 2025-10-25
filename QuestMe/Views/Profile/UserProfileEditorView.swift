//
//  UserProfileEditorView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Profile/UserProfileEditorView.swift
//
//  🎯 ファイルの目的:
//      ユーザーのプロフィール編集に加え、血液検査結果のOCR読み取り → 構造化 → 保存 → 異常判定 → 履歴表示まで統合。
//      - Companion が案内し、DocumentCameraView で撮影 → VNRecognizeTextRequest で解析。
//      - LabItem に構造化し、LabResult として Calendar に保存。
//      - LabHistoryView で履歴を表示可能。
//      - scannedImage は UI状態として管理。
//
//  👤 製作者: 津村 淳一
//  📅 最終更新: 2025年10月9日

import SwiftUI
import VisionKit
import Vision

struct UserProfileEditorView: View {
    @State var profile: UserProfile
    @State private var showScanner = false
    @State private var scannedImage: UIImage? = nil
    @State private var labResults: [LabResult] = []

    var body: some View {
        Form {
            // 既存のプロフィール編集セクション（省略）

            // MARK: - 血液検査読み取り
            Section(header: Text("血液検査")) {
                Button("検査結果を読み取る") {
                    showScanner = true
                }

                if !labResults.isEmpty {
                    ForEach(labResults) { result in
                        VStack(alignment: .leading) {
                            Text(result.date, style: .date).bold()
                            ForEach(result.items) { item in
                                HStack {
                                    Text(item.name)
                                    Spacer()
                                    Text(item.value)
                                    if item.isAbnormal == true {
                                        Text("⚠️").foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // MARK: - 保存
            Section {
                Button("保存") {
                    var updated = profile
                    updated.lastUpdated = Date()
                    UserProfileStorage.shared.save(updated)
                    print("✅ プロファイル保存: \(updated)")
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            DocumentCameraView { image in
                scannedImage = image
                processScan(image)
                scannedImage = nil
            }
        }
        .onAppear {
            labResults = loadLabResultsFromCalendar()
        }
        .navigationTitle("ユーザープロファイル修正")
    }

    // MARK: - OCR解析 → LabItem構造化
    func processScan(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        let request = VNRecognizeTextRequest { req, err in
            guard err == nil else { return }
            let results = req.results as? [VNRecognizedTextObservation] ?? []
            let lines = results.compactMap { $0.topCandidates(1).first?.string }

            let items = parseLabResults(from: lines)
            saveLabResultsToCalendar(items)
            labResults = loadLabResultsFromCalendar()
        }

        request.recognitionLevel = .accurate
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }

    // MARK: - テキスト → LabItem構造化
    func parseLabResults(from lines: [String]) -> [LabItem] {
        var items: [LabItem] = []
        for line in lines {
            let parts = line.components(separatedBy: ":")
            if parts.count == 2 {
                let name = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1].trimmingCharacters(in: .whitespaces)
                var item = LabItem(name: name, value: value)
                item.referenceRange = lookupReferenceRange(for: name)
                item.evaluateAbnormality()
                items.append(item)
            }
        }
        return items
    }

    // MARK: - 保存
    func saveLabResultsToCalendar(_ items: [LabItem]) {
        let result = LabResult(date: Date(), items: items, notes: "AIによる解析結果：検査値を確認してください。")
        let payload = result.toDictionary()

        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let root = docs.appendingPathComponent("Calendar")
        let year = Calendar.current.component(.year, from: result.date)
        let month = Calendar.current.component(.month, from: result.date)
        let dateStr = DateFormatter.localizedString(from: result.date, dateStyle: .short, timeStyle: .none).replacingOccurrences(of: "/", with: "-")
        let folder = root.appendingPathComponent("\(year)年/\(month)月/血液検査結果")

        try? fm.createDirectory(at: folder, withIntermediateDirectories: true)
        let fileURL = folder.appendingPathComponent("\(dateStr).json")

        if let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted]) {
            try? data.write(to: fileURL)
        }
    }

    // MARK: - 読み込み
    func loadLabResultsFromCalendar() -> [LabResult] {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let root = docs.appendingPathComponent("Calendar")
        var results: [LabResult] = []

        if let enumerator = fm.enumerator(at: root, includingPropertiesForKeys: nil) {
            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension == "json",
                   let data = try? Data(contentsOf: fileURL),
                   let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let values = dict["values"] as? [[String: Any]] {
                    let items = values.compactMap { v in
                        LabItem(
                            name: v["name"] as? String ?? "",
                            value: v["value"] as? String ?? "",
                            unit: v["unit"] as? String,
                            referenceRange: v["range"] as? String,
                            isAbnormal: v["abnormal"] as? Bool
                        )
                    }
                    let date = Date() // 本来は dict["date"] を Date に変換
                    let notes = dict["notes"] as? String ?? ""
                    results.append(LabResult(date: date, items: items, notes: notes))
                }
            }
        }

        return results.sorted { $0.date > $1.date }
    }

    // MARK: - 参照範囲の仮定義
    func lookupReferenceRange(for name: String) -> String? {
        switch name {
        case "AST": return "10-40"
        case "ALT": return "10-45"
        case "LDL": return "70-139"
        default: return nil
        }
    }
}
