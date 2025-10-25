//
//  QRCodeView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Shared/QRCodeView.swift
//
//  🎯 ファイルの目的:
//      共有用テキスト（JSONなど）をQRコードとして表示するビュー。
//      - SharedEventView.swift から起動。
//      - 家族・医師・介護者との共有を想定。
//      - QRコードは画像として保存可能（後日拡張）。
//
//  🔗 依存:
//      - CoreImage.CIFilter
//      - SwiftUI.Image
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月9日

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let content: String
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        VStack(spacing: 24) {
            Text("📷 QRコード")
                .font(.title2)
                .bold()

            if let image = generateQRCode(from: content) {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
                    .padding()
            } else {
                Text("QRコード生成に失敗しました")
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
    }

    func generateQRCode(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)
        if let outputImage = filter.outputImage,
           let cgimg = context.createCGImage(outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10)), from: outputImage.extent) {
            return UIImage(cgImage: cgimg)
        }
        return nil
    }
}
