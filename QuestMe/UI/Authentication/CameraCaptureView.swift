//
//  CameraCaptureView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Companion/Camera/CameraCaptureView.swift
//
//  🎯 ファイルの目的:
//      カメラから顔画像（CVPixelBuffer）を取得し、呼び出し元に渡す。
//      - 顔認証・顔登録に使用。
//  🔗 依存:
//      - AVFoundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月11日
//

import SwiftUI
import AVFoundation

struct CameraCaptureView: UIViewControllerRepresentable {
    var onCapture: (CVPixelBuffer) -> Void
    
    func makeUIViewController(context: Context) -> CameraCaptureViewController {
        let controller = CameraCaptureViewController()
        controller.onCapture = onCapture
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraCaptureViewController, context: Context) {}
}

final class CameraCaptureViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var onCapture: ((CVPixelBuffer) -> Void)?
    
    private let session = AVCaptureSession()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("❌ カメラ入力の初期化に失敗しました")
            return
        }
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.queue"))
        guard session.canAddOutput(output) else {
            print("❌ カメラ出力の初期化に失敗しました")
            return
        }
        session.addOutput(output)
        
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        session.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        DispatchQueue.main.async {
            self.onCapture?(pixelBuffer)
            self.session.stopRunning()
            self.dismiss(animated: true)
        }
    }
}
