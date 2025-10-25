//
//  EmotionReportGenerator.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/PDF/EmotionReportGenerator.swift
//
//  🎯 ファイルの目的:
//      - 感情ログ・アドバイス履歴・検査値・相関コメント・グラフ画像を PDF にまとめる。
//      - UIKit の UIGraphicsPDFRenderer を使用。
//      - CompanionOverlay のコメントも埋め込める。
//      - iCloud保存・共有対応。
//

import UIKit

final class EmotionReportGenerator {
    static func generate(
        from emotions: [EmotionLog],
        advices: [[String: Any]],
        labs: [LabResult],
        correlation: String,
        chartImagePath: String,
        date: String
    ) -> Data? {
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792), format: format)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            var y = 72

            "QuestMe 感情傾向レポート（\(date)）"
                .draw(at: CGPoint(x: 72, y: CGFloat(y)), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
            y += 36

            if let chartImage = UIImage(contentsOfFile: chartImagePath) {
                chartImage.draw(in: CGRect(x: 72, y: CGFloat(y), width: 468, height: 240))
                y += 260
            }

            for lab in labs {
                let line = "🧪 \(lab.testName): \(lab.value)"
                line.draw(at: CGPoint(x: 72, y: CGFloat(y)), withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
                y += 24
            }

            y += 12
            for log in emotions {
                let line = "🧠 \(log.emotion.rawValue) at \(log.date.formatted())"
                line.draw(at: CGPoint(x: 72, y: CGFloat(y)), withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
                y += 24
            }

            y += 12
            for advice in advices {
                let line = "💬 \(advice["text"] ?? "")"
                line.draw(at: CGPoint(x: 72, y: CGFloat(y)), withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
                y += 24
            }

            y += 12
            "🧠 相関コメント: \(correlation)"
                .draw(at: CGPoint(x: 72, y: CGFloat(y)), withAttributes: [.font: UIFont.italicSystemFont(ofSize: 14)])
        }

        return data
    }
}
