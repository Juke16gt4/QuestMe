//
//  CompanionLoginView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Companion/Login/CompanionLoginView.swift
//
//  🎯 ファイルの目的:
//      顔認証によるログイン画面。
//      - カメラから顔画像を取得し、CompanionProfile.faceprintData と照合。
//      - 認証成功時に profile.id に基づいて CompanionHomeView に動的遷移。
//  🔗 依存:
//      - FaceAuthenticator.swift
//      - CompanionProfile.swift
//      - CameraCaptureView.swift
//      - CompanionHomeView.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月11日
//

import SwiftUI
import AVFoundation

struct CompanionLoginView: View {
    @EnvironmentObject var locale: LocalizationManager
    @State private var profile: CompanionProfile = CompanionProfile.defaultProfile()
    @State private var showCamera = false
    @State private var isAuthenticated = false
    @State private var authenticationAttempted = false
    @State private var authenticatedProfileID: UUID? = nil
    @State private var authenticator = FaceAuthenticator()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(locale.localized("face_auth_title"))
                    .font(.title)
                    .bold()

                Button(locale.localized("face_capture_button")) {
                    showCamera = true
                }
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(12)

                if authenticationAttempted {
                    if isAuthenticated {
                        Text("✅ \(locale.localized("face_auth_success")) \(profile.name)")
                            .foregroundColor(.green)
                            .font(.headline)
                    } else {
                        Text("❌ \(locale.localized("face_auth_fail"))")
                            .foregroundColor(.red)
                            .font(.headline)
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraCaptureView { pixelBuffer in
                    authenticationAttempted = true
                    isAuthenticated = authenticator?.authenticateFace(from: pixelBuffer, with: profile) ?? false
                    showCamera = false
                    if isAuthenticated {
                        authenticatedProfileID = profile.id
                        speak(locale.localized("face_auth_success"))
                    } else {
                        speak(locale.localized("face_auth_fail"))
                    }
                }
            }
            .navigationDestination(for: UUID.self) { id in
                CompanionHomeView(profile: profile)
            }
            .onChange(of: authenticatedProfileID) { newID in
                if newID != nil {
                    authenticatedProfileID = newID
                }
            }
            .navigationTitle(locale.localized("face_auth_title"))
            .padding()
        }
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: locale.speechCode())
        utterance.rate = 0.5
        AVSpeechSynthesizer().speak(utterance)
    }
}
