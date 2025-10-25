//
//  CertificationTemplateProvider.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/CertificationTemplateProvider.swift
//
//  🎯 ファイルの目的:
//      資格ごとの学習計画テンプレートを提供。
//      - 週次/日次/分野別のステップを提示。
//      - ユーザーの学習計画立案を支援。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

struct CertificationTemplate {
    let title: String
    let steps: [String]
}

final class CertificationTemplateProvider {
    func template(for name: String) -> CertificationTemplate {
        if name.lowercased().contains("pmp") {
            return CertificationTemplate(
                title: "PMP 4週間集中プラン",
                steps: [
                    "Week 1: PMBOK第1〜3章の理解",
                    "Week 2: 模擬試験と振り返り",
                    "Week 3: 弱点補強と用語整理",
                    "Week 4: 本番形式で通し練習"
                ]
            )
        }
        return CertificationTemplate(
            title: "一般資格テンプレート",
            steps: ["目標設定", "教材選定", "週次レビュー", "模擬試験"]
        )
    }
}
