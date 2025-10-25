//
//  NutritionMainView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Nutrition/NutritionMainView.swift
//
//  🎯 ファイルの目的:
//      「🥗 栄養・食事」ボタンから呼び出される統合ビュー。
//      - 記録（NutritionRecordView）
//      - 振り返り（CompanionCaloriesSummaryView）
//      - アドバイス（HealthAdviceView）
//      をタブで切り替え可能にし、食事関連の一連フローをまとめる。
//
//  🔗 依存:
//      - NutritionRecordView.swift
//      - CompanionCaloriesSummaryView.swift
//      - HealthAdviceView.swift
//      - CompanionOverlay.swift（音声ガイド）
//
//  👤 製作者: 津村 淳一
//  📅 作成日: 2025年10月18日
//

import SwiftUI

struct NutritionMainView: View {
    var body: some View {
        TabView {
            // 記録
            NutritionRecordView()
                .tabItem {
                    Label("記録", systemImage: "camera")
                }

            // 振り返り
            CompanionCaloriesSummaryView(days: 10)
                .tabItem {
                    Label("振り返り", systemImage: "chart.bar")
                }

            // アドバイス
            HealthAdviceView()
                .tabItem {
                    Label("アドバイス", systemImage: "heart.text.square")
                }
        }
        .onAppear {
            CompanionOverlay.shared.speak("栄養の記録、振り返り、アドバイスをまとめて表示します。")
        }
    }
}
