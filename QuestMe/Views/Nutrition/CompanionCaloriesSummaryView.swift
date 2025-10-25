//
//  CompanionCaloriesSummaryView.swift
//  QuestMe
//
//  Created by 津村淳一 on 2025/10/05.
//

/**
 CompanionCaloriesSummaryView
 ----------------------------
 目的:
 - ユーザーが指定した過去日数の摂取カロリーを集計し、Companion が吹き出し＋音声＋感情で案内する。
 - CompanionOverlay.speakForReview(total:days:) を呼び出し、結果に応じた感情表現を行う。
 
 格納先:
 - Swiftファイル: Views/Nutrition/CompanionCaloriesSummaryView.swift
*/

import SwiftUI

struct CompanionCaloriesSummaryView: View {
    let days: Int
    @State private var totalCalories: Double = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("過去\(days)日間の摂取カロリー")
                .font(.headline)

            Text("\(Int(totalCalories)) kcal")
                .font(.largeTitle)
                .bold()

            CompanionSpeechBubbleView() // 吹き出しUIを常時表示

            Spacer()
        }
        .padding()
        .onAppear {
            totalCalories = NutritionStorageManager.shared.getCalories(forDays: days)
            CompanionOverlay.shared.speakForReview(total: totalCalories, days: days)
        }
    }
}
