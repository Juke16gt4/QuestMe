//
//  CompanionMemoryEngine.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Engine/CompanionMemoryEngine.swift
//
//  🎯 ファイルの目的:
//      Calendar/年/月/対話/日.json を読み込み、ユーザーの返信履歴をAIが分析。
//      - 感情・疲労・食事・服薬・検査に関する傾向を抽出。
//      - CompanionAdviceView に連携し、語りかけに活かす。
//      - 感情の流れや変化をユーザーにフィードバックする。
//
//  🔗 依存:
//      - DialogueEntry.swift（履歴モデル）
//      - FileManager（読み込み）
//      - NaturalLanguage（感情分析）
//
//  👤 製作者: 津村 淳一
//  📅 修正日: 2025年10月9日

import Foundation
import NaturalLanguage

struct CompanionMemoryEngine {
    func loadAllReplies() -> [DialogueEntry] {
        var entries: [DialogueEntry] = []
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let calendarRoot = docs.appendingPathComponent("Calendar")

        guard let enumerator = fm.enumerator(at: calendarRoot, includingPropertiesForKeys: nil) else { return [] }

        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent.hasSuffix(".json"),
               fileURL.path.contains("対話") {
                if let data = try? Data(contentsOf: fileURL),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let date = json["date"] as? String,
                   let advice = json["advice"] as? String,
                   let reply = json["reply"] as? String {
                    let entry = DialogueEntry(date: date, advice: advice, reply: reply)
                    entries.append(entry)
                }
            }
        }

        return entries.sorted(by: { $0.date < $1.date })
    }

    func summarizeEmotionTrend(from entries: [DialogueEntry]) -> String {
        var positive = 0
        var negative = 0
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        for entry in entries {
            tagger.string = entry.reply
            let score = tagger.tag(at: entry.reply.startIndex, unit: .paragraph, scheme: .sentimentScore).0
            if let scoreStr = score?.rawValue, let scoreVal = Double(scoreStr) {
                if scoreVal > 0.1 { positive += 1 }
                else if scoreVal < -0.1 { negative += 1 }
            }
        }

        if entries.isEmpty {
            return "まだ十分な対話履歴がありません。記録を続けていきましょう。"
        }

        if positive > negative {
            return "最近は前向きな返信が多いですね。この調子で続けましょう。"
        } else if negative > positive {
            return "少し疲れや不安が見える日が続いています。無理せず、休息を意識しましょう。"
        } else {
            return "感情の波が安定しています。自分のペースを大切にしてください。"
        }
    }

    func extractKeywords(from entries: [DialogueEntry]) -> [String] {
        let allText = entries.map { $0.reply }.joined(separator: " ")
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = allText
        var keywords: [String: Int] = [:]

        tokenizer.enumerateTokens(in: allText.startIndex..<allText.endIndex) { range, _ in
            let word = String(allText[range]).lowercased()
            if word.count > 2 {
                keywords[word, default: 0] += 1
            }
            return true
        }

        return keywords.sorted(by: { $0.value > $1.value }).prefix(5).map { $0.key }
    }

    func generateMemorySummary() -> String {
        let entries = loadAllReplies()
        let emotionTrend = summarizeEmotionTrend(from: entries)
        let keywords = extractKeywords(from: entries)

        var summary = emotionTrend + "\n"
        if !keywords.isEmpty {
            summary += "最近よく使われている言葉：「" + keywords.joined(separator: "」「") + "」\n"
        }
        summary += "これまでの対話をもとに、あなたの傾向を少しずつ理解しています。"

        return summary
    }
}
