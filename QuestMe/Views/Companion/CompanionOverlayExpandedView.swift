//
//  CompanionOverlayExpandedView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionOverlayExpandedView.swift
//
//  🎯 ファイルの目的:
//      フローティングコンパニオンの拡張ビューとして、主要アクションへの入口を提供。
//      - 栄養記録フロー(NutritionRecordView)への遷移。
//      - 摂取カロリー振り返り(CompanionCaloriesSummaryView)の起動。
//      - CompanionOverlay による音声ガイドと連携し、UXの一貫性を保つ。
//
//  🔗 依存:
//      - NutritionRecordView.swift（記録）
//      - CompanionCaloriesSummaryView.swift（振り返り）
//      - CompanionOverlay.swift（音声）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import SwiftUI

struct CompanionOverlayExpandedView: View {
    @State private var showNutrition = false
    @State private var showReview = false

    var body: some View {
        VStack(spacing: 16) {
            Text("コンパニオン")
                .font(.title3)
                .bold()

            Button {
                CompanionOverlay.shared.speak("栄養記録を始めます。撮影から進めましょう。")
                showNutrition = true
            } label: {
                Label("栄養を記録", systemImage: "fork.knife")
            }
            .buttonStyle(.borderedProminent)

            Button {
                CompanionOverlay.shared.speak("直近10日間の摂取カロリーを振り返ります。")
                showReview = true
            } label: {
                Label("振り返り（過去10日）", systemImage: "chart.bar.xaxis")
            }
            .buttonStyle(.bordered)

            Spacer(minLength: 0)
        }
        .padding()
        .sheet(isPresented: $showNutrition) {
            NutritionRecordView()
        }
        .sheet(isPresented: $showReview) {
            CompanionCaloriesSummaryView(days: 10)
        }
    }
}
