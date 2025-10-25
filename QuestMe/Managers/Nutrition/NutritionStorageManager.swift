//
//  NutritionStorageManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/Nutrition/NutritionStorageManager.swift
//
//  🎯 ファイルの目的:
//      食事記録の統一保存窓口。
//      - CoreData保存（MealEntity）
//      - SQL保存（AdviceLogManagerなど拡張ポイント）
//      - JSON保存（Calendar/年/月/食事_栄養/yyyyMMdd_index.json）
//      ファイル名ルール: yyyyMMdd_index（例: 20251018_1）
//
//  👤 製作者: 津村 淳一
//  📅 作成日: 2025年10月18日
//

import Foundation
import CoreData
import UIKit

final class NutritionStorageManager {
    static let shared = NutritionStorageManager()
    private init() {}

    func saveMeal(_ record: MealRecord) {
        saveCoreData(record)
        saveJSON(record)
        saveSQL(record)
    }

    // MARK: - CoreData保存
    private func saveCoreData(_ record: MealRecord) {
        let context = PersistenceController.shared.container.viewContext
        let entity = MealEntity(context: context)
        entity.id = UUID()
        entity.date = record.date
        entity.mealType = record.mealType
        entity.userInput = record.userInput
        entity.calories = record.calories
        entity.protein = record.protein
        entity.fat = record.fat
        entity.carbs = record.carbs

        if let img = record.compressedImage,
           let path = saveImageToCalendar(img: img, date: record.date) {
            entity.imagePath = path
        }

        do { try context.save() } catch {
            print("❌ CoreData保存失敗: \(error.localizedDescription)")
        }
    }

    // MARK: - JSON保存（Calendar/年/月/食事_栄養/yyyyMMdd_index.json）
    private func saveJSON(_ record: MealRecord) {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let year = Calendar.current.component(.year, from: record.date)
        let month = Calendar.current.component(.month, from: record.date)
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyyMMdd"
        let dayStr = dayFormatter.string(from: record.date)

        let folder = docs.appendingPathComponent("Calendar/\(year)年/\(month)月/食事_栄養")
        try? fm.createDirectory(at: folder, withIntermediateDirectories: true)

        let existing = (try? fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
        let sameDay = existing.filter { $0.lastPathComponent.hasPrefix(dayStr + "_") }
        let index = (sameDay.count + 1)
        let filename = "\(dayStr)_\(index).json"

        let fileURL = folder.appendingPathComponent(filename)
        let payload: [String: Any] = [
            "mealType": record.mealType,
            "userInput": record.userInput,
            "calories": record.calories,
            "protein": record.protein,
            "fat": record.fat,
            "carbs": record.carbs,
            "date": ISO8601DateFormatter().string(from: record.date)
        ]
        do {
            let data = try JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted])
            try data.write(to: fileURL)
        } catch {
            print("❌ JSON保存失敗: \(error.localizedDescription)")
        }
    }

    // MARK: - SQL保存（拡張ポイント）
    private func saveSQL(_ record: MealRecord) {
        // 例: AdviceLogManager などにINSERT（仕様に合わせて拡張）
        // AdviceLogManager().insertAdvice(userId: uid, medicationName: "NutritionRecord", advice: "cal:\(record.calories)")
    }

    // MARK: - 画像のCalendar保存（同階層にJPEG）
    private func saveImageToCalendar(img: UIImage, date: Date) -> String? {
        guard let data = img.jpegData(compressionQuality: 0.85) else { return nil }
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyyMMdd"
        let dayStr = dayFormatter.string(from: date)
        let folder = docs.appendingPathComponent("Calendar/\(year)年/\(month)月/食事_栄養")
        try? fm.createDirectory(at: folder, withIntermediateDirectories: true)

        // インデックスはJSON保存と揃えるため、既存件数から推定
        let existing = (try? fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
        let sameDay = existing.filter { $0.lastPathComponent.hasPrefix(dayStr + "_") && $0.pathExtension == "json" }
        let index = (sameDay.count + 1)
        let filename = "\(dayStr)_\(index).jpg"
        let url = folder.appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return url.path
        } catch {
            print("❌ 画像保存失敗: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - CoreDataスタック（簡潔だが完全）
final class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    private init() {
        container = NSPersistentContainer(name: "QuestMe")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ Persistent store load error: \(error)")
            }
        }
    }
}

// MARK: - MealEntity（CoreDataモデル）
@objc(MealEntity)
class MealEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var date: Date
    @NSManaged var mealType: String
    @NSManaged var userInput: String
    @NSManaged var calories: Double
    @NSManaged var protein: Double
    @NSManaged var fat: Double
    @NSManaged var carbs: Double
    @NSManaged var imagePath: String?
}

extension MealEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MealEntity> {
        NSFetchRequest<MealEntity>(entityName: "MealEntity")
    }
}
