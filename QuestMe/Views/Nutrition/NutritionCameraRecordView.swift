//
//  NutritionCameraRecordView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Nutrition/NutritionCameraRecordView.swift
//
//  🎯 ファイルの目的:
//      栄養記録用カメラ画面の UI。
//      - カメラプレビュー表示、手動/自動撮影、圧縮、保存トリガー
//      - 12言語対応ヘルプ（右上❓）
//      - 解析インジケータと待機表示（2秒超）
//      - 保存後ダイアログ（追加撮影 / メニュー / メイン画面）
//      - 保存は NutritionStorageManager に委譲（Calendar 規約）
//
//  🔗 連動:
//      - CameraPreview.swift（プレビュー）
//      - PhotoDelegate.swift（撮影コールバック）
//      - ImageCompressor.swift（圧縮）
//      - LocalizationHelper.swift（文言多言語）
//      - MealRecord.swift（モデル）
//      - NutritionStorageManager.swift（保存処理）
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-23 13:20 JST
//

import SwiftUI
import AVFoundation
import CoreMotion
import Vision
import UIKit

struct NutritionCameraRecordView: View {
    // UI 状態
    @State private var showHelp = false
    @State private var showSavedDialog = false
    @State private var isAnalyzing = false
    @State private var analysisStart: Date?
    @State private var showWaitingLabel = false

    @State private var capturedImage: UIImage?
    @State private var estimatedCalories: Double?

    // 自動撮影条件
    @State private var isStable = false
    @State private var isLargeEnough = false

    // カメラ
    @State private var session = AVCaptureSession()
    @State private var photoOutput = AVCapturePhotoOutput()
    private let motionManager = CMMotionManager()

    var body: some View {
        NavigationStack {
            ZStack {
                CameraPreview(session: session)
                    .overlay(guideOverlay)

                VStack {
                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .padding(.top, 8)
                    }

                    if isAnalyzing {
                        VStack(spacing: 8) {
                            ProgressView()
                            Text(localized("解析までしばらくお待ちください…"))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .opacity(showWaitingLabel ? 1.0 : 0.0)
                        }
                        .onAppear {
                            analysisStart = Date()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                if let start = analysisStart,
                                   Date().timeIntervalSince(start) >= 2.0 {
                                    showWaitingLabel = true
                                }
                            }
                        }
                    }

                    Spacer()

                    // 撮影ボタン（手動）
                    Button(action: manualCapture) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 70, height: 70)
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .padding(.bottom, 20)
                            .accessibilityLabel(localized("撮影"))
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("🥗 " + localized("栄養記録"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("❓") {
                        CompanionOverlay.shared.speak(helpText(for: currentLang()))
                        showHelp = true
                    }
                    .accessibilityLabel(localized("ヘルプ"))
                }
            }
            .onAppear { setupCameraPipeline() }
            .alert(localized("保存が完了しました"), isPresented: $showSavedDialog) {
                Button(localized("追加撮影")) { restartCapture() }
                Button(localized("メニュー")) { dismissSelf() }
                Button(localized("メイン画面")) { goToMainScreen() }
            } message: {
                Text(estimatedCaloriesText())
            }
        }
    }

    // ガイド枠
    private var guideOverlay: some View {
        GeometryReader { geo in
            let w = geo.size.width * 0.8
            let h = geo.size.height * 0.35
            RoundedRectangle(cornerRadius: 12)
                .stroke(isLargeEnough ? Color.green : Color.yellow, lineWidth: 3)
                .frame(width: w, height: h)
                .position(x: geo.size.width / 2, y: geo.size.height * 0.45)
        }
    }

    // カメラセットアップ
    private func setupCameraPipeline() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            CompanionOverlay.shared.speak(localized("カメラを初期化できませんでした。"))
            return
        }
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }

        // iOS16〜の最大解像度設定
        try? device.lockForConfiguration()
        if #available(iOS 16.0, *) {
            photoOutput.maxPhotoDimensions = .init(width: 4032, height: 3024)
        } else {
            photoOutput.isHighResolutionCaptureEnabled = true
        }
        // 安定化
        if device.isFocusModeSupported(.continuousAutoFocus) { device.focusMode = .continuousAutoFocus }
        if device.isExposureModeSupported(.continuousAutoExposure) { device.exposureMode = .continuousAutoExposure }
        if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) { device.whiteBalanceMode = .continuousAutoWhiteBalance }
        device.unlockForConfiguration()

        session.commitConfiguration()
        session.startRunning()

        startMotionStabilityCheck()
        startSizeDetection()
    }

    // 手動撮影
    private func manualCapture() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        photoOutput.capturePhoto(with: settings, delegate: PhotoDelegate { image in
            capturedImage = image
            analyzeAndSave(image: image)
        })
    }

    // 手ぶれ判定
    private func startMotionStabilityCheck() {
        motionManager.accelerometerUpdateInterval = 0.05
        motionManager.startAccelerometerUpdates(to: .main) { data, _ in
            guard let a = data?.acceleration else { return }
            let delta = abs(a.x) + abs(a.y) + abs(a.z)
            isStable = delta < 0.05
            tryAutoCapture()
        }
    }

    // 大きさ検知（簡易）
    private func startSizeDetection() {
        // 実運用では AVCaptureVideoDataOutput + Vision を推奨
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isLargeEnough = true
            tryAutoCapture()
        }
    }

    // 条件成立で自動撮影
    private func tryAutoCapture() {
        guard isStable && isLargeEnough else { return }
        manualCapture()
        isStable = false
        isLargeEnough = false
    }

    // 解析と保存（NutritionStorageManager に委譲）
    private func analyzeAndSave(image: UIImage) {
        isAnalyzing = true
        analysisStart = Date()
        showWaitingLabel = false

        DispatchQueue.global(qos: .userInitiated).async {
            let compressed = compressToTarget(image: image, targetKB: 300)
            let calories = estimateCaloriesPlaceholder(from: compressed)
            estimatedCalories = calories

            let record = MealRecord(
                mealType: localized("食事"),
                userInput: localized("撮影された食事"),
                calories: calories,
                protein: 20,
                fat: 15,
                carbs: 60,
                compressedImage: compressed
            )
            NutritionStorageManager.shared.saveMeal(record)

            DispatchQueue.main.async {
                isAnalyzing = false
                showSavedDialog = true
                CompanionOverlay.shared.speak(localized("保存しました。追加撮影、メニュー、またはメイン画面を選んでください。"))
            }
        }
    }

    // ダイアログ操作
    private func restartCapture() {
        capturedImage = nil
        estimatedCalories = nil
        showSavedDialog = false
        CompanionOverlay.shared.speak(localized("もう一度撮影します。中央の枠に料理を大きく収めてください。"))
        startSizeDetection()
        startMotionStabilityCheck()
    }

    private func dismissSelf() {
        CompanionOverlay.shared.speak(localized("メニューに戻ります。"))
        // 呼び出し側で閉じる想定（ここではナビゲーション操作を委譲）
    }

    private func goToMainScreen() {
        CompanionOverlay.shared.speak(localized("メイン画面に戻ります。"))
        // 呼び出し側の Navigation ルートに戻るロジックに委譲
    }

    // 文言
    private func estimatedCaloriesText() -> String {
        guard let cal = estimatedCalories else { return localized("解析が完了しました。") }
        return String(format: localized("推定摂取カロリー: %.0f kcal"), cal)
    }
}
