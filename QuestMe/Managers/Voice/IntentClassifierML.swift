//
//  IntentClassifierML.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/Voice/IntentClassifierML.swift
//
//  🎯 ファイルの目的:
//      音声コマンド文字列を Core ML で分類し、VoiceIntent を返す。
//      - IntentClassifier プロトコルの ML 実装。
//      - モデル出力を Action/Entity/Field/Value にマッピング。
//
//  🔗 依存:
//      - Protocols/MLAdvisor.swift
//      - Services/ML/ModelRegistry.swift
//      - Models/VoiceIntent.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import Foundation
import CoreML

final class IntentClassifierML: IntentClassifier {
    private let fallbackResolver = ActionResolver()

    func classify(command: String) -> VoiceIntent {
        guard let model = ModelRegistry.shared.intentModel else {
            return fallbackResolver.resolve(from: command)
        }
        let provider = try? MLDictionaryFeatureProvider(dictionary: ["command": command])
        guard let input = provider,
              let out = try? model.prediction(from: input) else {
            return fallbackResolver.resolve(from: command)
        }

        let actionStr = out.featureValue(for: "action")?.stringValue ?? "read"
        let entity = out.featureValue(for: "entity")?.stringValue ?? "UserProfile"
        let field = out.featureValue(for: "field")?.stringValue
        let value = out.featureValue(for: "value")?.stringValue

        let action: VoiceIntent.Action
        switch actionStr {
        case "update": action = .update
        case "delete": action = .delete
        case "add":    action = .add
        default:       action = .read
        }
        return VoiceIntent(action: action, entity: entity, field: field, value: value)
    }
}
