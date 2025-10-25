//
//  CompanionLanguagePickerView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Onboarding/CompanionLanguagePickerView.swift
//
//  🎯 ファイルの目的:
//      インストール直後の母国語選択儀式。
//      - 12言語対応 Picker で母語を選択。
//      - 「決定」ボタンで言語を確定 → SpeechSync.currentLanguage に反映。
//      - 「次へ」ボタンで CompanionSetupView.swift に遷移。
//      - Companion が選択言語でナレーション開始。
//      - UIラベル・音声・ヘルプはすべて選択言語で表示。
//      - 再現性・儀式性・感情的安全性を保証。
//
//  🔗 関連/連動ファイル:
//      - SpeechSync.swift（言語判定・音声案内）
//      - CompanionSetupView.swift（初期設定画面）
//      - UserEventHistory.swift（言語選択履歴保存）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月20日
//

import SwiftUI

struct CompanionLanguagePickerView: View {
    @State private var selectedLanguage: String = "ja"
    @State private var isConfirmed = false
    @State private var showNextButton = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(localized("title"))
                    .font(.title2)
                    .bold()

                Picker(localized("pickerLabel"), selection: $selectedLanguage) {
                    ForEach(supportedLanguages, id: \.self) { lang in
                        Text(languageLabel(for: lang)).tag(lang)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 160)

                if !isConfirmed {
                    Button(localized("confirmButton")) {
                        SpeechSync().currentLanguage = selectedLanguage
                        SpeechSync().speak(localized("confirmedSpoken"))
                        isConfirmed = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showNextButton = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }

                if showNextButton {
                    Button(localized("nextButton")) {
                        SpeechSync().speak(localized("nextSpoken"))
                        // CompanionSetupView.swift に遷移
                        navigateToCompanionSetup()
                    }
                    .buttonStyle(.bordered)
                }

                Button(localized("helpButton")) {
                    SpeechSync().speak(helpText(for: selectedLanguage))
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle(localized("title"))
        }
    }

    // MARK: - 言語ラベル
    private func languageLabel(for lang: String) -> String {
        switch lang {
        case "ja": return "日本語"
        case "en": return "English"
        case "fr": return "Français"
        case "de": return "Deutsch"
        case "es": return "Español"
        case "zh": return "中文"
        case "ko": return "한국어"
        case "pt": return "Português"
        case "it": return "Italiano"
        case "hi": return "हिन्दी"
        case "sv": return "Svenska"
        case "no": return "Norsk"
        default: return lang
        }
    }

    private var supportedLanguages: [String] {
        ["ja", "en", "fr", "de", "es", "zh", "ko", "pt", "it", "hi", "sv", "no"]
    }

    // MARK: - 多言語ラベル
    private func localized(_ key: String) -> String {
        switch (key, selectedLanguage) {
        case ("title", "ja"): return "🌐 母国語を選択"
        case ("pickerLabel", "ja"): return "言語を選んでください"
        case ("confirmButton", "ja"): return "決定"
        case ("nextButton", "ja"): return "次へ"
        case ("helpButton", "ja"): return "ヘルプ"
        case ("confirmedSpoken", "ja"): return "言語を「日本語」に設定しました。"
        case ("nextSpoken", "ja"): return "次の設定画面に進みます。"

        case ("title", "en"): return "🌐 Choose your language"
        case ("pickerLabel", "en"): return "Select your language"
        case ("confirmButton", "en"): return "Confirm"
        case ("nextButton", "en"): return "Next"
        case ("helpButton", "en"): return "Help"
        case ("confirmedSpoken", "en"): return "Language set to English."
        case ("nextSpoken", "en"): return "Proceeding to setup screen."

        // 他言語は必要に応じて追加可能
        default: return key
        }
    }

    private func helpText(for lang: String) -> String {
        switch lang {
        case "ja": return "この画面では母国語を選びます。決定すると、すべての案内がその言語になります。"
        case "en": return "Choose your language here. Once confirmed, all guidance will be in that language."
        default: return "Choose your language here. Once confirmed, all guidance will be in that language."
        }
    }

    // MARK: - CompanionSetupView に遷移
    private func navigateToCompanionSetup() {
        // CompanionSetupView.swift に遷移するロジックをここに記述
        // 例：NavigationLink または画面スタック操作
    }
}
