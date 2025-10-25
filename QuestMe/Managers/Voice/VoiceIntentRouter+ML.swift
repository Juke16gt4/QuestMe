//
//  VoiceIntentRouter+ML.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/Voice/VoiceIntentRouter+ML.swift
//
//  🎯 ファイルの目的:
//      - 音声認識結果を解析し、意図(Intent)を分類。
//      - 感情ログ(EmotionLog)を Core Data に直接保存。
//      - MLモデルによる分類結果を反映。
//      - ReflectionService や EmotionReviewView と連動。
//
//  🔗 依存:
//      - CoreData
//      - EmotionLog.swift（Core Data モデル）
//      - EmotionType.swift（感情分類）
//      - PersistenceController.swift（Core Data スタック）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月17日
//

import Foundation
import CoreData
import Speech

final class VoiceIntentRouterML {
    static let shared = VoiceIntentRouterML()
    private init() {}

    private let context = PersistenceController.shared.container.viewContext

    /// 音声認識結果を解析し、EmotionLog として保存
    func handleTranscript(_ transcript: String) {
        // MLモデルで感情分類（ここは仮実装）
        let detectedEmotion: EmotionType = classifyEmotion(from: transcript)

        // Core Data に保存
        let log = EmotionLog(context: context)
        log.uuid = UUID().uuidString
        log.timestamp = Date()
        log.text = transcript
        log.emotion = detectedEmotion.rawValue
        log.ritual = "VoiceIntentRouter"
        log.metadata = nil

        do {
            try context.save()
            print("✅ EmotionLog 保存成功: \(log.text)")
        } catch {
            print("❌ EmotionLog 保存失敗: \(error)")
        }
    }

    /// MLモデルによる感情分類（ダミー実装）
    private func classifyEmotion(from text: String) -> EmotionType {
        if text.contains("楽しい") || text.contains("嬉しい") {
            return .happy
        } else if text.contains("悲しい") {
            return .sad
        } else if text.contains("怒") {
            return .angry
        } else {
            return .neutral
        }
    }
}
