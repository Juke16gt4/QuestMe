//
//  GS1ScannerView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Medication/GS1ScannerView.swift
//
//  🎯 ファイルの目的:
//      医薬品パッケージに印字された GS1 バーコードを読み取る専用カメラビュー。
//      - 読み取ったコードを解析し、薬剤名・容量を抽出して Medication.sqlite3 に保存。
//      - AVCaptureSession によりリアルタイム読み取り。
//      - MedicationDialog.swift から呼び出される。
//
//  🔗 依存:
//      - AVFoundation（カメラ）
//      - MedicationManager.swift（保存）
//      - MedicationDialog.swift（呼び出し元）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import SwiftUI
import AVFoundation

struct GS1ScannerView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: GS1ScannerView

        init(parent: GS1ScannerView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let code = object.stringValue {
                parent.completion(.success(code))
            } else {
                parent.completion(.failure(NSError(domain: "GS1Scan", code: -1, userInfo: nil)))
            }
        }
    }

    var completion: (Result<String, Error>) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let session = AVCaptureSession()

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            completion(.failure(NSError(domain: "GS1Scan", code: -2, userInfo: nil)))
            return controller
        }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
        // GS1コードはEAN/Code128など → 医薬品バーコード規格に対応
        output.metadataObjectTypes = [.ean13, .ean8, .code128]

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        controller.view.layer.addSublayer(previewLayer)

        session.startRunning()
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
