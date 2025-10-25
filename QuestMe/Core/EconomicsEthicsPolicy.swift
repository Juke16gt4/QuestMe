//
//  EconomicsEthicsPolicy.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/EconomicsEthicsPolicy.swift
//
//  🎯 ファイルの目的:
//      経済学・経営学分野の免責文と安全表現ガイドライン。
//      - 投資助言や金融判断の代替を禁止。
//      - 免責文を自動付与。
//      - 出典明示を推奨（IMF/OECD/日銀など）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

struct EconomicsDisclaimerProvider {
    static func disclaimerJP() -> String {
        "以下は一般的な経済情報であり、投資助言ではありません。金融判断は専門家にご相談ください。"
    }
}

struct EconomicsToneGuard {
    private static let softenMap: [String:String] = [
        "絶対":"一般的には",
        "必ず":"通常は",
        "確実":"多くの場合",
        "儲かる":"有利に働く可能性がある",
        "損する":"リスクがある"
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
        return "出典: IMFやOECD、日銀などの公式資料を推奨します"
    }
}
