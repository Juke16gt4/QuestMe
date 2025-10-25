//
//  MedicalModels.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/MedicalModels.swift
//
//  🎯 ファイルの目的:
//      医学・薬学関連のトピック分類。
//      - MedicalTopic: 内科/外科/薬理/公衆衛生など。
//      - MedicalArticleRef: 論文やガイドライン参照情報。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

enum MedicalTopic: String, Codable {
    case internalMed, surgery, pharmacology, publicHealth, nutrition, rehab, sports, other
}

struct MedicalArticleRef: Codable {
    let title: String
    let sourceURL: URL?
}
