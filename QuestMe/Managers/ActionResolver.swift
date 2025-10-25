//
//  ActionResolver.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/ActionResolver.swift
//
//  🎯 ファイルの目的:
//      ユーザーの音声コマンド文字列を解析し、VoiceIntent に変換する。
//      - Apple の NaturalLanguage フレームワークを利用し、品詞・固有表現を抽出。
//      - キーワードベースに加え、将来的に Core ML モデルを組み込み可能な構造。
//      - VoiceIntentRouter から呼び出される。
//
//  🔗 依存:
//      - VoiceIntent.swift（意図モデル）
//      - NaturalLanguage.framework（NLP）
//      - CoreML.framework（将来的なモデル統合）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import Foundation
import NaturalLanguage
import CoreML

final class ActionResolver {
    /// ユーザーのコマンドを解析し、VoiceIntent に変換
    func resolve(from command: String) -> VoiceIntent {
        let lower = command.lowercased()
        
        // 1. キーワードベースの即時判定
        if lower.contains("削除") || lower.contains("delete") {
            return VoiceIntent(action: .delete, entity: detectEntity(from: command), field: nil, value: nil)
        } else if lower.contains("追加") || lower.contains("add") {
            return VoiceIntent(action: .add, entity: detectEntity(from: command), field: nil, value: detectValue(from: command))
        } else if lower.contains("更新") || lower.contains("update") {
            return VoiceIntent(action: .update, entity: detectEntity(from: command), field: detectField(from: command), value: detectValue(from: command))
        } else if lower.contains("表示") || lower.contains("read") {
            return VoiceIntent(action: .read, entity: detectEntity(from: command), field: nil, value: nil)
        }
        
        // 2. NLP による補助解析
        let entity = detectEntity(from: command)
        let field = detectField(from: command)
        let value = detectValue(from: command)
        
        return VoiceIntent(action: .read, entity: entity, field: field, value: value)
    }
    
    // MARK: - NLP ユーティリティ
    private func detectEntity(from text: String) -> String {
        // 簡易ルール + 固有表現抽出
        if text.contains("薬") || text.contains("medicine") {
            return "Medication"
        } else if text.contains("サプリ") || text.contains("supplement") {
            return "Supplement"
        } else if text.contains("プロフィール") || text.contains("体重") {
            return "UserProfile"
        }
        return "UserProfile"
    }
    
    private func detectField(from text: String) -> String? {
        if text.contains("体重") || text.contains("weight") {
            return "weightKg"
        } else if text.contains("名前") || text.contains("name") {
            return "name"
        }
        return nil
    }
    
    private func detectValue(from text: String) -> String? {
        // 数値や単位を抽出
        let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
        tagger.string = text
        var detected: String?
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                             unit: .word,
                             scheme: .nameType,
                             options: [.omitPunctuation, .omitWhitespace]) { tag, range in
            if let tag = tag, tag == .number {
                detected = String(text[range])
                return false
            }
            return true
        }
        
        // 単位付きの例: "65kg"
        if let match = text.range(of: #"\d+\s?(kg|mg|g)"#, options: .regularExpression) {
            return String(text[match])
        }
        
        return detected
    }
}
