//
//  EthicalFilter.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/EthicalFilter.swift
//
//  🎯 ファイルの目的:
//      誹謗中傷/嘲笑/センシティブ検知と共感テンプレート適用。
//      - ユーザー入力のサニタイズ。
//      - 応答の安全化（ブロック/注意/言い換え）。
//
//  🔗 依存:
//      - Models.swift
//      - Foundation
//      - SwiftUI
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine
import SwiftUI

struct EthicalScore {
    let aggression: Int
    let mockery: Int
    let sensitivity: Int
    var total: Int { aggression + mockery + sensitivity }
}

final class EthicalFilter: ObservableObject {
    private let aggressionWords = ["バカ","死ね","殺す","愚か","クズ","あほ","間抜け","dis","侮辱"]
    private let mockeryWords = ["笑","草","嘲笑","晒す","煽る","いじる"]
    private let sensitiveWords = ["事故","災害","病気","自殺","鬱","暴力","差別","虐待","いじめ","誹謗中傷"]

    private let replaceMap: [String:String] = [
        "死ね":"＊＊","殺す":"＊＊","バカ":"＊＊","クズ":"＊＊","嘲笑":"＊＊","差別":"＊＊"
    ]

    private let blockThreshold = 3
    private let cautionThreshold = 2

    private let empathyTemplates: [ConversationSubject:[String]] = [
        .anxiety: [
            "不安に感じるのは自然なことです。",
            "まず状況を整理して、一歩ずつ進めましょう。"
        ],
        .life: [
            "日々の生活は、ときに負荷が重なりますね。",
            "小さな前進でも大切にしていきましょう。"
        ],
        .health: [
            "体調を第一に、無理のないペースを大切に。",
            "必要なら、専門家の助言も検討しましょう。"
        ],
        .work: [
            "仕事の負荷は、時期によって大きく変わりますね。",
            "優先順位をつけて、できる範囲から整えましょう。"
        ],
        .politics: [
            "複雑な問題ほど、複数の視点が役立ちます。",
            "事実と解釈を分けて考えるのが有効です。"
        ],
        .entertainment: [
            "話題を共有してくれてありがとう。",
            "情報源の確認も忘れずに進めますね。"
        ]
    ]

    func sanitizeUserInput(_ text: String) -> String {
        var out = text
        for (k,v) in replaceMap { out = out.replacingOccurrences(of: k, with: v) }
        return out
    }

    func score(_ text: String) -> EthicalScore {
        let l = text.lowercased()
        let aggr = aggressionWords.reduce(0) { $0 + (l.contains($1.lowercased()) ? 1 : 0) }
        let mock = mockeryWords.reduce(0) { $0 + (l.contains($1.lowercased()) ? 1 : 0) }
        let sens = sensitiveWords.reduce(0) { $0 + (l.contains($1.lowercased()) ? 1 : 0) }
        return EthicalScore(aggression: aggr, mockery: mock, sensitivity: sens)
    }

    func safeReply(from text: String) -> String {
        var reply = text
        for (k,v) in replaceMap { reply = reply.replacingOccurrences(of: k, with: v) }
        let l = reply.lowercased()
        if mockeryWords.contains(where: { l.contains($0.lowercased()) }) {
            reply = reply.replacingOccurrences(of: "笑", with: "")
            reply = reply.replacingOccurrences(of: "草", with: "")
            reply = "敬意をもって情報を共有します。" + reply
        }
        return reply
    }

    func shouldBlock(_ score: EthicalScore) -> Bool {
        score.total >= blockThreshold || score.aggression > 0
    }

    func shouldCaution(_ score: EthicalScore) -> Bool {
        score.total >= cautionThreshold || score.sensitivity > 0
    }

    func empatheticPrefix(for topic: ConversationSubject) -> String {
        if let set = empathyTemplates[topic], let pick = set.randomElement() { return pick }
        return "話題を共有してくれてありがとう。"
    }
}
