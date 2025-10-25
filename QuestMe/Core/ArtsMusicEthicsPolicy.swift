//
//  ArtsMusicEthicsPolicy.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/ArtsMusicEthicsPolicy.swift
//
//  🎯 ファイルの目的:
//      芸術・音楽分野の免責文と安全表現ガイドライン。
//      - 解釈は一般的な一例として提示。
//      - 断定的表現を弱める。
//      - 出典明示を推奨（美術館・音楽学会・著作権切れ資料など）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

struct ArtsMusicDisclaimerProvider {
    static func disclaimerJP() -> String {
        "以下は芸術・音楽の一般的解説です。解釈には複数の視点があります。"
    }
}

struct ArtsMusicToneGuard {
    private static let softenMap: [String:String] = [
        "絶対":"一般的には",
        "必ず":"通常は",
        "正しい":"広く支持されている",
        "最高":"高く評価されている"
    ]

    static func soften(_ text: String) -> String {
        var out = text
        for (k,v) in softenMap {
            out = out.replacingOccurrences(of: k, with: v)
        }
        return out
    }

    static func enforceSourcePrefix(_ source: String?) -> String {
        if let s = source, !s.isEmpty { return "出典: \(s)" }
        return "出典: 美術館・音楽学会・著作権切れ資料などの公式情報を推奨します"
    }
}
