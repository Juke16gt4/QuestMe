//
//  Assets.swift
//  QuestMe
//
//  Created by 津村淳一 on 2025/09/30
//
//  📦 目的: Assets.xcassets に登録されたカラー・画像・AppIconを型安全に扱うためのラッパー
//  📁 保管場所: Shared/Resources/
//  🧭 使用箇所: Companion UI, Onboarding, EmotionView, AppIcon表示
//

import SwiftUI
import UIKit

// MARK: - Color Assets

enum AppColor {
    static let accent = Color("AccentColor")
    static let joy = Color("EmotionJoyColor")
    static let calm = Color("EmotionCalmColor")
    static let onboardingBackground = Color("OnboardingBackground")
}

// MARK: - UIImage Assets (for UIKit)

enum AppImage {
    static let companionIcon = UIImage(named: "CompanionIcon")
    static let onboardingStar = UIImage(named: "OnboardingStar")
    static let emotionHappy = UIImage(named: "EmotionHappy")
}

// MARK: - SwiftUI Image Assets

enum AppImageView {
    static let companionIcon = Image("CompanionIcon")
    static let onboardingStar = Image("OnboardingStar")
    static let emotionHappy = Image("EmotionHappy")
}

// MARK: - AppIcon Access (Optional)

enum AppIcon {
    static let marketingIcon = UIImage(named: "Companion1024") // iOS Marketing icon
}
