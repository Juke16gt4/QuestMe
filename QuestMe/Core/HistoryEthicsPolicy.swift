//
//  HistoryEthicsPolicy.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/HistoryEthicsPolicy.swift
//
//  🎯 ファイルの目的:
//      歴史分野の免責文と安全表現ガイドライン。
//      - 学術的解釈の一例として提示。
//      - 断定的表現を弱める。
//      - 出典明示を推奨（国立国会図書館、歴史学会誌など）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct HistoryDisclaimerProvider {
    static func disclaimerJP() -> String {
        "以下は歴史的な一般情報であり、学術的解釈の一例です。"
    }
}

struct HistoryToneGuard {
    private static let softenMap: [String:String] = [
        "絶対":"一般的には",
        "必ず":"多くの場合",
        "確実":"概ね"
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
        return "出典: 国立国会図書館や歴史学会誌などの公式資料を推奨します"
    }
}
