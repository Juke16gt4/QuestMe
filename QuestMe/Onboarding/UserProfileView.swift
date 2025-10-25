//
//  UserProfileView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Onboarding/UserProfileView.swift
//
//  🎯 目的:
//      - ユーザーのプロフィールを音声ガイド付きで登録する儀式ビュー
//      - 名前入力は音声＋手入力ハイブリッド
//      - ヘルプ・戻る・メイン画面・決定ボタンを追加し、完全音声対応
//      - 身長・体重変更時に再設定案内
//      - BMI値と判定をテキスト表示
//      - 「次へ」ボタンで FloatingCompanionOverlayView.swift に遷移
//
//  🔗 関連ファイル:
//      - CompanionSetupView.swift（戻る先）
//      - FloatingCompanionOverlayView.swift（メイン画面）
//      - SpeechRecognizer.swift（音声入力）
//      - VoiceGuide.swift（音声ガイド）
//      - RegionResolver.swift（郵便番号 → 地域）
//
//  👤 作成者: 津村 淳一
//  📅 最終更新: 2025年10月20日（完全音声対応版）

import SwiftUI

enum NameInputState {
    case waitingSpeech
    case confirming
    case correction
    case manualInput
    case completed
}

struct UserProfileView: View {
    @AppStorage("selectedLanguageCode") private var langCode: String = "ja"
    @Environment(\.dismiss) private var dismiss
    @State private var profile = UserProfile.empty()
    @State private var showMain = false
    @State private var nameState: NameInputState = .waitingSpeech
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Button(localized("helpButton")) {
                            VoiceGuide.speak(localized("helpText"), languageCode: langCode)
                        }
                        Spacer()
                        Button(localized("backButton")) {
                            VoiceGuide.speak(localized("backText"), languageCode: langCode)
                            dismiss()
                        }
                        Button(localized("mainButton")) {
                            VoiceGuide.speak(localized("mainText"), languageCode: langCode)
                            showMain = true
                        }
                    }
                }
                
                Section(header: Text(localized("personalInfo"))) {
                    TextField(localized("namePlaceholder"), text: $profile.name, onEditingChanged: { editing in
                        if editing {
                            nameState = .manualInput
                            SpeechRecognizer.shared.stop()
                            VoiceGuide.speak(localized("manualPrompt"), languageCode: langCode)
                        }
                    })
                    .onSubmit {
                        nameState = .completed
                        VoiceGuide.speak(localized("confirmRegister"), languageCode: langCode)
                    }
                    
                    TextField(localized("emailPlaceholder"), text: $profile.email)
                        .keyboardType(.emailAddress)
                    
                    DatePicker(localized("birthPlaceholder"), selection: $profile.birthdate, displayedComponents: .date)
                    
                    TextField(localized("postalPlaceholder"), text: $profile.postalCode)
                        .keyboardType(.numbersAndPunctuation)
                        .onChange(of: profile.postalCode) {
                            profile.region = RegionResolver.resolveRegion(postalCode: profile.postalCode)
                        }
                    
                    Text(profile.region.isEmpty ? "" : "📍 \(profile.region)")
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text(localized("healthInfo"))) {
                    TextField(localized("heightPlaceholder"), value: $profile.heightCm, format: .number)
                        .keyboardType(.decimalPad)
                        .onChange(of: profile.heightCm) { _ in
                            VoiceGuide.speak(localized("reconfigNotice"), languageCode: langCode)
                        }
                    
                    TextField(localized("weightPlaceholder"), value: $profile.weightKg, format: .number)
                        .keyboardType(.decimalPad)
                        .onChange(of: profile.weightKg) { _ in
                            VoiceGuide.speak(localized("reconfigNotice"), languageCode: langCode)
                        }
                    
                    if profile.bmi > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("📐 BMI: \(profile.bmi, specifier: "%.1f")")
                                .font(.body)
                                .bold()
                            Text("🩺 判定: \(profile.bmiCategory)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    }
                }
                
                Section(header: Text(localized("optionalInfo"))) {
                    Picker(localized("genderPlaceholder"), selection: $profile.gender) {
                        ForEach(GenderType.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    
                    Picker(localized("bloodPlaceholder"), selection: $profile.bloodType) {
                        ForEach(BloodType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField(localized("occupationPlaceholder"), text: $profile.occupation)
                    
                    TextField(localized("hobbyPlaceholder"), text: Binding(
                        get: { profile.hobbies.joined(separator: ", ") },
                        set: { profile.hobbies = $0.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
                    ))
                    
                    TextField(localized("allergyPlaceholder"), text: Binding(
                        get: { profile.allergies.joined(separator: ", ") },
                        set: { profile.allergies = $0.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
                    ))
                }
                
                Section {
                    Button(localized("confirmButton")) {
                        VoiceGuide.speak(localized("confirmRegister"), languageCode: langCode)
                        showMain = true
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle(localized("title"))
            .navigationDestination(isPresented: $showMain) {
                FloatingCompanionOverlayView()
            }
            .onAppear {
                startNameFlow()
            }
        }
    }
    
    var isValid: Bool {
        !profile.name.isEmpty &&
        !profile.email.isEmpty &&
        !profile.postalCode.isEmpty &&
        profile.heightCm > 0 &&
        profile.weightKg > 0
    }
    
    private func startNameFlow() {
        nameState = .waitingSpeech
        VoiceGuide.speak(localized("namePrompt"), languageCode: langCode)
        try? SpeechRecognizer.shared.start(locale: langCode) { result in
            profile.name = result
            SpeechRecognizer.shared.stop()
            nameState = .confirming
            VoiceGuide.speak(localized("confirmName"), languageCode: langCode)
            waitForConfirmation()
        }
    }
    
    private func waitForConfirmation() {
        try? SpeechRecognizer.shared.start(locale: langCode) { response in
            let lower = response.lowercased()
            if lower.contains("はい") || lower.contains("yes") {
                SpeechRecognizer.shared.stop()
                nameState = .completed
                VoiceGuide.speak(localized("confirmRegister"), languageCode: langCode)
            } else if lower.contains("違う") || lower.contains("no") {
                SpeechRecognizer.shared.stop()
                nameState = .correction
                VoiceGuide.speak(localized("correctionPrompt"), languageCode: langCode)
                waitForCorrection()
            }
        }
    }
    
    private func waitForCorrection() {
        try? SpeechRecognizer.shared.start(locale: langCode) { correction in
            profile.name = correction
            SpeechRecognizer.shared.stop()
            nameState = .confirming
            VoiceGuide.speak(localized("confirmName"), languageCode: langCode)
            waitForConfirmation()
        }
    }
    
    private func localized(_ key: String) -> String {
        switch (key, langCode) {
            // 日本語対応
        case ("title", "ja"): return "プロフィール登録"
        case ("helpButton", "ja"): return "ヘルプ"
        case ("helpText", "ja"): return "この画面ではプロフィールを登録します。音声でも入力できます。"
        case ("backButton", "ja"): return "戻る"
        case ("backText", "ja"): return "前の画面に戻ります。"
        case ("mainButton", "ja"): return "メイン画面へ"
        case ("mainText", "ja"): return "メイン画面に移動します。"
        case ("confirmButton", "ja"): return "次へ"
        case ("confirmRegister", "ja"): return "こちらで登録しますね。次をお願いします。"
        case ("namePrompt", "ja"): return "お名前をどうぞ。"
        case ("confirmName", "ja"): return "これで良いですか？"
        case ("correctionPrompt", "ja"): return "どこが違いますか？"
        case ("manualPrompt", "ja"): return "もしよろしければ手入力いただけますか？"
        case ("reconfigNotice", "ja"): return "身長や体重に変更があるときは、UserProfile設定で再設定できますよ。"
            
        case ("personalInfo", "ja"): return "基本情報"
        case ("healthInfo", "ja"): return "健康情報"
        case ("optionalInfo", "ja"): return "任意情報"
            
        case ("namePlaceholder", "ja"): return "氏名を入力してください"
        case ("emailPlaceholder", "ja"): return "メールアドレスを入力してください"
        case ("birthPlaceholder", "ja"): return "生年月日を選択してください"
        case ("postalPlaceholder", "ja"): return "郵便番号を入力してください"
        case ("heightPlaceholder", "ja"): return "身長を入力してください（cm）"
        case ("weightPlaceholder", "ja"): return "体重を入力してください（kg）"
        case ("genderPlaceholder", "ja"): return "性別を選択してください"
        case ("bloodPlaceholder", "ja"): return "血液型を選択してください"
        case ("occupationPlaceholder", "ja"): return "職業を入力してください"
        case ("hobbyPlaceholder", "ja"): return "趣味を入力してください（カンマ区切り）"
        case ("allergyPlaceholder", "ja"): return "アレルギー歴を入力してください（カンマ区切り）"
        case ("bmi", "ja"): return "BMI"
        case ("bmiCategory", "ja"): return "判定"
            
            // 英語対応
        case ("title", "en"): return "Profile Registration"
        case ("helpButton", "en"): return "Help"
        case ("helpText", "en"): return "This screen lets you register your profile. You can also use voice input."
        case ("backButton", "en"): return "Back"
        case ("backText", "en"): return "Returning to the previous screen."
        case ("mainButton", "en"): return "Go to Main"
        case ("mainText", "en"): return "Navigating to the main screen."
        case ("confirmButton", "en"): return "Next"
        case ("confirmRegister", "en"): return "I'll register this for you. Let's continue."
        case ("namePrompt", "en"): return "Please say your name."
        case ("confirmName", "en"): return "Is this correct?"
        case ("correctionPrompt", "en"): return "What part is incorrect?"
        case ("manualPrompt", "en"): return "Feel free to enter it manually if you prefer."
        case ("reconfigNotice", "en"): return "If your height or weight changes, you can update it anytime in your UserProfile settings."
            
        case ("personalInfo", "en"): return "Basic Info"
        case ("healthInfo", "en"): return "Health Info"
        case ("optionalInfo", "en"): return "Optional Info"
            
        case ("namePlaceholder", "en"): return "Enter your name"
        case ("emailPlaceholder", "en"): return "Enter your email address"
        case ("birthPlaceholder", "en"): return "Select your birthdate"
        case ("postalPlaceholder", "en"): return "Enter your postal code"
        case ("heightPlaceholder", "en"): return "Enter your height (cm)"
        case ("weightPlaceholder", "en"): return "Enter your weight (kg)"
        case ("genderPlaceholder", "en"): return "Select your gender"
        case ("bloodPlaceholder", "en"): return "Select your blood type"
        case ("occupationPlaceholder", "en"): return "Enter your occupation"
        case ("hobbyPlaceholder", "en"): return "Enter your hobbies (comma-separated)"
        case ("allergyPlaceholder", "en"): return "Enter your allergies (comma-separated)"
        case ("bmi", "en"): return "BMI"
        case ("bmiCategory", "en"): return "Category"
            
        default: return key
        }
    }
}
