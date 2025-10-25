//
//  ClassicsEthicsPolicy.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/ClassicsEthicsPolicy.swift
//
//  🎯 ファイルの目的:
//      古典分野の免責文と安全表現ガイドライン。
//      - 解釈は学術的な一例として提示。
//      - 断定的表現を弱める。
//      - 出典明示を推奨（青空文庫・大学資料など）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

struct ClassicsDisclaimerProvider {
    static func disclaimerJP() -> String {
        "以下は古典文学の一般的解説であり、学術的研究の一部です。解釈には複数の視点があります。"
    }
}

struct ClassicsToneGuard {
    private static let softenMap: [String:String] = [
        "絶対":"一般的には",
        "必ず":"通常は",
        "確実":"多くの場合",
        "正しい":"広く支持されている"
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
        return "出典: 青空文庫や大学古典資料などの公式情報を推奨します"
    }
}
