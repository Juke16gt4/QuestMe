//
//  AuthenticationGateView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/Authentication/AuthenticationGateView.swift
//
//  🎯 ファイルの目的:
//      - 認証ゲート画面（音声・顔認証）
//      - LocalizationManager による多言語対応（UI表示・音声合成）
//      - 認証成功時に CompanionSetupView へ遷移
//
//  🔗 依存:
//      - Authentication/Voice/VoiceprintRecognitionView.swift（音声認証）
//      - UI/Authentication/Face/FaceRecognitionView.swift（顔認証）
//      - Managers/LocalizationManager.swift（@EnvironmentObject）
//      - Setup/CompanionSetupView.swift（遷移先）
//
//  👤 作成者: 津村 淳一
//  📅 修正版: 2025年10月24日（曖昧 init 解消）
//

import SwiftUI
import AVFoundation

struct AuthenticationGateView: View {
    @EnvironmentObject var locale: LocalizationManager
    @State private var voiceAuthenticated = false
    @State private var faceAuthenticated = false
    @State private var navigateToCompanionSetup = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text(locale.localized("auth_title"))
                    .font(.title2)
                    .padding()

                let voiceAuthHandler: () -> Void = {
                    voiceAuthenticated = true
                    navigateToCompanionSetup = true
                    speak(locale.localized("voice_auth_success"))
                }

                let faceAuthHandler: () -> Void = {
                    faceAuthenticated = true
                    navigateToCompanionSetup = true
                    speak(locale.localized("face_auth_success"))
                }

                VoiceprintRecognitionView(onAuthenticated: voiceAuthHandler)
                FaceRecognitionView(onAuthenticated: faceAuthHandler)
            }
            .padding()
            // ✅ iOS16以降の推奨APIに変更
            .navigationDestination(isPresented: $navigateToCompanionSetup) {
                CompanionSetupView()
            }
        }
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: locale.speechCode())
        utterance.rate = 0.5
        AVSpeechSynthesizer().speak(utterance)
    }
}
