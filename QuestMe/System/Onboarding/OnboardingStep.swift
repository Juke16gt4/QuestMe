//
//  OnboardingStep.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/System/Onboarding/OnboardingStep.swift
//
//  🎯 ファイルの目的:
//      オンボーディングの進行状態を定義する列挙型。
//      - ContentView から参照され、画面遷移の制御に使用。
//      - 今後は状態保存や復帰処理にも活用予定。
//
//  🔗 依存:
//      - ContentView.swift（状態参照）
//      - LanguageSetupView.swift / AgreementView.swift / VoiceprintRegistrationView.swift（各ステップ）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月2日

import Foundation

enum OnboardingStep {
    case languageSelection
    case agreement
    case voiceprintRegistration
    case companionSession
}
