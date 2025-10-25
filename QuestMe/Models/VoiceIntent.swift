//
//  VoiceIntent.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/VoiceIntent.swift
//
//  🎯 ファイルの目的:
//      音声入力から抽出された意図を表現するモデル。
//      - Action（update, delete, add, read）を保持。
//      - entity, field, value を持ち、編集対象を特定する。
//      - VoiceIntentRouter や EditSessionManager から利用される。
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import Foundation

public struct VoiceIntent {
    public enum Action { case update, delete, add, read }
    public let action: Action
    public let entity: String
    public let field: String?
    public let value: String?

    public init(action: Action, entity: String, field: String? = nil, value: String? = nil) {
        self.action = action
        self.entity = entity
        self.field = field
        self.value = value
    }
}
