//
//  VoiceProfile.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Voice/VoiceProfile.swift
//
//  🎯 ファイルの目的:
//      コンパニオンの声の性格（スタイル/トーン/速度）を唯一の正として定義。
//      - CompanionProfile に保存される音声属性。
//      - 推定ロジックは拡張ファイルへ分離し、モデルの純度を維持する。
//
//  🔗 依存/連動:
//      - CompanionProfile.swift（参照）
//      - VoiceProfile+Inference.swift（推定ロジック拡張）
//      - CompanionSetupView.swift（inferred(from:)の利用）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月15日
//

import Foundation

public enum VoiceStyle: String, Codable, CaseIterable, Hashable {
    case calm      = "落ち着いた"
    case energetic = "元気"
    case gentle    = "優しい"
    case lively    = "軽快"
    case sexy      = "セクシー"
}

public enum VoiceTone: String, Codable, CaseIterable, Hashable {
    case neutral = "ノーマル"
    case husky   = "ハスキー"
    case bright  = "高め"
    case deep    = "低め"
}

public enum VoiceSpeed: String, Codable, CaseIterable, Hashable {
    case slow   = "ゆっくり"
    case normal = "普通"
    case fast   = "速い"
}

public struct VoiceProfile: Codable, Equatable, Hashable {
    public var style: VoiceStyle
    public var tone: VoiceTone
    public var speed: VoiceSpeed

    public init(style: VoiceStyle, tone: VoiceTone, speed: VoiceSpeed = .normal) {
        self.style = style
        self.tone = tone
        self.speed = speed
    }
}
