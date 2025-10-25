//
//  CrossReviewView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Review/CrossReviewView.swift
//
//  🎯 ファイルの目的:
//      - 検査データと感情ログを並列表示し、相関コメントを提示する。
//      - CompanionOverlay による音声案内と表情演出を統合。
//      - ユーザーが「体調と気分の関係」を振り返るための画面。
//
//  🧑‍💻 作成者: 津村 淳一 (Junichi Tsumura)
//  🗓️ 製作日時: 2025-10-10 JST
//
//  🔗 依存:
//      - Models/LabResult.swift（testName, value, date）
//      - Models/EmotionLog.swift（emotion, date）
//      - Managers/LabResultStorageManager.swift（loadAll → filter）
//      - Managers/EmotionLogStorageManager.swift（loadAll → filter）
//      - UI/CompanionOverlay.swift（相関コメント生成）
//

import SwiftUI

struct CrossReviewView: View {
    let dateString: String

    @State private var labs: [LabResult] = []
    @State private var emotions: [EmotionLog] = []

    var body: some View {
        VStack(spacing: 16) {
            Text("🧪 検査データ")
                .font(.headline)

            ForEach(labs, id: \.id) { lab in
                HStack {
                    Text("\(lab.testName): \(lab.value)")
                    Spacer()
                    Text(lab.date.formatted())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            Text("🧠 感情ログ")
                .font(.headline)

            ForEach(emotions, id: \.id) { log in
                HStack {
                    Text(log.emotion.rawValue)
                    Spacer()
                    Text(log.date.formatted())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            Button("コンパニオンの相関コメントを聞く") {
                CompanionOverlay.shared.speakCorrelation(labs: labs, emotions: emotions)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Cross Review")
        .onAppear {
            labs = LabResultStorageManager.shared.loadAll().filter {
                ISO8601DateFormatter().string(from: $0.date).hasPrefix(dateString)
            }
            emotions = EmotionLogStorageManager.shared.loadAll().filter {
                ISO8601DateFormatter().string(from: $0.date).hasPrefix(dateString)
            }
        }
    }
}
