//
//  SocialWelfareModels.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/SocialWelfareModels.swift
//
//  🎯 ファイルの目的:
//      社会福祉学関連のトピック分類。
//      - SocialWelfareTopic: 高齢者/障害者/児童/生活保護/地域/国際/その他。
//      - SocialWelfareArticleRef: 制度や研究参照情報。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

enum SocialWelfareTopic: String, Codable {
    case elderly, disability, child, poverty, community, international, other
}

struct SocialWelfareArticleRef: Codable {
    let title: String
    let sourceURL: URL?
}
