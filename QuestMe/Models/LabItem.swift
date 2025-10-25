//
//  LabItem.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/LabItem.swift
//
//  🎯 ファイルの目的:
//      OCRで読み取った検査項目を構造化し、異常値判定を可能にする。
//      - LabResult に含まれる個別項目として使用。
//      - グラフ表示や履歴表示で活用。
//      - referenceRange に基づき isAbnormal を自動判定。

import Foundation

struct LabItem: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var value: String
    var unit: String?
    var referenceRange: String?
    var isAbnormal: Bool?

    mutating func evaluateAbnormality() {
        guard let range = referenceRange,
              let valueNum = Double(value),
              let lower = Double(range.components(separatedBy: "-").first ?? ""),
              let upper = Double(range.components(separatedBy: "-").last ?? "") else {
            isAbnormal = nil
            return
        }
        isAbnormal = !(lower...upper).contains(valueNum)
    }
}
