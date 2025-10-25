//
//  PDFRenderer.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Utilities/PDFRenderer.swift
//
//  🎯 ファイルの目的:
//      シンプルなテキスト→PDF化ユーティリティ（日本語対応・複数ページ分割）。
//      - 余白つきのレイアウトで、CoreText を用いて自動改ページします。
//      - 本番ではヘッダー/フッター、フォント、行間、装飾などの拡張を推奨。
//
//  👤 製作者: 津村 淳一
//  📅 改変日: 2025年10月8日
//

import UIKit
import CoreText

struct PDFRenderer {

    /// テキストを PDF にレンダリングして指定 URL に保存
    /// - Parameters:
    ///   - text: 出力する本文（UTF-8）
    ///   - url: 保存先 URL（例: Documents/.../minutes.pdf）
    ///   - title: 先頭ページに表示するタイトル（任意）
    ///   - pageSize: PDF ページサイズ（既定: A4）
    ///   - margins: ページ余白（既定: 36pt 各辺）
    func render(
        text: String,
        to url: URL,
        title: String? = "議事録",
        pageSize: CGSize = CGSize(width: 595.2, height: 841.8), // A4: 72dpi換算
        margins: UIEdgeInsets = UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36)
    ) {
        // 文字属性（日本語対応フォント）
        let baseFont = UIFont.systemFont(ofSize: 12)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.minimumLineHeight = 16
        paragraphStyle.maximumLineHeight = 16

        let attributes: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .paragraphStyle: paragraphStyle
        ]

        // タイトルの属性
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .paragraphStyle: {
                let ps = NSMutableParagraphStyle()
                ps.alignment = .center
                ps.lineBreakMode = .byWordWrapping
                return ps
            }()
        ]

        // 余白を引いた描画領域
        let contentRect = CGRect(
            x: margins.left,
            y: margins.top,
            width: pageSize.width - margins.left - margins.right,
            height: pageSize.height - margins.top - margins.bottom
        )

        // PDF レンダラー準備
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)

        // 本文（タイトル行 + 本文）をページ分割して描画
        let data = renderer.pdfData { ctx in
            let fullText = NSMutableAttributedString()

            // タイトル（任意）
            if let title = title, !title.isEmpty {
                let titleString = NSAttributedString(string: title + "\n\n", attributes: titleAttrs)
                fullText.append(titleString)
            }

            // 本文
            let bodyString = NSAttributedString(string: text, attributes: attributes)
            fullText.append(bodyString)

            // CoreText のフレームセッターで改ページ
            let framesetter = CTFramesetterCreateWithAttributedString(fullText as CFAttributedString)
            var currentRange = CFRange(location: 0, length: 0)
            let textLength = CFAttributedStringGetLength(fullText as CFAttributedString)

            while currentRange.location < textLength {
                ctx.beginPage()

                // ページ内の描画パス（余白つき矩形）
                let path = CGMutablePath()
                path.addRect(contentRect)

                // ページに収まる範囲を取得
                let frame = CTFramesetterCreateFrame(framesetter, currentRange, path, nil)
                let frameRange = CTFrameGetVisibleStringRange(frame)

                // CoreText で描画（UIKit座標とCoreGraphics座標の違いに注意）
                if let cgContext = UIGraphicsGetCurrentContext() {
                    cgContext.saveGState()
                    cgContext.textMatrix = .identity
                    // UIKit は左上原点、CoreText は左下原点 → 座標系を反転して合わせる
                    cgContext.translateBy(x: 0, y: pageSize.height)
                    cgContext.scaleBy(x: 1.0, y: -1.0)
                    CTFrameDraw(frame, cgContext)
                    cgContext.restoreGState()
                }

                // 次ページの開始位置へ更新
                currentRange = CFRange(
                    location: currentRange.location + frameRange.length,
                    length: 0
                )
            }
        }

        // 保存
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            print("PDF 保存に失敗しました: \(error.localizedDescription)")
        }
    }
}
