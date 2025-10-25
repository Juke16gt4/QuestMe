//
//  ImageCompressor.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Utils/ImageCompressor.swift
//
//  🎯 ファイルの目的:
//      画像を目標サイズ（KB）に近づける圧縮ユーティリティ
//
//  🔗 連動:
//      - NutritionCameraRecordView.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-23 13:20 JST
//

import UIKit

func compressToTarget(image: UIImage, targetKB: Int) -> UIImage {
    let maxLongSide: CGFloat = 1600
    let ratio = max(image.size.width, image.size.height) / maxLongSide
    let targetSize = ratio > 1 ? CGSize(width: image.size.width/ratio, height: image.size.height/ratio) : image.size

    UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
    image.draw(in: CGRect(origin: .zero, size: targetSize))
    let resized = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    let base: UIImage
    if let r = resized {
        base = r
    } else if let cg = image.cgImage {
        base = UIImage(cgImage: cg)
    } else {
        base = image
    }

    var quality: CGFloat = 0.6
    var data = base.jpegData(compressionQuality: quality) ?? Data()
    let targetBytes = targetKB * 1024
    var tries = 0
    while data.count > targetBytes && tries < 5 {
        quality -= 0.1
        data = base.jpegData(compressionQuality: max(quality, 0.3)) ?? data
        tries += 1
    }
    return UIImage(data: data) ?? base
}
