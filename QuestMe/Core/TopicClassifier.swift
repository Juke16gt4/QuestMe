//
//  TopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/TopicClassifier.swift
//
//  🎯 ファイルの目的:
//      ルール＋MLハイブリッドのトピック分類。
//      - ユーザー履歴に基づく補正でパーソナライズ。
//      - Core ML モデルが存在すれば利用。
//
//  🔗 依存:
//      - Models.swift
//      - Foundation
//      - NaturalLanguage
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine
import NaturalLanguage

final class TopicClassifier: ObservableObject {
    @Published private(set) var userTopicCounts: [ConversationTopic:Int] = [:]

    private var nlModel: NLModel? = {
        if let url = Bundle.main.url(forResource: "TopicClassifier", withExtension: "mlmodelc") {
            return try? NLModel(contentsOf: url)
        }
        return nil
    }()

    func registerUserEntry(_ entry: ConversationEntry) {
        guard entry.speaker == "user" else { return }
        userTopicCounts[entry.topic, default: 0] += 1
    }

    func classify(_ text: String) -> ConversationTopic {
        if let rule = ruleClassify(text) { return rule }
        if let model = nlModel, let label = model.predictedLabel(for: text),
           let mlTopic = mapLabel(label) {
            return corrected(byHistory: mlTopic)
        }
        return corrected(byHistory: .other)
    }

    private func ruleClassify(_ text: String) -> ConversationTopic? {
        let l = text.lowercased()
        if l.contains("政治") || l.contains("選挙") { return .politics }
        if l.contains("芸能") || l.contains("俳優") || l.contains("アイドル") { return .entertainment }
        if l.contains("it") || l.contains("テック") || l.contains("技術") || l.contains("コード") { return .it }
        if l.contains("生活") || l.contains("家事") || l.contains("買い物") { return .life }
        if l.contains("不安") || l.contains("心配") || l.contains("悩み") { return .anxiety }
        if l.contains("健康") || l.contains("薬") || l.contains("運動") { return .health }
        if l.contains("趣味") || l.contains("旅行") || l.contains("音楽") { return .hobby }
        if l.contains("仕事") || l.contains("職場") || l.contains("開発") { return .work }
        if l.contains("家族") || l.contains("子供") || l.contains("親") { return .family }
        if l.contains("成長") || l.contains("学び") || l.contains("勉強") { return .growth }
        return nil
    }

    private func mapLabel(_ label: String) -> ConversationTopic? {
        switch label.lowercased() {
        case "politics": return .politics
        case "entertainment": return .entertainment
        case "it": return .it
        case "life": return .life
        case "anxiety": return .anxiety
        case "health": return .health
        case "hobby": return .hobby
        case "work": return .work
        case "family": return .family
        case "growth": return .growth
        default: return .other
        }
    }

    private func corrected(byHistory topic: ConversationTopic) -> ConversationTopic {
        if let (topTopic, topCount) = userTopicCounts.max(by: { $0.value < $1.value }),
           topCount >= 5, topic == .other {
            return topTopic
        }
        return topic
    }
}
