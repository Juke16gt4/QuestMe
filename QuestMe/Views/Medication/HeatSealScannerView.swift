//
//  HeatSealScannerView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Medication/HeatSealScannerView.swift
//
//  🎯 ファイルの目的:
//      医薬品PTPシート（ヒートシール包装）をカメラで撮影し、Visionフレームワークで文字認識（OCR）を行う。
//      - 薬剤名・容量を抽出し、Medication.sqlite3 に追加保存。
//      - VNDocumentCameraViewController により撮影。
//      - MedicationDialog.swift から呼び出される。
//
//  🔗 依存:
//      - VisionKit / Vision（OCR）
//      - MedicationManager.swift（保存）
//      - MedicationDialog.swift（呼び出し元）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import SwiftUI
import VisionKit
import Vision

struct HeatSealScannerView: UIViewControllerRepresentable {
    var completion: (Result<(String, String), Error>) -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: HeatSealScannerView

        init(parent: HeatSealScannerView) {
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                parent.completion(.failure(NSError(domain: "HeatSealScan", code: -1, userInfo: nil)))
                return
            }

            let image = scan.imageOfPage(at: 0)
            recognizeText(from: image)
            controller.dismiss(animated: true)
        }

        private func recognizeText(from image: UIImage) {
            guard let cgImage = image.cgImage else { return }

            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    self.parent.completion(.failure(error))
                    return
                }

                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }

                // 簡易解析: 薬剤名と容量を抽出
                let drugName = recognizedStrings.first(where: { $0.contains("錠") || $0.contains("カプセル") }) ?? "不明薬剤"
                let dosage = recognizedStrings.first(where: { $0.contains("mg") || $0.contains("μg") }) ?? "規格不明"

                self.parent.completion(.success((drugName, dosage)))
            }

            request.recognitionLevel = .accurate
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
}
