//
//  CompanionSettingsView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/Settings/CompanionSettingsView.swift
//
//  🎯 ファイルの目的:
//      登録済みコンパニオンの声や設定を編集する画面。
//      - プロフィールを @Binding 経由で受け取り編集
//      - サンプル音声再生で確認
//      - 保存後に ProfileStorage と CompanionOverlay に即時反映
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月11日
//

import SwiftUI
import AVFoundation

struct CompanionSettingsView: View {
    @Binding var profile: CompanionProfile
    @State private var isSpeaking = false

    var body: some View {
        Form {
            Section(header: Text("コンパニオンの声を変更")) {
                Picker("スタイル", selection: $profile.voice.style) {
                    ForEach(VoiceStyle.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }

                Picker("声色", selection: $profile.voice.tone) {
                    ForEach(VoiceTone.allCases, id: \.self) { tone in
                        Text(tone.rawValue).tag(tone)
                    }
                }

                Picker("速度", selection: $profile.voice.speed) {
                    ForEach(VoiceSpeed.allCases, id: \.self) { speed in
                        Text(speed.rawValue).tag(speed)
                    }
                }

                Button("サンプル再生") {
                    let sample = "こんにちは、私は \(profile.name) です。"
                    speak(sample, with: profile.voice)
                    isSpeaking = true
                }

                if isSpeaking {
                    Text("🎧 再生中…").foregroundColor(.blue)
                }
            }

            Section {
                Button("保存して戻る") {
                    _ = ProfileStorage.saveProfile(profile)
                    CompanionOverlay.shared.updateProfile(profile) // ✅ 即時反映
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("コンパニオン設定")
    }

    private func speak(_ text: String, with voice: VoiceProfile) {
        let utterance = AVSpeechUtterance(string: text)

        utterance.rate = {
            switch voice.speed {
            case .slow: return 0.4
            case .fast: return 0.65
            default: return 0.5
            }
        }()

        utterance.pitchMultiplier = {
            switch voice.tone {
            case .bright: return 1.2
            case .deep: return 0.8
            case .husky: return 0.9
            default: return 1.0
            }
        }()

        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        AVSpeechSynthesizer().speak(utterance)
    }
}
