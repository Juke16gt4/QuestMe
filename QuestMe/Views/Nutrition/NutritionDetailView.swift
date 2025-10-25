//
//  NutritionDetailView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Nutrition/NutritionDetailView.swift
//
//  🎯 目的:
//      NutritionLocalSaveManager で保存された栄養情報JSONを読み込み、構造的に表示する儀式ビュー。
//      - 栄養素名・量・単位を明示的に表示
//      - 12言語対応
//      - CompanionOverlay.shared による音声案内（任意）
//      - 保存形式: NutritionSnapshotPayload
//
//  🔗 関連:
//      - NutrientDetail.swift（栄養素構造）
//      - NutritionLocalSaveManager.swift（保存）
//      - NutritionSnapshotPayload（表示対象）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月20日

import SwiftUI

struct NutritionDetailView: View {
    @AppStorage("selectedLanguageCode") private var langCode: String = "ja"
    let payload: NutritionSnapshotPayload

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text(localized("mealType"))) {
                    Text(payload.mealType)
                    Text(payload.userInput)
                }

                Section(header: Text(localized("nutrients"))) {
                    ForEach(payload.totalNutrients.sorted(by: { $0.key < $1.key }), id: \.key) { key, detail in
                        HStack {
                            Text("🍽 \(localized(detail.label))")
                            Spacer()
                            Text("\(detail.quantity, specifier: "%.1f") \(detail.unit)")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if let url = payload.sourceURL {
                    Section(header: Text(localized("source"))) {
                        Text(url)
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle(localized("nutritionTitle"))
            .onAppear {
                CompanionOverlay.shared.speak(localized("nutritionIntro"))
            }
        }
    }

    private func localized(_ key: String) -> String {
        switch (key, langCode) {
        case ("nutritionTitle", "ja"): return "栄養詳細"
        case ("nutritionIntro", "ja"): return "この食事に含まれる栄養素を表示します。"
        case ("mealType", "ja"): return "食事情報"
        case ("nutrients", "ja"): return "栄養素一覧"
        case ("source", "ja"): return "出典URL"
        case ("カロリー", "ja"): return "カロリー"
        case ("たんぱく質", "ja"): return "たんぱく質"
        case ("脂質", "ja"): return "脂質"
        case ("炭水化物", "ja"): return "炭水化物"

        case ("nutritionTitle", "en"): return "Nutrition Details"
        case ("nutritionIntro", "en"): return "Displaying nutrients contained in this meal."
        case ("mealType", "en"): return "Meal Info"
        case ("nutrients", "en"): return "Nutrient List"
        case ("source", "en"): return "Source URL"
        case ("カロリー", "en"): return "Calories"
        case ("たんぱく質", "en"): return "Protein"
        case ("脂質", "en"): return "Fat"
        case ("炭水化物", "en"): return "Carbohydrates"

        default: return key
        }
    }
}
