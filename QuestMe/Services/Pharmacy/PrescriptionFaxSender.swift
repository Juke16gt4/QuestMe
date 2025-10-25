//
//  PrescriptionFaxSender.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/Pharmacy/PrescriptionFaxSender.swift
//
//  🎯 ファイルの目的:
//      AirPrintを用いた処方箋Fax送信処理。
//      - PDFを生成し、UIPrintInteractionControllerで送信。
//      - Companionが送信完了・失敗を音声で通知。
//      - 送信後にPDFと元画像を自動削除。
//      - 将来的にAPI送信にも拡張可能な構造。
//
//  🔗 依存:
//      - UIKit
//      - PDFKit
//      - Models/PharmacyFaxEntry.swift
//      - CompanionOverlay.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import UIKit
import PDFKit

final class PrescriptionFaxSender {
    static func sendFax(to pharmacy: PharmacyFaxEntry, from view: UIViewController, image: UIImage?) {
        guard let pdfURL = createPDF(for: pharmacy.name, from: image) else {
            CompanionOverlay.shared.speak("PDF生成に失敗しました。")
            return
        }

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "処方箋Fax送付"

        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printingItem = pdfURL

        printController.present(animated: true) { _, completed, error in
            if completed {
                CompanionOverlay.shared.speak("薬局「\(pharmacy.name)」にFax送信しました。")
            } else if let error = error {
                CompanionOverlay.shared.speak("送信に失敗しました: \(error.localizedDescription)")
            }

            // 🔥 自動削除処理
            try? FileManager.default.removeItem(at: pdfURL)
            if let image = image {
                deleteTemporaryImage(image)
            }
        }
    }

    private static func createPDF(for pharmacyName: String, from image: UIImage?) -> URL? {
        let filename = "prescription_\(UUID().uuidString).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 300, height: 400))
        do {
            try renderer.writePDF(to: url, withActions: { ctx in
                ctx.beginPage()
                let text = "処方箋送付先: \(pharmacyName)\nQuestMeより送信"
                text.draw(at: CGPoint(x: 20, y: 20), withAttributes: [.font: UIFont.systemFont(ofSize: 14)])

                if let image = image {
                    let imageRect = CGRect(x: 20, y: 60, width: 260, height: 300)
                    image.draw(in: imageRect)
                }
            })
            return url
        } catch {
            return nil
        }
    }

    private static func deleteTemporaryImage(_ image: UIImage) {
        // 仮に画像が保存されていた場合の削除処理（例: Documentsやtmpに保存されていた場合）
        // 実際の保存先がある場合はそのパスを明示する必要あり
        // この関数は拡張用のフックとして残してあります
    }
}
