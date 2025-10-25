//
//  MedicalEthicsPolicy.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/MedicalEthicsPolicy.swift
//
//  🎯 ファイルの目的:
//      医学分野の免責文と安全表現ガイドライン。
//      - 診断や処方の代替を禁止。
//      - 免責文を自動付与。
//      - 危険な断定表現を弱める。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct MedicalDisclaimerProvider {
    static func disclaimerJP() -> String {
        "以下は一般的な医学・薬学情報であり、診断や処方の代替にはなりません。必ず専門医にご相談ください。"
    }
}
