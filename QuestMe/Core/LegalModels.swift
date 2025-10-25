//
//  LegalModels.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/LegalModels.swift
//
//  🎯 ファイルの目的:
//      法律関連カテゴリと法令参照のためのモデル定義。
//      - LegalTopic: 法分野の分類（憲法/民法/刑法/労働法/知財/行政/国際/消費者/会社法/その他）。
//      - LegalArticleRef: 法令参照情報（法令名、条、項、号、出典URL）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

enum LegalTopic: String, Codable, CaseIterable {
    case constitution     // 憲法
    case civil            // 民法
    case criminal         // 刑法
    case labor            // 労働法
    case ip               // 知的財産法
    case administrative   // 行政法
    case international    // 国際法
    case consumer         // 消費者法
    case corporate        // 会社法
    case other            // その他
}

struct LegalArticleRef: Codable, Hashable {
    let lawName: String       // 例: 民法
    let article: String       // 例: 第709条
    let paragraph: String?    // 例: 1項
    let item: String?         // 例: 1号
    let sourceURL: URL?       // 公式ソース（e-Gov 法令検索など）
}
