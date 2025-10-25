//
//  CompanionImageInsertView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionImageInsertView.swift
//
//  🎯 ファイルの目的:
//      楕円形の枠に選択されたコンパニオン画像を表示するビュー。
//      - ユーザーの象徴として配置。
//      - CompanionSetupView や ExpandedCompanionView で使用。
//
//  🔗 依存:
//      - UIImage（画像）
//      - CompanionProfile.swift（画像保持）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import SwiftUI

struct CompanionImageInsertView: View {
    @Binding var selectedCompanionImage: UIImage?

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.secondary.opacity(0.1))
                .frame(width: 180, height: 220)
                .overlay(
                    Ellipse().stroke(Color.gray, lineWidth: 2)
                )

            if let image = selectedCompanionImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 180, height: 220)
                    .clipShape(Ellipse())
            } else {
                Text("未選択")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}
