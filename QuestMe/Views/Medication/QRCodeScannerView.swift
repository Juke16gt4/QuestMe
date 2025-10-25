//
//  QRCodeScannerView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Medication/QRCodeScannerView.swift
//
//  🎯 ファイルの目的:
//      処方箋QRコードをカメラで読み取り、薬剤名・容量を抽出して保存する。
//      - AVCaptureSession によりリアルタイム読み取り。
//      - MedicationManager に保存。
//      - MedicationDialogLauncherView から呼び出される。
//
//  🔗 依存:
//      - AVFoundation（カメラ）
//      - MedicationManager.swift（保存）
//      - CompanionOverlay.swift（音声案内）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import SwiftUI
import AVFoundation

struct QRCodeScannerView: UIViewControllerRepresentable {
    var completion: (Result<String, Error>) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let session = AVCaptureSession()

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            completion(.failure(NSError(domain: "QRScan", code: -2)))
            return controller
        }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.qr]

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        controller.view.layer.addSublayer(previewLayer)

        session.startRunning()
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRCodeScannerView

        init(parent: QRCodeScannerView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let code = object.stringValue {
                CompanionOverlay.shared.speak("QRコードを読み取りました。")
                parent.completion(.success(code))
            } else {
                parent.completion(.failure(NSError(domain: "QRScan", code: -1)))
            }
        }
    }
}
