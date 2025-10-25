//
//  BeautyStorageManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Beauty/BeautyStorageManager.swift
//
//  🎯 目的:
//      美容アドバイスの保存/読み込み/自動削除（3ヶ月）/初回永久保存。
//      ・保存先: Documents/Calendar/美容アドバイス
//      ・初回: 基準画像/first.jpg + first.json（永久）
//      ・履歴: 履歴/timestamp.jpg + timestamp.json（3ヶ月以上前は自動削除）
//      ・削除UIは提供しない（アプリ削除時のみ全削除の想定）
//
//  🔗 依存:
//      - Foundation, UIKit
//
//  🔗 関連/連動ファイル:
//      - BeautyAdviceEngine.swift
//      - BeautyCaptureView.swift
//      - BeautyCompareView.swift
//      - BeautyHistoryView.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-21

import Foundation
import UIKit

struct BeautyLog: Codable, Identifiable {
    var id = UUID()
    var timestamp: Date
    var imageFilename: String
    var analysis: BeautyAnalysisResult
    var category: BeautyAdviceCategory
}

final class BeautyStorageManager {
    static let shared = BeautyStorageManager()

    private var fm: FileManager { FileManager.default }
    private var docs: URL { fm.urls(for: .documentDirectory, in: .userDomainMask).first! }
    private var root: URL { docs.appendingPathComponent("Calendar/美容アドバイス") }
    private var firstFolder: URL { root.appendingPathComponent("基準画像") }
    private var historyFolder: URL { root.appendingPathComponent("履歴") }

    init() {
        try? fm.createDirectory(at: firstFolder, withIntermediateDirectories: true)
        try? fm.createDirectory(at: historyFolder, withIntermediateDirectories: true)
    }

    func hasFirstImage() -> Bool {
        fm.fileExists(atPath: firstFolder.appendingPathComponent("first.jpg").path)
    }

    func saveFirst(image: UIImage, analysis: BeautyAnalysisResult) {
        let jpgURL = firstFolder.appendingPathComponent("first.jpg")
        let jsonURL = firstFolder.appendingPathComponent("first.json")
        if let data = image.jpegData(compressionQuality: 0.95) {
            try? data.write(to: jpgURL)
        }
        let log = BeautyLog(timestamp: Date(), imageFilename: "first.jpg", analysis: analysis, category: .capture)
        if let data = try? JSONEncoder().encode(log) {
            try? data.write(to: jsonURL)
        }
    }

    func saveHistory(image: UIImage, analysis: BeautyAnalysisResult) {
        let ts = timestampString(Date())
        let jpgURL = historyFolder.appendingPathComponent("\(ts).jpg")
        let jsonURL = historyFolder.appendingPathComponent("\(ts).json")
        if let data = image.jpegData(compressionQuality: 0.95) {
            try? data.write(to: jpgURL)
        }
        let log = BeautyLog(timestamp: Date(), imageFilename: "\(ts).jpg", analysis: analysis, category: .capture)
        if let data = try? JSONEncoder().encode(log) {
            try? data.write(to: jsonURL)
        }
        cleanupOlderThan3Months()
    }

    func loadFirst() -> (image: UIImage?, log: BeautyLog?) {
        let jpgURL = firstFolder.appendingPathComponent("first.jpg")
        let jsonURL = firstFolder.appendingPathComponent("first.json")
        let img = UIImage(contentsOfFile: jpgURL.path)
        var log: BeautyLog?
        if let data = try? Data(contentsOf: jsonURL) {
            log = try? JSONDecoder().decode(BeautyLog.self, from: data)
        }
        return (img, log)
    }

    func loadLatest() -> (image: UIImage?, log: BeautyLog?) {
        guard let files = try? fm.contentsOfDirectory(at: historyFolder, includingPropertiesForKeys: nil) else { return (nil, nil) }
        let images = files.filter { $0.pathExtension.lowercased() == "jpg" }
        guard let latestImageURL = images.sorted(by: { $0.lastPathComponent > $1.lastPathComponent }).first else { return (nil, nil) }
        let latestJsonURL = historyFolder.appendingPathComponent(latestImageURL.deletingPathExtension().lastPathComponent + ".json")
        let img = UIImage(contentsOfFile: latestImageURL.path)
        var log: BeautyLog?
        if let data = try? Data(contentsOf: latestJsonURL) {
            log = try? JSONDecoder().decode(BeautyLog.self, from: data)
        }
        return (img, log)
    }

    func loadHistoryLogs() -> [BeautyLog] {
        guard let files = try? fm.contentsOfDirectory(at: historyFolder, includingPropertiesForKeys: nil) else { return [] }
        let jsons = files.filter { $0.pathExtension.lowercased() == "json" }
        var logs: [BeautyLog] = []
        for u in jsons {
            if let data = try? Data(contentsOf: u), let log = try? JSONDecoder().decode(BeautyLog.self, from: data) {
                logs.append(log)
            }
        }
        return logs.sorted { $0.timestamp > $1.timestamp }
    }

    private func cleanupOlderThan3Months() {
        guard let files = try? fm.contentsOfDirectory(at: historyFolder, includingPropertiesForKeys: [.creationDateKey]) else { return }
        for f in files {
            if let attrs = try? fm.attributesOfItem(atPath: f.path),
               let date = attrs[.creationDate] as? Date,
               Calendar.current.dateComponents([.month], from: date, to: Date()).month ?? 0 >= 3 {
                try? fm.removeItem(at: f)
            }
        }
    }

    private func timestampString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return f.string(from: date)
    }
}
