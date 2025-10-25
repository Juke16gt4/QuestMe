//
//  ConversationManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/ConversationManager.swift
//
//  🎯 ファイルの目的:
//      Companion とユーザーの会話履歴を管理するベースクラス。
//      - 会話内容の保存・取得・分析に対応予定。
//      - Append-only の ConversationLog.sqlite3 に保存する構造に拡張可能。
//      - CompanionAdviceView や EditSessionManager から呼び出される予定。
//
//  🔗 依存:
//      - SQLite3（予定）
//      - CompanionOverlay.swift（音声連携）
//      - EditSessionManager.swift（会話記録）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import Foundation
