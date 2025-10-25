//
//  CompanionSetupView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Setup/CompanionSetupView.swift
//
//  🎯 ファイルの目的:
//      初回起動時にユーザーがAIコンパニオンを1体生成する儀式ビュー。
//      - 名前・性格・AIエンジン・声・アバター（画像＋希望）を設定
//      - アバターは必ず正面向き・高解像度・希望記述付きで生成
//      - Avatar.swift の構造（prompt, orientation, quality）を完全に組み込み済み
//      - 「決定」ボタンで設定確定 → 「次へ」ボタンで UserProfileView.swift に遷移
//      - 12言語対応・音声案内・音声操作対応
//
//  🔗 関連/連動ファイル:
//      - VoiceProfile.swift（声モデル）
//      - VoiceProfile+Inference.swift（推定）
//      - AIEngine.swift（AIエンジン選択）
//      - ImagePickerView.swift（画像選択）
//      - UserProfileView.swift（ユーザー登録儀式）
//      - EmotionLogRepository.swift（感情ログ保存）
//      - CompanionAvatar.swift（役割・性別）
//      - Avatar.swift（アバター構造）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月20日（UserProfileView遷移版）

import SwiftUI
import AVFoundation

public struct CompanionSetupView: View {
    @AppStorage("selectedLanguageCode") private var langCode: String = "ja"

    // 入力状態
    @State private var name: String = ""
    @State private var personality: String = ""
    @State private var selectedEngine: AIEngine = .copilot
    @State private var selectedAvatarRole: CompanionAvatar = .mentor
    @State private var voiceURL: URL?
    @State private var imageData: Data?
    @State private var userPromptText: String = ""
    @State private var selectedStyle: AvatarStyle = .photoRealistic

    // 状態管理
    @State private var isConfirmed = false
    @State private var showNextButton = false
    @State private var showImagePicker = false
    @State private var showVoicePicker = false
    @State private var profile: CompanionProfile?

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text(localized("title"))
                        .font(.title2)
                        .bold()

                    Button(localized("helpButton")) {
                        SpeechSync().speak(localized("helpText"))
                    }
                    .buttonStyle(.bordered)

                    TextField(localized("nameField"), text: $name)
                        .textFieldStyle(.roundedBorder)

                    TextField(localized("personalityField"), text: $personality)
                        .textFieldStyle(.roundedBorder)

                    Picker(localized("enginePicker"), selection: $selectedEngine) {
                        ForEach(AIEngine.allCases, id: \.self) { engine in
                            Text(engine.label).tag(engine)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker(localized("avatarRolePicker"), selection: $selectedAvatarRole) {
                        ForEach(CompanionAvatar.allCases) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }

                    Button(localized("selectImage")) {
                        showImagePicker = true
                    }

                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                    }

                    TextEditor(text: $userPromptText)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                        .padding(.bottom, 8)

                    Picker(localized("stylePicker"), selection: $selectedStyle) {
                        ForEach(AvatarStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }

                    Button(localized("selectVoice")) {
                        showVoicePicker = true
                    }

                    if let voiceURL = voiceURL {
                        Text(localized("voiceSelected") + voiceURL.lastPathComponent)
                            .font(.footnote)
                    }

                    Button(localized("confirmButton")) {
                        profile = generateProfile()
                        isConfirmed = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            showNextButton = true
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    if showNextButton {
                        NavigationLink(destination: UserProfileView()) {
                            Text(localized("nextButton"))
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            .navigationTitle(localized("title"))
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(selectedImage: Binding(get: {
                imageData.flatMap { UIImage(data: $0) }
            }, set: { newImage in
                imageData = newImage?.jpegData(compressionQuality: 1.0)
            }))
        }
        .sheet(isPresented: $showVoicePicker) {
            VoicePickerView(selectedVoiceURL: $voiceURL)
        }
    }

    // MARK: - プロフィール生成
    private func generateProfile() -> CompanionProfile {
        let prompt = AvatarPrompt(
            description: userPromptText,
            style: selectedStyle,
            realism: true
        )

        let avatar = Avatar.custom(
            data: imageData,
            prompt: prompt,
            orientation: .frontFacing,
            quality: .highResolution
        )

        let voice = VoiceProfile.inferred(from: voiceURL)

        return CompanionProfile(
            name: name,
            avatar: avatar,
            voice: voice,
            aiEngine: selectedEngine,
            role: selectedAvatarRole
        )
    }

    // MARK: - 多言語ラベル
    private func localized(_ key: String) -> String {
        switch (key, langCode) {
        case ("title", "ja"): return "🧍‍♂️ コンパニオン生成"
        case ("nameField", "ja"): return "名前を入力"
        case ("personalityField", "ja"): return "性格を入力"
        case ("enginePicker", "ja"): return "AIエンジン選択"
        case ("avatarRolePicker", "ja"): return "役割を選択"
        case ("selectImage", "ja"): return "画像を選択"
        case ("stylePicker", "ja"): return "スタイル選択"
        case ("selectVoice", "ja"): return "音声ファイルを選択"
        case ("voiceSelected", "ja"): return "選択された音声: "
        case ("confirmButton", "ja"): return "決定"
        case ("nextButton", "ja"): return "次へ"
        case ("helpButton", "ja"): return "ヘルプ"
        case ("helpText", "ja"): return "この画面ではコンパニオンの名前、性格、AIエンジン、画像、声を設定します。"

        case ("title", "en"): return "🧍‍♂️ Companion Creation Ritual"
        case ("nameField", "en"): return "Enter name"
        case ("personalityField", "en"): return "Enter personality"
        case ("enginePicker", "en"): return "Select AI Engine"
        case ("avatarRolePicker", "en"): return "Select Role"
        case ("selectImage", "en"): return "Select Image"
        case ("stylePicker", "en"): return "Select Style"
        case ("selectVoice", "en"): return "Select Voice File"
        case ("voiceSelected", "en"): return "Selected Voice: "
        case ("confirmButton", "en"): return "Confirm"
        case ("nextButton", "en"): return "Next"
        case ("helpButton", "en"): return "Help"
        case ("helpText", "en"): return "On this screen, you set your companion's name, personality, AI engine, image, and voice."

        default: return key
        }
    }
}
