//
//  FolderScanner.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/Calendar/FolderScanner.swift
//
//  🎯 目的:
//      指定日付に関連する保存フォルダー（カテゴリ）を抽出する。
//      - 保存形式: Documents/Calendar/yyyy-MM-dd/カテゴリ/event.json
//      - カレンダーUIや検索UIで使用可能。
//
//  🔗 連動:
//      - DayScheduleView.swift（1日スケジュール）
//      - SearchCalendarLogView.swift（検索画面）
//      - QuestMeCalendarView.swift（月グリッド）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import Foundation

struct FolderScanner {
    /// 指定日付に関連する保存フォルダー名（カテゴリ）を返す
    /// - Parameter date: 対象日付
    /// - Returns: フォルダー名の配列（例: ["おくすり", "感情"]）
    static func folders(for date: Date) -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: date)

        let root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dateFolder = root
            .appendingPathComponent("Calendar")
            .appendingPathComponent(dateStr)

        guard let categoryFolders = try? FileManager.default.contentsOfDirectory(at: dateFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        else { return [] }

        return categoryFolders.compactMap { folderURL in
            guard folderURL.hasDirectoryPath else { return nil }
            let fileURL = folderURL.appendingPathComponent("event.json")
            return FileManager.default.fileExists(atPath: fileURL.path) ? folderURL.lastPathComponent : nil
        }
        .sorted()
    }
}
