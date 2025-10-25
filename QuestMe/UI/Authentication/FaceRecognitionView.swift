//
//  FaceRecognitionView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/Authentication/Face/FaceRecognitionView.swift
//
//  🎯 ファイルの目的:
//      ユーザーの顔画像を取得し、保存済み顔特徴量と照合して認証するビュー。
//      - カメラで顔を撮影 → 顔特徴量抽出 → 保存済みデータと照合。
//      - CompanionProfile.faceprintData と比較して認証。
//      - 認証成功時に onAuthenticated() を呼び出す。
//      - LocalizationManager を利用して多言語対応（テキスト・音声）。
//
//  🔗 依存:
//      - UIKit（UIImagePickerController）
//      - FaceAuthenticator.swift（照合ロジック）
//      - ProfileStorage.swift（保存済みプロフィール）
//      - LocalizationManager.swift（文言管理）
//      - SupportedLanguage.swift（言語定義）
//
//  👤 製作者: 津村 淳一
//  📅 修正日: 2025年10月16日
//

import SwiftUI
import UIKit
import AVFoundation

struct FaceRecognitionView: View {
    var onAuthenticated: () -> Void

    @EnvironmentObject var locale: LocalizationManager
    @State private var showCamera = false
    @State private var capturedImage: UIImage?

    var body: some View {
        VStack(spacing: 16) {
            Text(locale.localized("face_auth_title"))
                .font(.headline)

            Button(locale.localized("face_capture_button")) {
                showCamera = true
            }

            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)

                Button(locale.localized("face_verify_button")) {
                    verifyFace(image)
                }
                .padding()
                .background(Color.green.opacity(0.2))
                .cornerRadius(12)
            }
        }
        .sheet(isPresented: $showCamera) {
            ImageCaptureView(image: $capturedImage)
        }
        .padding()
    }

    // MARK: - 顔照合
    private func verifyFace(_ image: UIImage) {
        guard let storedData = ProfileStorage.loadProfiles().first?.faceprintData else {
            print(locale.localized("face_no_target"))
            return
        }

        if FaceAuthenticator.verify(image: image, against: storedData) {
            let success = locale.localized("face_auth_success")
            print("✅ \(success)")
            speak(success)
            onAuthenticated()
        } else {
            let fail = locale.localized("face_auth_fail")
            print("❌ \(fail)")
            speak(fail)
        }
    }

    // MARK: - 音声フィードバック
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: locale.current.speechCode)
        utterance.rate = 0.5
        AVSpeechSynthesizer().speak(utterance)
    }
}
