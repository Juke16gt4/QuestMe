//
//  MannersExplanationView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Manners/MannersExplanationView.swift
//
//  🎯 ファイルの目的:
//      GPS/WiFiで取得した訪問先のマナー情報を、母国と比較しながらAIコンパニオンが音声と文字で解説する。
//      吹き出しUIで感情同期し、単語ごとに1.4倍表示→標準サイズへ戻すアニメーションを行う。
//      解説後に「ご質問はありますか？」と問いかけ、対話を開始。
//      5秒間無応答なら「会話を終了します。ご理解いただけましたか？」と確認。
//      「理解した」なら感謝メッセージを表示・音声再生し、儀式を終了。
//      「理解できない」ならマナー解説を繰り返す。
//      マナー情報は Calendar/VisitDestination フォルダーに日時＋地域名で保存。
//      最終的に FloatingCompanionOverlayView に戻る。
//
//  🔗 依存:
//      - EmotionType.swift
//      - CompanionSpeechBubbleView.swift
//      - MannersAPIManager.swift
//      - MannersFileSaver.swift
//      - AVFoundation
//      - AppStorage
//
//  👤 製作者: 津村 淳一
//  📅 改変日: 2025年10月13日
//

import SwiftUI
import AVFoundation

struct MannersExplanationView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasShownMannersIntro") private var hasShownMannersIntro = false
    @State private var currentEmotion: EmotionType = .gentle
    @State private var currentSpeechText: String = ""
    @State private var fontScale: CGFloat = 1.4
    @State private var showUnderstandingButtons = false
    @State private var showThankYouMessage = false
    @State private var userResponded = false
    @State private var isRepeating = false
    @State private var timer: Timer?

    var regionManners: RegionManners

    var body: some View {
        VStack(spacing: 16) {
            CompanionSpeechBubbleView(text: currentSpeechText, emotion: currentEmotion)
                .font(.system(size: 16 * fontScale))
                .animation(.easeOut(duration: 0.3), value: fontScale)
                .padding()

            if showUnderstandingButtons {
                HStack {
                    Button("理解した") {
                        userResponded = true
                        MannersAPIManager.shared.markMannerAsUnderstood(regionManners.region)
                        speakFinalMessage()
                        MannersFileSaver.shared.save(manners: regionManners)
                    }
                    Button("理解できない") {
                        userResponded = true
                        isRepeating = true
                        showUnderstandingButtons = false
                        explainAllManners()
                    }
                }
            }

            if showThankYouMessage {
                Text("ご理解とご配慮に感謝いたします。ご滞在をゆっくりお楽しみください。")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .transition(.opacity)
            }

            Spacer()
        }
        .onAppear {
            if !hasShownMannersIntro || isRepeating {
                explainAllManners()
                hasShownMannersIntro = true
                startInactivityTimer()
            }
        }
    }

    // MARK: - マナー解説（全項目）
    func explainAllManners() {
        var delay: Double = 0.0
        for (_, item) in regionManners.manners {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                speakWithSync(item.summary, emotion: EmotionType(rawValue: item.emotion) ?? .neutral)
            }
            delay += 4.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 1.0) {
            askForQuestions()
        }
    }

    // MARK: - 音声＋文字起こし（1語ずつアニメーション）
    func speakWithSync(_ text: String, emotion: EmotionType) {
        currentEmotion = emotion
        currentSpeechText = ""
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: regionManners.language)
        utterance.rate = 0.5
        AVSpeechSynthesizer().speak(utterance)

        let words = text.split(separator: " ")
        var delay: Double = 0.0
        for word in words {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                animateWord(String(word))
            }
            delay += 0.4
        }
    }

    func animateWord(_ word: String) {
        fontScale = 1.4
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.3)) {
                fontScale = 1.0
            }
            currentSpeechText += word + " "
        }
    }

    // MARK: - 質問誘導
    func askForQuestions() {
        speak("ご質問はありますか？", emotion: .gentle)
        startInactivityTimer()
    }

    // MARK: - 無応答検知
    func startInactivityTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            if !userResponded {
                speak("会話を終了します。ご理解いただけましたか？", emotion: .gentle)
                showUnderstandingButtons = true
            }
        }
    }

    // MARK: - 感謝メッセージ＋儀式終了
    func speakFinalMessage() {
        speak("ご理解とご配慮に感謝いたします。ご滞在をゆっくりお楽しんで、ぜひこの国やこの町の魅力を存分に味わってください。", emotion: .happy)
        showThankYouMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            dismiss()
        }
    }

    // MARK: - 発話処理（吹き出し連動）
    func speak(_ text: String, emotion: EmotionType) {
        currentEmotion = emotion
        currentSpeechText = text
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: regionManners.language)
        utterance.rate = 0.5
        AVSpeechSynthesizer().speak(utterance)
    }
}
