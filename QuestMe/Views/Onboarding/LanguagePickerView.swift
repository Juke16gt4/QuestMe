//
//  LanguagePickerView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Onboarding/LanguagePickerView.swift
//
//  🎯 ファイルの目的:
//      母国語を選択するためのピッカービュー。
//      - 言語選択後、2秒静止で音声確認 → 「はい／いいえ」ダイアログで確定。
//      - 確定時に AppStorage に保存。
//      - SpeechManager による音声確認と連携。
//
//  🔗 依存:
//      - LanguageOption.swift（言語定義）
//      - SpeechManager.swift（音声）
//      - AppStorage（保存）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import SwiftUI

struct LanguagePickerView: View {
    @AppStorage("selectedLanguageCode") private var storedLanguageCode: String = ""

    @State private var selectedLanguage: LanguageOption = .all.first! // 初期値: 日本語
    @State private var lastMovedAt: Date = Date()
    @State private var showConfirmation = false
    @State private var didConfirm = false

    var body: some View {
        VStack {
            Text("母国語を選択してください")
                .font(.headline)
                .padding()

            Picker("言語を選択", selection: $selectedLanguage) {
                ForEach(LanguageOption.all) { lang in
                    Text(lang.name).tag(lang)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .onChange(of: selectedLanguage) {
                lastMovedAt = Date()
                didConfirm = false
                showConfirmation = false
                startIdleCheck()
            }
        }
        .onAppear {
            lastMovedAt = Date()
            startIdleCheck()
        }
        .alert("これで良いですか？", isPresented: $showConfirmation) {
            Button("はい") {
                didConfirm = true
                storedLanguageCode = selectedLanguage.code
                print("✅ 言語確定: \(selectedLanguage.name)")
            }
            Button("いいえ", role: .cancel) {
                didConfirm = false
                lastMovedAt = Date()
                startIdleCheck()
            }
        } message: {
            Text("\(selectedLanguage.welcome) (\(selectedLanguage.name))")
        }
    }

    private func startIdleCheck() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            guard !didConfirm else { return }
            let idleTime = Date().timeIntervalSince(lastMovedAt)
            if idleTime >= 2.0 {
                SpeechManager.shared.speakConfirmation(for: selectedLanguage)
                showConfirmation = true
            }
        }
    }
}
