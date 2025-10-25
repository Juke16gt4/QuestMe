//
//  EngineeringEthicsPolicy.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/EngineeringEthicsPolicy.swift
//
//  🎯 ファイルの目的:
//      工学・情報科学分野の免責文と安全表現ガイドライン。
//      - 解説は研究成果の一部として提示。
//      - 断定的表現を弱める。
//      - 出典明示を推奨（IEEE/ACM/大学研究所など）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

struct EngineeringDisclaimerProvider {
    static func disclaimerJP() -> String {
        "以下は工学・情報科学の一般情報であり、研究成果の一部です。詳細は一次資料をご確認ください。"
    }
}

struct EngineeringToneGuard {
    private static let softenMap: [String:String] = [
        "絶対":"一般的には",
        "必ず":"通常は",
        "確実":"多くの場合",
        "最先端":"注目されている",
        "革新的":"新しいアプローチ"
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
        return "出典: IEEEやACM、大学研究所などの公式資料を推奨します"
    }
}
