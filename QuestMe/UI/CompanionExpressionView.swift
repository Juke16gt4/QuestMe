//  CompanionExpressionView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/CompanionExpressionView.swift
//
//  🎯 ファイルの目的:
//      - Companion の感情を UI 上に表現する。
//      - CompanionOverlay の状態を監視し、動的に更新する。
//      - 感情に応じたアイコン・色・ラベルを表示する。
//
//  🔗 依存ファイル:
//      - SwiftUI
//      - Overlay/CompanionOverlay.swift
//          → CompanionOverlay (ObservableObject)
//      - Models/EmotionType.swift
//          → EmotionType (Equatable, CaseIterable)
//
//  👤 作成者: Tsumura Junichi
//  🗓 作成日: 2025/10/10
//

import SwiftUI

struct CompanionExpressionView: View {
    @ObservedObject var overlay: CompanionOverlay

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: overlay.currentEmotion.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(overlay.currentEmotion.color)
                .animation(.easeInOut, value: overlay.currentEmotion)

            Text(overlay.currentEmotion.label)
                .font(.title)
                .foregroundColor(overlay.currentEmotion.color)
        }
        .padding()
    }
}
