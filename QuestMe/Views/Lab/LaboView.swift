//
//  LaboView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Lab/LaboView.swift
//
//  🎯 ファイルの目的:
//      血液検査結果の読み取り → 構造化 → 保存 → 異常判定 → 履歴表示を統合。
//      - Companion による案内と吹き出し表示を含む。
//      - 保存先: Calendar/年/月/血液検査結果/日.json
//

import SwiftUI
import VisionKit
import Vision

struct LaboView: View {
    @State private var showScanner = false
    @State private var scannedImage: UIImage? = nil
    @State private var labResults: [LabResult] = []
    @State private var bubbleText = "検査結果の読み取りを開始できます。"

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CompanionSpeechBubbleView(text: bubbleText)

                Button("📷 検査結果を読み取る") {
                    speak("検査結果の読み取りを開始します。", emotion: .neutral)
                    showScanner = true
                }
                .buttonStyle(.borderedProminent)

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
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
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
        .navigationTitle("検査結果の記録")
    }

    // MARK: - OCR解析
    func processScan(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        let request = VNRecognizeTextRequest { req, err in
            guard err == nil else { return }
            let results = req.results as? [VNRecognizedTextObservation] ?? []
            let lines = results.compactMap { $0.topCandidates(1).first?.string }

            let items = parseLabResults(from: lines)
            saveLabResultsToCalendar(items)
            labResults = loadLabResultsFromCalendar()
            speak("検査結果を保存しました。異常値がある場合は医師に相談しましょう。", emotion: .gentle)
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

    func lookupReferenceRange(for name: String) -> String? {
        switch name {
        case "AST": return "10-40"
        case "ALT": return "10-45"
        case "LDL": return "70-139"
        default: return nil
        }
    }

    func speak(_ text: String, emotion: EmotionType) {
        CompanionOverlay.shared.speak(text, emotion: emotion)
        bubbleText = text
    }
}
