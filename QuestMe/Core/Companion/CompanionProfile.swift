//
//  CompanionProfile.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Companion/CompanionProfile.swift
//
//  🎯 ファイルの目的:
//      コンパニオンのプロフィール構造（名前・声・AIエンジン・アバター・役割）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月15日

import Foundation

public struct CompanionProfile: Codable {
    public var name: String
    public var avatar: Avatar
    public var voice: VoiceProfile
    public var aiEngine: AIEngine
    public var role: CompanionAvatar

    public init(name: String, avatar: Avatar, voice: VoiceProfile, aiEngine: AIEngine, role: CompanionAvatar) {
        self.name = name
        self.avatar = avatar
        self.voice = voice
        self.aiEngine = aiEngine
        self.role = role
    }
}
