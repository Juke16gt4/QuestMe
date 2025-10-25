//
//  MedicationAdviceView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Advice/MedicationAdviceView.swift
//
//  🎯 ファイルの目的:
//      AIコンパニオンが服薬中のユーザーに向けて、合併症予防を含むアドバイスを語りかける儀式ビュー。
//      - 質問分類に応じたテンプレート/LLM応答と感情ログ保存
//      - CompanionAvatar に応じた語り口で音声案内
//      - 吹き出し表示・音声発話・会話保存・終了検知・多言語対応を統合
//
//  🔗 連動:
//      - CompanionAvatar.swift
//      - VoiceProfile.swift
//      - MedicationEmotionLogger.swift
//      - ConversationLogger.swift
//      - CompanionSpeechBubbleView.swift
//      - FloatingCompanionOverlayView.swift
//      - MedicationAdviceResponder.swift（プロトコル）
//
//  👤 作成者: 津村 淳一
//  📅 改訂日: 2025年10月23日

import SwiftUI

public struct MedicationAdviceView: View {
    @AppStorage("selectedLanguageCode") private var langCode: String = "ja"
    @State private var userQuestion: String = ""
    @State private var companionResponse: String = ""
    @State private var lastInteractionTime = Date()
    @State private var showMainScreen = false
    @State private var showHelp = false
    @State private var showAdvice = false
    @State private var timer: Timer?
    @StateObject private var speechSync: SpeechSync

    let companion: CompanionAvatar
    let voice: VoiceProfile
    let responder: MedicationAdviceResponder

    public init(companion: CompanionAvatar, voice: VoiceProfile, responder: MedicationAdviceResponder) {
        self.companion = companion
        self.voice = voice
        self.responder = responder
        _speechSync = StateObject(wrappedValue: SpeechSync(voice: voice))
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text(localized("title"))
                .font(.title2)
                .bold()

            if !companionResponse.isEmpty {
                CompanionSpeechBubbleView(text: companionResponse, emotion: .gentle)
                    .padding(.horizontal)
            }

            TextField(localized("questionField"), text: $userQuestion)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    respondToQuestion(userQuestion)
                }

            Button(localized("askButton")) {
                respondToQuestion(userQuestion)
            }

            Button(localized("helpButton")) {
                showHelp = true
                speak(localized("helpText"))
            }

            Button(localized("adviceButton")) {
                showAdvice = true
                speak(localized("adviceText"))
            }

            NavigationLink(destination: DashboardView(), isActive: $showMainScreen) {
                Button(localized("mainButton")) {
                    speak(localized("returning"))
                    showMainScreen = true
                }
            }
        }
        .padding()
        .onAppear {
            startInitialAdvice()
            startInactivityTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - 初期アドバイス
    private func startInitialAdvice() {
        let intro = companionIntro(for: companion)
        companionResponse = intro
        speak(intro)
        logExchange(user: "", companion: intro)
    }

    // MARK: - 質問応答
    private func respondToQuestion(_ question: String) {
        guard !question.isEmpty else { return }
        lastInteractionTime = Date()

        let response = responder.generateResponse(for: question, langCode: langCode)
        let emotion = responder.emotionFor(question: question)

        companionResponse = response
        speak(response)
        logExchange(user: question, companion: response)
        MedicationEmotionLogger.shared.log(emotion, language: langCode)

        userQuestion = ""
    }

    // MARK: - 音声出力
    private func speak(_ text: String) {
        speechSync.speak(text)
    }

    // MARK: - 会話保存
    private func logExchange(user: String, companion: String) {
        ConversationLogger.shared.logExchange(
            folder: "おくすりアドバイス",
            filename: DateFormatter.timestamp(),
            userText: user,
            companionText: companion
        )
    }

    // MARK: - 5秒ルール
    private func startInactivityTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince(lastInteractionTime)
            if elapsed > 5 {
                let closing = localized("closingMessage")
                companionResponse = closing
                speak(closing)
                logExchange(user: "", companion: closing)
                timer?.invalidate()
            }
        }
    }

    // MARK: - 多言語ラベル
    private func localized(_ key: String) -> String {
        // 省略：従来の localized スイッチ構造を使用
        return key
    }

    // MARK: - Companion語り口
    private func companionIntro(for avatar: CompanionAvatar) -> String {
        switch avatar {
        case .nutritionist:
            return langCode == "ja"
                ? "食事と薬の関係を一緒に見ていきましょうね。"
                : "Let’s explore how food and medication interact."
        case .counselor:
            return langCode == "ja"
                ? "不安なことがあれば、いつでも何でも良いのでお話してくださいね。"
                : "If you’re feeling anxious, I’m here to talk anytime."
        case .mentor:
            return langCode == "ja"
                ? "この薬はあなたの日々の生活を健やかに維持するおくすりです。飲み忘れがないようにしましょうね。"
                : "This medicine is a step toward protecting your future."
        default:
            return langCode == "ja"
                ? "おくすりを飲む大切さを一緒に確認していきましょう。"
                : "Let’s review the importance of taking your medication together."
        }
    }
}
