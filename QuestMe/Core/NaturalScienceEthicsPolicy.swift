//
//  NaturalScienceEthicsPolicy.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/NaturalScienceEthicsPolicy.swift
//
//  🎯 ファイルの目的:
//      自然科学分野の免責文と安全表現ガイドライン。
//      - 研究成果の紹介は一般情報として提示。
//      - 断定的表現の弱化（過度な確実性表現の抑制）。
//      - 出典明示を推奨（公式・査読済み情報を優先）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct ScienceDisclaimerProvider {
    static func disclaimerJP() -> String {
        "以下は一般的な科学知識であり、研究成果の一部を紹介するものです。詳細な検証や再現性については一次情報の確認を推奨します。"
    }
}

struct ScienceToneGuard {
    private static let softenMap: [String:String] = [
        "絶対":"一般的には",
        "必ず":"通常は",
        "確実":"多くの場合",
        "間違いなく":"概ね",
        "証明された":"広く支持されている",
        "否定できない":"強く示唆される"
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
        return "出典: 学術的な一次情報の確認を推奨します"
    }
}
