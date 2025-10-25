//
//  ExpertiseDomainsView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/ExpertiseDomainsView.swift
//
//  🎯 ファイルの目的:
//      QuestMeが対応する専門分野を表形式で提示し、音声で安心感を届ける。
//      - ユーザーが「どんな分野に話しかけられるか」を視覚と聴覚で理解。
//      - 感情同期と知的信頼を両立。
//      依存消失（CompanionOverlay / SpeechService）に伴い、発話機能をローカルに内蔵。
//
//  🔗 依存:
//      - SwiftUI
//      - EmotionType.swift（感情定義）
//
//  👤 製作者: 津村 淳一
//  📅 改名日: 2025年10月14日
//

import SwiftUI
import AVFoundation

struct ExpertiseDomainsView: View {
    // 必要に応じて吹き出しを出す場合の状態（今回は画面内発話のみ）
    @State private var showSpeechBubble = false
    @State private var currentEmotion: EmotionType = .gentle
    @State private var currentSpeechText: String = ""

    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack(spacing: 20) {
            if showSpeechBubble {
                CompanionSpeechBubbleView(text: currentSpeechText, emotion: currentEmotion)
                    .padding(.horizontal, 16)
            }

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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                speak("これらの分野はすべて音声でも対応できますよ。質問してみてください。", emotion: .gentle)
            }
        }
    }

    private func speak(_ text: String, emotion: EmotionType) {
        // 感情と吹き出し（必要なら表示）
        currentEmotion = emotion
        currentSpeechText = text
        showSpeechBubble = true

        // 音声合成（ja-JP）
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.5
        synthesizer.speak(utterance)

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            showSpeechBubble = false
        }
    }
}
