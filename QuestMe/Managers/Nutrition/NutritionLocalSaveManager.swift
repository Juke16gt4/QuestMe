//
//  NutritionLocalSaveManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/Nutrition/NutritionLocalSaveManager.swift
//
//  🎯 目的:
//      撮影画像と栄養情報JSONを同名で Calendar フォルダに保存。
//      - フォーマット: Calendar/年/月/食事_栄養/yyyyMMdd_index.(jpg|json)
//
//  🔗 関連/連動:
//      - NutrientDetail.swift（栄養素モデル）
//      - NutritionCameraRecordView.swift（撮影時に呼び出し）
//      - NutritionDetailView.swift（表示時に読み込み）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月20日（完全保存版）

import Foundation
import UIKit

public struct NutritionSnapshotPayload: Codable {
    public let mealType: String
    public let userInput: String
    public let ingredients: [String]
    public let totalNutrients: [String: NutrientDetail]
    public let sourceURL: String?
}

final class NutritionLocalSaveManager {
    static let shared = NutritionLocalSaveManager()
    private init() {}

    /// 画像とJSONを同名で保存
    func saveImageAndJSON(processedImage: UIImage,
                          mealType: String,
                          userInput: String,
                          ingredients: [String],
                          totalNutrients: [String: NutrientDetail],
                          date: Date = Date()) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = String(format: "%02d", calendar.component(.month, from: date))
        let day = String(format: "%02d", calendar.component(.day, from: date))

        let folderURL = getCalendarFolder(year: year, month: month)
        createFolderIfNeeded(at: folderURL)

        let baseName = "\(year)\(month)\(day)"
        let index = nextAvailableIndex(for: folderURL, baseName: baseName)
        let filename = "\(baseName)_\(index)"

        let imagePath = folderURL.appendingPathComponent("\(filename).jpg")
        let jsonPath = folderURL.appendingPathComponent("\(filename).json")

        // 保存処理
        do {
            let imageData = processedImage.jpegData(compressionQuality: 1.0)
            try imageData?.write(to: imagePath)

            let payload = NutritionSnapshotPayload(
                mealType: mealType,
                userInput: userInput,
                ingredients: ingredients,
                totalNutrients: totalNutrients,
                sourceURL: nil
            )
            let jsonData = try JSONEncoder().encode(payload)
            try jsonData.write(to: jsonPath)

        } catch {
            CompanionOverlay.shared.speak("保存に失敗しました。ストレージを確認してください。")
        }
    }

    // MARK: - 保存先フォルダ生成
    private func getCalendarFolder(year: Int, month: String) -> URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent("Calendar/\(year)/\(month)/食事_栄養")
    }

    private func createFolderIfNeeded(at url: URL) {
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    // MARK: - 連番インデックス取得
    private func nextAvailableIndex(for folder: URL, baseName: String) -> Int {
        let files = (try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? []
        let existingIndices = files.compactMap { file -> Int? in
            guard file.hasPrefix(baseName), let num = file.split(separator: "_").last?.split(separator: ".").first else { return nil }
            return Int(num)
        }
        return (existingIndices.max() ?? 0) + 1
    }
}
