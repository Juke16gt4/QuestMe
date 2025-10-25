//
//  CertificationEthicsPolicy.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/CertificationEthicsPolicy.swift
//
//  🎯 ファイルの目的:
//      資格取得分野の免責文と安全表現ガイドライン。
//      - 合格保証や制度断定を禁止。
//      - 免責文を自動付与。
//      - 出典明示を推奨（厚労省/IPA/ETS/PMP/AWSなど）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

struct CertificationDisclaimerProvider {
    static func disclaimerJP() -> String {
        "以下は資格取得に関する一般情報であり、試験制度や合格保証を含むものではありません。詳細は公式機関をご確認ください。"
    }
}

struct CertificationToneGuard {
    private static let softenMap: [String:String] = [
        "絶対合格":"多くの受験者が成功している",
        "簡単に取れる":"比較的取り組みやすいとされる",
        "確実に受かる":"一般的に合格率が高いとされる",
        "落ちる可能性ゼロ":"十分な準備が推奨される",
        "おすすめ資格":"注目されている資格"
    ]

    static func soften(_ text: String) -> String {
        var out = text
        for (k,v) in softenMap {
            out = out.replacingOccurrences(of: k, with: v)
        }
        return out
    }

    static func enforceSourcePrefix(_ source: String?) -> String {
        if let s = source, !s.isEmpty {
            return "出典: \(s)"
        }
        return "出典: 厚労省、IPA、ETS、AWS、PMPなどの公式資料を推奨します"
    }

    static func blockedReply() -> String {
        "資格取得に関する情報は慎重に扱う必要があります。詳細は公式機関をご確認ください。"
    }

    static func safeReply(from original: String) -> String {
        soften(original)
    }

    static func score(_ text: String) -> Int {
        var score = 0
        for (k,_) in softenMap {
            if text.contains(k) { score += 1 }
        }
        return score
    }

    static func shouldBlock(_ score: Int) -> Bool {
        score >= 3
    }

    static func shouldCaution(_ score: Int) -> Bool {
        score == 1 || score == 2
    }
}
