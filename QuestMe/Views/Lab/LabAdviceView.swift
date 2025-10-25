//
//  LabAdviceView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Lab/LabAdviceView.swift
//
//  🎯 目的:
//      最新の血液検査結果をもとに、AIコンパニオンがユーザーにアドバイスを行うビュー。
//      - LabResultStorageManager からロードした結果を表示
//      - 異常値は赤字＋⚠️で強調
//      - CompanionSpeechBubbleView と CompanionOverlay による音声案内を統合
//      - LabHistoryView への遷移も可能にして履歴を確認できる
//
//  🔗 連動:
//      - Models/LabResult.swift
//      - Models/LabItem.swift
//      - Managers/LabResultStorageManager.swift
//      - Views/Lab/LabHistoryView.swift
//      - Views/Companion/CompanionSpeechBubbleView.swift
//      - CompanionOverlay（音声案内）
//
//  👤 作成者: 津村 淳一
//  📅 修正版: 2025年10月24日
//

import SwiftUI

struct LabAdviceView: View {
    let results: [LabResult]
    @State private var bubbleText: String = "最新の検査結果を確認しています…"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CompanionSpeechBubbleView(text: bubbleText, emotion: .neutral)

                if let latest = results.sorted(by: { $0.date > $1.date }).first {
                    Text("🩺 最新の検査結果")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("日付: \(latest.date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.subheadline)

                        if !latest.items.isEmpty {
                            ForEach(latest.items) { item in
                                HStack {
                                    Text(item.name)
                                    Spacer()
                                    Text(item.value)
                                        .foregroundColor(item.isAbnormal == true ? .red : .primary)
                                    if item.isAbnormal == true {
                                        Text("⚠️")
                                    }
                                }
                            }
                        } else if let first = latest.items.first {
                            Text("\(first.name): \(first.value)")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                    Button("🗣 コンパニオンに説明してもらう") {
                        let message = summarize(latest)
                        CompanionOverlay.shared.speak(message, emotion: .neutral)
                        bubbleText = message
                    }
                    .buttonStyle(.borderedProminent)

                    NavigationLink("📊 検査履歴を見る", destination: LabHistoryView())
                        .buttonStyle(.bordered)
                        .padding(.top, 8)

                } else {
                    Text("検査結果がまだ登録されていません。")
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .navigationTitle("検査値アドバイス")
    }

    // MARK: - 要約生成
    func summarize(_ result: LabResult) -> String {
        let abnormal = result.items.filter { $0.isAbnormal == true }
        if abnormal.isEmpty {
            return "最新の検査結果はすべて正常範囲内でした。安心して過ごせますね。"
        } else {
            let names = abnormal.map { $0.name }.joined(separator: "・")
            return "最新の検査で異常値が見つかりました：\(names)。生活習慣や医師の指示を確認しましょう。"
        }
    }
}
