//
//  AppPickerView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Cockpit/AppPickerView.swift
//
//  🎯 ファイルの目的:
//      ユーザーが最大4件のアプリを選択し、コックピットに登録できるようにするビュー。
//      - AppRegistry.defaultApps から選択。
//      - AppIconSelectable を使用。
//
//  🔗 依存:
//      - AppRegistry.swift（保存）
//      - RegisteredApp.swift（モデル）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import SwiftUI

struct AppPickerView: View {
    @State private var selectedApps: [RegisteredApp] = []
    @State private var availableApps: [RegisteredApp] = AppRegistry.defaultApps

    var body: some View {
        VStack(spacing: 16) {
            Text("コックピットに登録するアプリを選択")
                .font(.headline)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                    ForEach(availableApps, id: \.id) { app in
                        AppIconSelectable(app: app, isSelected: selectedApps.contains(app)) {
                            toggle(app)
                        }
                    }
                }
            }

            Button("登録する") {
                AppRegistry.save(selectedApps)
            }
            .disabled(selectedApps.isEmpty)
            .padding()
        }
        .padding()
    }

    private func toggle(_ app: RegisteredApp) {
        if selectedApps.contains(app) {
            selectedApps.removeAll { $0 == app }
        } else if selectedApps.count < 4 {
            selectedApps.append(app)
        }
    }
}
