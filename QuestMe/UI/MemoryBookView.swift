//
//  MemoryBookView.swift
//  QuestMe
//
//  作成者: 津村 淳一 (Junichi Tsumura)
//  作成日: 2025年10月6日
//
//  📂 格納場所:
//      QuestMe/Companion/Memory/MemoryBookView.swift
//
//  🎯 ファイルの目的:
//      Companion がユーザーの地域体験履歴（UserEventHistory）を物語として語るビュー。
//      - 吹き出し＋音声＋表情で語りかける。
//      - 感想がある場合は「思い出」として強調。
//      - 表情は感情ラベルに応じて変化。
//      - 季節や時間帯に応じて語り口を変化。
//      - タグ分類とお気に入り登録に対応。
//      - ユーザーが「記憶の書」を開くことで、自分の旅路を振り返ることができる。

import SwiftUI

struct MemoryBookView: View {
    @State private var histories: [UserEventHistory] = UserEventStorage.shared.loadAll()
    @State private var currentIndex: Int = 0
    @State private var currentEmotion: CompanionExpression = .neutral

    var body: some View {
        VStack(spacing: 24) {
            Text("📖 記憶の書")
                .font(.largeTitle)
                .bold()

            if histories.isEmpty {
                Text("まだ記憶がありません。地域体験を重ねていきましょう。")
                    .foregroundColor(.secondary)
            } else {
                let history = histories[currentIndex]

                FloatingCompanionView(expression: currentEmotion)

                CompanionSpeechBubbleView(message: generateNarration(for: history))

                Text("訪問日: \(history.visitedAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !history.tags.isEmpty {
                    Text("タグ: \(history.tags.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Button(history.isFavorite ? "★ お気に入り解除" : "☆ お気に入りに追加") {
                    histories[currentIndex].isFavorite.toggle()
                    UserEventStorage.shared.save(histories[currentIndex])
                }
                .buttonStyle(.bordered)

                if histories.count > 1 {
                    HStack {
                        Button("← 前へ") {
                            currentIndex = max(0, currentIndex - 1)
                        }
                        .disabled(currentIndex == 0)

                        Button("次へ →") {
                            currentIndex = min(histories.count - 1, currentIndex + 1)
                        }
                        .disabled(currentIndex == histories.count - 1)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            updateEmotion()
        }
        .onChange(of: currentIndex) { _ in
            updateEmotion()
        }
    }

    // MARK: - 語り生成
    private func generateNarration(for history: UserEventHistory) -> String {
        let seasonal = seasonalGreeting(for: history.visitedAt)
        let base = "『\(history.title)』に訪れた記憶があります。"

        if let notes = history.notes, !notes.isEmpty {
            return "\(seasonal) \(base) あなたはこう語っていました──「\(notes)」。素敵な思い出ですね。"
        } else if history.isFavorite {
            return "\(seasonal) \(base) お気に入りの記憶として保存されています。また語りましょう。"
        } else {
            return "\(seasonal) \(base) どんな体験だったか、また教えてくださいね。"
        }
    }

    // MARK: - 季節語り口
    private func seasonalGreeting(for date: Date) -> String {
        let month = Calendar.current.component(.month, from: date)
        switch month {
        case 3...5: return "春の風が吹いていた頃──"
        case 6...8: return "夏の陽射しの中で──"
        case 9...11: return "秋の空気に包まれて──"
        default: return "冬の静けさの中で──"
        }
    }

    // MARK: - 感情 → 表情変換
    private func updateEmotion() {
        let history = histories[currentIndex]
        if let notes = history.notes {
            if notes.contains("楽しかった") || notes.contains("癒された") || notes.contains("嬉しかった") {
                currentEmotion = .happy
            } else if notes.contains("不安") || notes.contains("疲れた") {
                currentEmotion = .sad
            } else {
                currentEmotion = .neutral
            }
        } else {
            currentEmotion = .neutral
        }
    }
}
