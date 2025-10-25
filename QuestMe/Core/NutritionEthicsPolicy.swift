//
//  NutritionEthicsPolicy.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/NutritionEthicsPolicy.swift
//
//  🎯 ファイルの目的:
//      栄養学分野の免責文と安全表現ガイドライン。
//      - 個別の食事指導や医療判断の代替を禁止。
//      - 免責文を自動付与。
//      - 出典明示を推奨（厚労省/WHOなど）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct NutritionDisclaimerProvider {
    static func disclaimerJP() -> String {
        "以下は一般的な栄養学情報であり、個別の食事指導ではありません。必要に応じて専門家にご相談ください。"
    }
}

struct NutritionToneGuard {
    private static let softenMap: [String:String] = [
        "絶対":"一般的には",
        "必ず":"通常は",
        "確実":"多くの場合"
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
        return "出典: 厚労省やWHOなどの公式資料を推奨します"
    }
}
