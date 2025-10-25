//
//  CockpitView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Cockpit/CockpitView.swift
//
//  🎯 ファイルの目的:
//      登録された最大4件のアプリを表示し、タップで即起動できるビュー。
//      - RegisteredApp を表示。
//      - UIApplication.shared.open により起動。
//
//  🔗 依存:
//      - RegisteredApp.swift（モデル）
//      - AppRegistry.swift（保存）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import SwiftUI

struct CockpitView: View {
    let apps: [RegisteredApp]

    var body: some View {
        HStack(spacing: 16) {
            ForEach(apps.prefix(4), id: \.id) { app in
                Button(action: {
                    UIApplication.shared.open(app.url)
                }) {
                    VStack {
                        Image(uiImage: app.icon)
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text(app.name)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
    }
}
