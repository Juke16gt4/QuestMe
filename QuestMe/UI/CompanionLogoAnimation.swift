//
//  CompanionLogoAnimation.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/CompanionLogoAnimation.swift
//
//  🎯 ファイルの目的:
//      音声入力や感情レベルに応じて、ロゴをアニメーションさせる演出ビュー。
//      - emotionLevel に応じてサイズ・影・動きが変化。
//      - CompanionOverlayExpandedView や GreetingView などで使用可能。
//      - 共鳴感・感情の可視化を担う。
//
//  🔗 依存:
//      - SwiftUI（アニメーション・UI構造）
//      - emotionLevel（感情強度）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月30日

import SwiftUI

public struct CompanionLogoAnimation: View {
    public let emotionLevel: CGFloat

    public var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 100 + emotionLevel, height: 100 + emotionLevel)
            .shadow(radius: emotionLevel / 5)
            .animation(.easeInOut(duration: 0.3), value: emotionLevel)
    }
}
