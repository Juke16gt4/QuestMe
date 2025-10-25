//
//  PsychologyEthicsPolicy.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/PsychologyEthicsPolicy.swift
//
//  🎯 ファイルの目的:
//      心理学分野の免責文と安全表現ガイドライン。
//      - 臨床診断や治療の代替を禁止。
//      - 免責文を自動付与。
//      - 出典明示を推奨（APA/心理学会誌など）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

struct PsychologyDisclaimerProvider {
    static func disclaimerJP() -> String {
        "以下は心理学の一般理論であり、臨床診断の代替ではありません。必要に応じて専門家にご相談ください。"
    }
}

struct PsychologyToneGuard {
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
        return "出典: APAや心理学会誌などの公式資料を推奨します"
    }
}
