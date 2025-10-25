//
//  StockEthicsPolicy.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/StockEthicsPolicy.swift
//
//  🎯 ファイルの目的:
//      株式分野の免責文と安全表現ガイドライン。
//      - 投資助言の禁止。
//      - 断定表現の弱化（儲かる/確実などを一般化）。
//      - 出典明示の強制（証券会社・金融機関・公式資料）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

struct StockDisclaimerProvider {
    static func disclaimerJP() -> String {
        "以下は株式に関する一般情報であり、投資助言ではありません。売買判断は専門家にご相談ください。"
    }
}

struct StockToneGuard {
    private static let softenMap: [String:String] = [
        "儲かる":"注目されている",
        "確実":"多くの場合",
        "絶対":"一般的には",
        "おすすめ":"検討されることがある"
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
        return "出典: 証券会社・金融機関・公式資料を推奨します"
    }
}
