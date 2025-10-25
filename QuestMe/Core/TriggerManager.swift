//
//  TriggerManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/TriggerManager.swift
//
//  🎯 ファイルの目的:
//      インテリジェントトリガー管理。
//      - 朝/夜/無会話/トピック再来を検知。
//      - ReflectionService に振り返りを発動させる。
//
//  🔗 依存:
//      - Models.swift
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

enum ReflectionTrigger {
    case morningGreeting
    case eveningReflection
    case inactivity(minutes: Int)
    case topicRevisited(ConversationTopic)
}

final class TriggerManager {
    private var lastInteraction: Date = Date()
    private var topicHistory: [ConversationTopic: Date] = [:]

    func markInteraction(topic: ConversationTopic?) {
        lastInteraction = Date()
        if let t = topic {
            topicHistory[t] = Date()
        }
    }

    func shouldFire(_ trigger: ReflectionTrigger) -> Bool {
        switch trigger {
        case .morningGreeting:
            let hour = Calendar.current.component(.hour, from: Date())
            return hour >= 6 && hour <= 9
        case .eveningReflection:
            let hour = Calendar.current.component(.hour, from: Date())
            return hour >= 21 && hour <= 23
        case .inactivity(let minutes):
            let diff = Date().timeIntervalSince(lastInteraction) / 60.0
            return diff >= Double(minutes)
        case .topicRevisited(let topic):
            if let last = topicHistory[topic] {
                let diff = Date().timeIntervalSince(last) / 3600.0
                return diff >= 24
            }
            return false
        }
    }
}
