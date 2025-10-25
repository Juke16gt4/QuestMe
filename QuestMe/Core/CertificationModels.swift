//
//  CertificationModels.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/CertificationModels.swift
//
//  🎯 ファイルの目的:
//      資格取得分野のトピック分類と参照モデル。
//      - CertificationTopic: 国内医療/国内法律/国内IT/国際語学/国際技術/国際ビジネス/その他。
//      - CertificationReference: 出典URL付きの参照情報（厚労省/IPA/ETS/PMP/AWSなど）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

struct CertificationReference: Codable, Hashable {
    let title: String
    let sourceURL: URL?
}
