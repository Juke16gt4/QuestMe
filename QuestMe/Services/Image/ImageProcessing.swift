//
//  ImageProcessing.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/Nutrition/ImageProcessing.swift
//
//  🎯 目的:
//      - 撮影画像を最大1600pxにリサイズ
//      - JPEG圧縮で目標KBに近づける
//      - 栄養推定（CoreMLまたはダミー）
//      - NutritionLocalSaveManager に渡す形式に整形
//
//  🔗 関連:
//      - NutritionCameraRecordView.swift（撮影後に呼び出し）
//      - NutritionLocalSaveManager.swift（保存）
//      - ModelRegistry.swift（推定モデル）
//      - NutrientDetail.swift（栄養素構造）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月20日（再構成版）

import UIKit

struct ImageProcessing {
    
    /// 最大1600pxにリサイズ
    static func resize(image: UIImage, maxLongSide: CGFloat = 1600) -> UIImage {
        let ratio = max(image.size.width, image.size.height) / maxLongSide
        let targetSize = ratio > 1 ? CGSize(width: image.size.width / ratio, height: image.size.height / ratio) : image.size

        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized ?? image
    }

    /// JPEG圧縮で目標KBに近づける（段階的）
    static func compress(image: UIImage, targetKB: Int = 300) -> Data {
        var quality: CGFloat = 0.6
        var data = image.jpegData(compressionQuality: quality) ?? Data()
        let targetBytes = targetKB * 1024
        var tries = 0

        while data.count > targetBytes && tries < 5 {
            quality -= 0.1
            data = image.jpegData(compressionQuality: max(quality, 0.3)) ?? data
            tries += 1
        }

        return data
    }

    /// 栄養推定（ダミー or CoreML）
    static func estimateNutrition(from image: UIImage) -> (calories: Double, protein: Double, fat: Double, carbs: Double) {
        // 実運用では ModelRegistry.shared.predict(image) に接続
        return (calories: 520, protein: 20, fat: 15, carbs: 60)
    }

    /// NutritionSnapshotPayload に変換
    static func generatePayload(mealType: String,
                                userInput: String,
                                ingredients: [String],
                                image: UIImage,
                                sourceURL: String? = nil) -> (payload: NutritionSnapshotPayload, compressedImage: UIImage) {

        let resized = resize(image: image)
        let compressedData = compress(image: resized)
        let compressedImage = UIImage(data: compressedData) ?? resized

        let nutrients = estimateNutrition(from: compressedImage)
        let nutrientDetails: [String: NutrientDetail] = [
            "calories": NutrientDetail(name: "カロリー", value: nutrients.calories, unit: "kcal"),
            "protein": NutrientDetail(name: "たんぱく質", value: nutrients.protein, unit: "g"),
            "fat": NutrientDetail(name: "脂質", value: nutrients.fat, unit: "g"),
            "carbs": NutrientDetail(name: "炭水化物", value: nutrients.carbs, unit: "g")
        ]

        let payload = NutritionSnapshotPayload(
            mealType: mealType,
            userInput: userInput,
            ingredients: ingredients,
            totalNutrients: nutrientDetails,
            sourceURL: sourceURL
        )

        return (payload, compressedImage)
    }
}
