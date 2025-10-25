//
//  PharmacyFaxEntry.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/Pharmacy/PharmacyFaxEntry.swift
//
//  🎯 ファイルの目的:
//      薬局Fax送付機能における薬局情報モデル。
//      - 薬局名とFax番号を保持。
//      - UserDefaultsやSQLiteで保存・取得に使用される。
//      - 複数薬局を一意に識別するためUUIDを付与。
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import Foundation

struct PharmacyFaxEntry: Codable, Identifiable {
    var id: UUID = UUID()
    let name: String
    let faxNumber: String
}
