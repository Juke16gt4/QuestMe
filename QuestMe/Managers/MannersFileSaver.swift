//
//  MannersFileSaver.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/MannersFileSaver.swift
//
//  🎯 ファイルの目的:
//      GPS/WiFiで取得した訪問先のマナー情報を、日付＋地域名でファイル保存。
//      保存先は Calendar/VisitDestination/ フォルダー。
//      Companionのマナー儀式履歴として活用可能。
//
//  🔗 依存:
//      - Foundation
//      - RegionManners（APIまたはローカル辞書構造）
//
//  👤 製作者: 津村 淳一
//  📅 改変日: 2025年10月13日
//

import Foundation

class MannersFileSaver {
    static let shared = MannersFileSaver()

    func save(manners: RegionManners) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())

        let folderName = "VisitDestination"
        let fileName = "\(dateString)_\(manners.region).txt"

        let fileManager = FileManager.default
        let calendarFolder = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Calendar")
            .appendingPathComponent(folderName)

        // フォルダー作成
        if !fileManager.fileExists(atPath: calendarFolder.path) {
            try? fileManager.createDirectory(at: calendarFolder, withIntermediateDirectories: true)
        }

        let fileURL = calendarFolder.appendingPathComponent(fileName)

        // 内容整形
        var content = "📍 訪問先: \(manners.region), \(manners.country)\n🕒 記録日: \(dateString)\n🗣 言語: \(manners.language)\n\n"
        for (key, item) in manners.manners {
            content += "🔸 \(key.capitalized)\n"
            content += "　感情: \(item.emotion)\n"
            content += "　内容: \(item.summary)\n\n"
        }

        // 保存
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            CompanionOverlay.shared.speak("訪問先マナーをカレンダーに保存しました。", emotion: .happy)
        } catch {
            CompanionOverlay.shared.speak("保存に失敗しました。", emotion: .sad)
        }
    }
}
