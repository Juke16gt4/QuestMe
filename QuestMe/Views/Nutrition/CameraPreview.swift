//
//  CameraPreview.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Nutrition/CameraPreview.swift
//
//  🎯 ファイルの目的:
//      AVCaptureVideoPreviewLayer を SwiftUI に橋渡しするビューラッパー
//
//  🔗 連動:
//      - NutritionCameraRecordView.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-23 13:20 JST
//

import SwiftUI
import AVFoundation
import UIKit

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        if let screen = v.window?.windowScene?.screen {
            layer.frame = screen.bounds
        } else {
            layer.frame = UIScreen.main.bounds // 互換
        }
        v.layer.addSublayer(layer)
        return v
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
