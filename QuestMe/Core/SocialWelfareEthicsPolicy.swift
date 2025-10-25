//
//  SocialWelfareEthicsPolicy.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/SocialWelfareEthicsPolicy.swift
//
//  🎯 ファイルの目的:
//      社会福祉学分野の免責文と安全表現ガイドライン。
//      - 個別の生活相談や制度利用の代替を禁止。
//      - 免責文を自動付与。
//      - 差別的表現をブロック。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

struct SocialWelfareDisclaimerProvider {
    static func disclaimerJP() -> String {
        "以下は一般的な社会福祉学の情報であり、個別の生活相談や制度利用の代替にはなりません。具体的な支援は専門機関にご相談ください。"
    }
}
