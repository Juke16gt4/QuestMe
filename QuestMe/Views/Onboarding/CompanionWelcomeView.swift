//
//  CompanionWelcomeView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Onboarding/CompanionWelcomeView.swift
//
//  🎯 ファイルの目的:
//      保存された母国語で初回挨拶を表示するビュー。
//      - LanguageOption を使用。
//      - 初回のみ QuestMe常駐ボタンの操作説明を表示・音声再生。
//      - AppStorage により初回表示済みフラグを永続化。
//
//  🔗 依存:
//      - LanguageOption.swift（言語定義）
//      - LanguageManager.swift（選択言語）
//      - AVFoundation（音声再生）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月11日
//

import SwiftUI
import AVFoundation

struct CompanionWelcomeView: View {
    let language: LanguageOption
    @AppStorage("questme.hasShownLaunchButtonIntro") private var hasShownIntro: Bool = false
    @State private var hasSpokenIntro: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            Text(language.welcome)
                .font(.largeTitle)
                .padding(.top)

            Text("（\(language.name) での体験が始まります）")
                .font(.subheadline)

            if !hasShownIntro {
                Divider()

                Text("""
                画面右下にある「QuestMe」ボタンは、
                私と初めて出会う窓口となります。

                🔴 赤い状態のときは、まだ起動していません。タップすると私が起動します。

                🟢 緑の状態のときは、私が起動中です。
                - 長押しすると「終了しますか？」と確認が出ます。
                - 2回タップすると、私の拡大画面に移動できます。
                - 何もしないと、通常の会話モードに入ります。

                5分間操作がないと、自動的に終了しますので、
                必要なときはまたタップしてくださいね。
                """)
                .font(.body)
                .padding()
                .onAppear {
                    if !hasSpokenIntro {
                        speakIntro()
                        hasSpokenIntro = true
                    }
                }

                Button("次へ") {
                    hasShownIntro = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .navigationTitle("ようこそ")
    }

    // MARK: - 初回音声案内
    private func speakIntro() {
        let text = "画面右下にあるQuestMeボタンは、私と初めて出会う窓口となります。赤いときは未起動、タップで起動します。緑のときは起動中で、長押しで終了確認、2回タップで拡大画面に移動できます。放置すると通常会話モードに入り、5分で自動終了します。"
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.5
        AVSpeechSynthesizer().speak(utterance)
    }
}
