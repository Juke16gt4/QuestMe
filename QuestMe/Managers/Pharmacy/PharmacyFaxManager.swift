//
//  PharmacyFaxManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/Pharmacy/PharmacyFaxManager.swift
//
//  🎯 ファイルの目的:
//      薬局Fax送付機能における薬局情報の保存・取得・削除管理。
//      - 最大3件までの薬局情報をUserDefaultsに保存。
//      - CompanionFaxFlowViewから呼び出される。
//      - 将来的にSQLite移行可能な構造。
//
//  🔗 依存:
//      - Models/PharmacyFaxEntry.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import Foundation

final class PharmacyFaxManager {
    static let shared = PharmacyFaxManager()
    private let key = "pharmacyFaxList"

    func save(pharmacy: String, fax: String) {
        var list = all()
        list.append(PharmacyFaxEntry(name: pharmacy, faxNumber: fax))
        persist(list)
    }

    func delete(pharmacy: String) {
        var list = all()
        list.removeAll { $0.name == pharmacy }
        persist(list)
    }

    func all() -> [PharmacyFaxEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([PharmacyFaxEntry].self, from: data) else {
            return []
        }
        return decoded
    }

    private func persist(_ list: [PharmacyFaxEntry]) {
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
