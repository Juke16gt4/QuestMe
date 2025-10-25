//
//  AICharacterSelectionView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/AICharacterSelectionView.swift
//
//  🎯 ファイルの目的:
//      Companion のアバターを選択するための UI ビュー。
//      - ProfileCreationFlow から @Binding で選択結果を受け取る。
//      - CompanionAvatar.allCases に準拠。
//
//  🔗 依存:
//      - CompanionAvatar.swift（アバター定義）
//      - ProfileCreationFlow.swift（呼び出し元）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import SwiftUI

struct AICharacterSelectionView: View {
    @Binding var selectedAvatar: CompanionAvatar?

    var body: some View {
        VStack {
            Text("コンパニオンを選んでください").font(.title2)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(CompanionAvatar.allCases) { avatar in
                    Button {
                        selectedAvatar = avatar
                    } label: {
                        Text(avatar.rawValue)
                            .padding()
                            .background(selectedAvatar == avatar ? Color.blue : Color.gray.opacity(0.3))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}
