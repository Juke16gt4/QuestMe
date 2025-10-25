//
//  Companion.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Companion/Companion.swift
//
//  🎯 ファイルの目的:
//      CompanionProfile に準拠した軽量モデル。
//      - 登録・再登録時の一時保持に使用され、UIや設定フローで活用される。
//      - CompanionAvatar（ロール）と AIEngine を参照し、個性と機能を定義。
//      - speakerID は VOICEVOX 話者IDなどの外部音声識別に使用可能。
//
//  🔗 依存:
//      - CompanionAvatar（from CompanionProfile.swift）
//      - AIEngine.swift（拡張定義済み）
//      - CompanionRegistry.swift（登録管理）
//      - CompanionSetupView.swift（初期設定）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月3日

import Foundation

public struct Companion: Identifiable, Codable, Equatable, Hashable {
    public var id = UUID()
    public var name: String
    public var personality: String
    public var speakerID: String?
    // CompanionProfile.swift に準拠して、Avatar は「ロール」＝ CompanionAvatar を使用
    public var avatar: CompanionAvatar
    // AIエンジンは再定義せず、CompanionProfile.swift の AIEngine を参照
    public var aiEngine: AIEngine
}
