//
//  ExpandedCompanionView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/ExpandedCompanionView.swift
//
//  🎯 ファイルの目的:
//      フローティング状態から拡張された際の UI を構築するビュー。
//      - Companion画像・健康管理ボタン・設定群・Cockpit を表示。
//      - CompanionImageInsertView や CockpitView と連携。
//
//  🔗 依存:
//      - CompanionImageInsertView.swift（画像）
//      - CockpitView.swift（アプリ）
//      - HealthButton.swift / ActionButton.swift（操作）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import SwiftUI

struct ExpandedCompanionView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var registeredApps: [RegisteredApp] = AppRegistry.load()

    var body: some View {
        VStack(spacing: 0) {
            CockpitView(apps: registeredApps)
                .frame(height: UIScreen.main.bounds.height / 6)

            CompanionImageInsertView(selectedCompanionImage: $selectedImage)

            Spacer()

            HStack(spacing: 16) {
                HealthButton(icon: "pills", label: "おくすり")
                HealthButton(icon: "leaf", label: "栄養")
                HealthButton(icon: "figure.walk", label: "運動")
            }
            .padding(.bottom, 12)

            HStack(spacing: 16) {
                ActionButton(icon: "person.crop.circle", label: "プロファイル")
                ActionButton(icon: "sparkles", label: "コンパニオン")
                ActionButton(icon: "gearshape", label: "設定")
            }
            .frame(height: UIScreen.main.bounds.height * 0.25)
            .background(Color.secondary.opacity(0.1))
        }
    }
}
