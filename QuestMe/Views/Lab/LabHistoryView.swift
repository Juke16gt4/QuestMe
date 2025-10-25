//
//  LabHistoryView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Lab/LabHistoryView.swift
//
//  🎯 ファイルの目的:
//      血液検査履歴をグラフとリストで表示し、最新の検査結果を CompanionSpeechBubbleView で吹き出し表示する。
//      - LabResultStorageManager から読み込み。
//      - 異常値は赤、正常値は青で表示。
//      - CompanionOverlay による音声案内と吹き出し表示を統合。

import SwiftUI
import Charts

struct LabHistoryView: View {
    @State private var results: [LabResult] = []
    @State private var selectedItemName: String = "AST"
    @State private var bubbleText: String = "最新の検査結果を読み込んでいます…"

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CompanionSpeechBubbleView(text: bubbleText)

                Picker("項目", selection: $selectedItemName) {
                    ForEach(uniqueItemNames(), id: \.self) { name in
                        Text(name)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Button("🗣 検査値の変化を説明") {
                    speakTrend(for: selectedItemName)
                }
                .buttonStyle(.borderedProminent)

                Chart {
                    ForEach(filteredData(), id: \.id) { point in
                        LineMark(
                            x: .value("日付", point.date),
                            y: .value("値", point.value)
                        )
                        .foregroundStyle(point.isAbnormal ? .red : .blue)
                        .symbol(point.isAbnormal ? .triangle : .circle)
                    }
                }
                .frame(height: 240)
                .padding(.horizontal)

                ForEach(results) { result in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.date, style: .date)
                            .font(.headline)
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
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .onAppear {
            results = LabResultStorageManager.shared.loadAll()
            bubbleText = summarizeLatestLabResult()
        }
        .navigationTitle("血液検査履歴")
    }

    // MARK: - グラフ用データ抽出
    func filteredData() -> [ChartPoint] {
        results.flatMap { result in
            result.items.filter { $0.name == selectedItemName }.map {
                ChartPoint(date: result.date, value: Double($0.value) ?? 0, isAbnormal: $0.isAbnormal ?? false, id: UUID())
            }
        }
    }

    func uniqueItemNames() -> [String] {
        Set(results.flatMap { $0.items.map { $0.name } }).sorted()
    }

    struct ChartPoint: Identifiable {
        var date: Date
        var value: Double
        var isAbnormal: Bool
        var id: UUID
    }

    // MARK: - Companion による語りかけ
    func speakTrend(for name: String) {
        let points = filteredData().sorted { $0.date > $1.date }
        guard points.count >= 2 else {
            CompanionOverlay.shared.speak("検査履歴が少ないため、変化を説明できません。")
            return
        }

        let latest = points[0]
        let previous = points[1]
        let delta = latest.value - previous.value
        let direction = delta > 0 ? "上昇" : "低下"
        let status = latest.isAbnormal ? "⚠️ 異常値です。" : "正常範囲内です。"

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateStr = formatter.string(from: latest.date)

        let message = "\(name) の値は前回より \(abs(delta), specifier: "%.1f") ほど \(direction) しました。現在の値は \(latest.value, specifier: "%.1f")（\(dateStr)）。\(status)"
        CompanionOverlay.shared.speak(message)
        bubbleText = message
    }

    // MARK: - 最新検査結果の要約生成
    func summarizeLatestLabResult() -> String {
        guard let latest = results.first else {
            return "検査履歴が見つかりませんでした。"
        }

        let abnormalItems = latest.items.filter { $0.isAbnormal == true }
        let normalCount = latest.items.count - abnormalItems.count
        let dateStr = DateFormatter.localizedString(from: latest.date, dateStyle: .medium, timeStyle: .none)

        if abnormalItems.isEmpty {
            return "🩺 \(dateStr) の検査結果はすべて正常でした。安心して過ごせますね。"
        } else {
            let names = abnormalItems.map { $0.name }.joined(separator: "・")
            return "⚠️ \(dateStr) の検査で異常値が見つかりました：\(names)。医師の指示に従いましょう。"
        }
    }
}
