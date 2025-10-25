//
//  OpeningFlowView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Opening/OpeningFlowView.swift
//
//  🎯 ファイルの目的:
//      起動直後の導入儀式を統合管理する。
//      - 母国語選択（LanguagePickerView）
//      - 初回挨拶（CompanionWelcomeView）
//      - 法的同意（ConsentViewLocalized）
//      - ロゴ演出（AudioReactiveLogoView）
//      - コンパニオン初期作成（CompanionSetupView）
//      - 主画面（FloatingCompanionOverlayView）
//      選択された母国語に応じて UI 表記と音声案内を切り替える。
//

import SwiftUI
import AVFoundation

public struct OpeningFlowView: View {
    @AppStorage("selectedLanguageCode") private var storedLanguageCode: String = ""
    @State private var currentStep: OpeningStep = .language
    @State private var hasSpokenIntro: Bool = false

    public enum OpeningStep {
        case language
        case welcome
        case consent
        case logo
        case setup
        case main
    }

    public init() {}

    public var body: some View {
        let lang = LanguageOption.all.first(where: { $0.code == storedLanguageCode }) ?? LanguageOption.all.first!

        VStack {
            switch currentStep {
            case .language:
                VStack {
                    Text(localized("Select Your Language", for: lang))
                        .font(.headline)
                        .padding(.bottom, 10)

                    LanguagePickerView()
                        .onChange(of: storedLanguageCode) { oldValue, newValue in
                            if !newValue.isEmpty {
                                currentStep = .welcome
                            }
                        }
                }
                .transition(.opacity)

            case .welcome:
                CompanionWelcomeView(language: lang)
                    .onDisappear {
                        currentStep = .consent
                    }

            case .consent:
                ConsentViewLocalized(language: lang) {
                    currentStep = .logo
                }
                .transition(.opacity)

            case .logo:
                AudioReactiveLogoView(language: lang, onFinished: {
                    currentStep = .setup
                })
                .transition(.opacity)

            case .setup:
                CompanionSetupView(
                    onBack: { currentStep = .logo },
                    onComplete: { currentStep = .main }
                )
                .transition(.opacity)

            case .main:
                FloatingCompanionOverlayView()
                    .transition(AnyTransition.scale)
            }
        }
        .animation(.easeInOut, value: currentStep)
        .onAppear {
            if !hasSpokenIntro, !storedLanguageCode.isEmpty {
                speakIntro(for: lang)
                hasSpokenIntro = true
            }
        }
    }

    // MARK: - 簡易ローカライズ関数
    private func localized(_ key: String, for lang: LanguageOption) -> String {
        switch lang.code {
        case "ja":
            switch key {
            case "Select Your Language": return "母国語を選択してください"
            case "Next": return "次へ"
            default: return key
            }
        default:
            return key
        }
    }

    // MARK: - 初回音声案内
    private func speakIntro(for lang: LanguageOption) {
        let text: String
        switch lang.code {
        case "ja":
            text = "QuestMeへようこそ。これから母国語の設定と初回の儀式を始めます。"
        default:
            text = "Welcome to QuestMe. Let's begin by setting your language and starting the introduction."
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: lang.speechCode)
        utterance.rate = 0.5
        AVSpeechSynthesizer().speak(utterance)
    }
}
