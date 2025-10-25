//
//  ConsentViewLocalized.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Onboarding/ConsentViewLocalized.swift
//
//  🎯 ファイルの目的:
//      利用規約・プライバシーポリシーへの同意を取得する画面。
//      - 選択された母国語に応じて UI 表記と音声案内を切り替える。
//      - 同意後はクロージャで次のステップへ進む。
//

import SwiftUI
import AVFoundation

struct ConsentViewLocalized: View {
    let language: LanguageOption
    var onConsentAccepted: () -> Void

    @State private var hasSpokenIntro: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            Text(localized("Terms and Privacy Policy", for: language))
                .font(.title2)
                .bold()

            ScrollView {
                Text(localized("Here will be shown the summary or link to full Terms and Privacy Policy.", for: language))
                    .padding()
            }
            .frame(height: 200)

            Button(action: {
                UserDefaults.standard.set(true, forKey: "UserAgreedToTerms")
                onConsentAccepted()
            }) {
                Text(localized("Agree", for: language))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
        .onAppear {
            if !hasSpokenIntro {
                speakIntro(for: language)
                hasSpokenIntro = true
            }
        }
    }

    // MARK: - ローカライズ
    private func localized(_ key: String, for lang: LanguageOption) -> String {
        switch lang.code {
        case "ja":
            switch key {
            case "Terms and Privacy Policy": return "利用規約とプライバシーポリシー"
            case "Here will be shown the summary or link to full Terms and Privacy Policy.": return "ここに利用規約やプライバシーポリシーの要約、または全文へのリンクを表示します。"
            case "Agree": return "同意する"
            default: return key
            }
        default:
            return key
        }
    }

    // MARK: - 音声案内
    private func speakIntro(for lang: LanguageOption) {
        let text: String
        switch lang.code {
        case "ja":
            text = "ここでは利用規約とプライバシーポリシーへの同意をお願いします。"
        default:
            text = "Here you need to agree to the Terms of Service and Privacy Policy."
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: lang.speechCode)
        utterance.rate = 0.5
        AVSpeechSynthesizer().speak(utterance)
    }
}
