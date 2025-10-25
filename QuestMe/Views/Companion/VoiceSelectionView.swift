//
//  VoiceSelectionView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/VoiceSelectionView.swift
//
//  🎯 ファイルの目的:
//      Companion の声スタイルと声色を選択するためのビュー。
//      - ProfileCreationFlow から avatar と onComplete を受け取る。
//      - AVSpeechSynthesizer によるプレビュー再生機能あり。
//      - Companion の人格形成における「声の儀式」を担う。
//
//  🔗 依存:
//      - CompanionAvatar.swift（アバター）
//      - VoiceProfile.swift（声の構造）
//      - AVFoundation（音声再生）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月1日

import SwiftUI
import AVFoundation

struct VoiceSelectionView: View {
    var selectedAvatar: CompanionAvatar
    var onComplete: (VoiceProfile) -> Void

    @State private var selectedStyle: VoiceStyle = .calm
    @State private var selectedTone: VoiceTone = .neutral
    @State private var synthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            Picker("スタイル", selection: $selectedStyle) {
                ForEach(VoiceStyle.allCases, id: \.self) { style in
                    Text(style.rawValue).tag(style)
                }
            }
            .pickerStyle(.segmented)

            Picker("声色", selection: $selectedTone) {
                ForEach(VoiceTone.allCases, id: \.self) { tone in
                    Text(tone.rawValue).tag(tone)
                }
            }
            .pickerStyle(.segmented)

            Button("プレビュー再生") {
                let profile = VoiceProfile(style: selectedStyle, tone: selectedTone)
                speakSample(for: profile)
            }

            Button("この声で決定") {
                let profile = VoiceProfile(style: selectedStyle, tone: selectedTone)
                onComplete(profile)
            }
        }
        .padding()
    }

    private func speakSample(for profile: VoiceProfile) {
        let utterance = AVSpeechUtterance(string: "こんにちは、私はあなたの寄り添うコンパニオンです。")
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        synthesizer.speak(utterance)
    }
}
