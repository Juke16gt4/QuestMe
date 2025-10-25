//
//  SpecializedKnowledgeView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Knowledge/SpecializedKnowledgeView.swift
//
//  🎯 ファイルの目的:
//      QuestMeが対応する専門分野を表形式で提示し、音声で安心感を届ける。
//      - ユーザーが「どんな分野に対応しているか」を視覚的に把握。
//      - 表示直後に音声で「話しかければ応答できる」安心感を提供。
//      - UI演出や感情同期を組み合わせ、知的挑戦と親しみを両立。
//
//  🔗 依存:
//      - SwiftUI
//      - EmotionType.swift
//      - CompanionOverlay.shared.speak() （音声発話）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import SwiftUI

struct SpecializedKnowledgeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🧠 QuestMeが対応する専門分野")
                .font(.title2)
                .bold()

            Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 12) {
                GridRow {
                    Text("医療・薬学")
                    Text("法律・制度")
                    Text("IT・技術")
                }
                GridRow {
                    Text("金融・経済")
                    Text("語学・国際")
                    Text("ビジネス・管理")
                }
                GridRow {
                    Text("自然科学")
                    Text("心理・福祉")
                    Text("歴史・哲学")
                }
                GridRow {
                    Text("芸術・音楽")
                    Text("工学・設計")
                    Text("教育・資格")
                }
            }
            .font(.body)
            .padding()

            Spacer()
        }
        .padding()
        .onAppear {
            // 表示から0.5秒後に音声アピール
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                CompanionOverlay.shared.speak(
                    "これらの分野はすべて音声でも対応できます。質問してみてください。",
                    emotion: .gentle
                )
            }
        }
    }
}
