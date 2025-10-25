//
//  RoleBasedNavigationMap.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/RoleBasedNavigationMap.swift
//
//  🎯 ファイルの目的:
//      Companion の役割別に画面を案内するメニュー構造。
//      - 各役割（初期設定、記憶の書、日記、アドバイス）に対応するボタンを表示。
//      - CompanionNarrationEngine による音声解説と連動。
//      - CompanionNavigationButton から呼び出される。
//
//  🔗 依存:
//      - CompanionNarrationEngine.swift（音声解説）
//      - ScreenRegistry.swift（画面遷移）
//      - ScreenRoleGuide.swift（役割文言）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月6日

import Foundation
