//
//  CompanionNarrationEngine.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/CompanionNarrationEngine.swift
//
//  🎯 ファイルの目的:
//      Companion が画面ごとの役割を音声で解説するためのナレーションエンジン。
//      - ScreenID に応じた説明文を生成。
//      - CompanionOverlay.shared.speak() を通じて音声再生。
//      - CompanionNavigationButton や RoleBasedNavigationMap から呼び出される。
//
//  🔗 依存:
//      - ScreenRoleGuide.swift（説明文定義）
//      - CompanionOverlay.swift（音声再生）
//      - CompanionEmotion.swift（語り口調）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月6日

import Foundation
