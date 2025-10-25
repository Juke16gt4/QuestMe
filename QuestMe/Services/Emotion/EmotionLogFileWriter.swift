//
//  EmotionLogFileWriter.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/Emotion/EmotionLogFileWriter.swift
//
//  🎯 目的:
//      感情ログ（感想・写真・位置情報）を CoreData ではなくファイルとして保存。
//      - 保存先: ~/Library/Calendars/おでかけ/
//      - ファイル名: yyyyMMdd_HHmmss.json
//      - 構造: text と image を分離して保存
//
//  🔗 関連:
//      - PlaceDetailOverlay.swift（保存呼び出し元）
//      - EmotionLogViewer.swift（読み込み表示）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import Foundation
import CoreLocation
import UIKit

struct EmotionLogFileWriter {
    static func save(placeName: String,
                     coordinate: CLLocationCoordinate2D,
                     comment: String,
                     image: UIImage?) {
        let timestamp = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let filename = formatter.string(from: timestamp) + ".json"

        let folderURL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Calendars/おでかけ", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            print("❌ フォルダー作成失敗: \(error)")
            return
        }

        var payload: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: timestamp),
            "placeName": placeName,
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "text": [
                "comment": comment
            ]
        ]

        if let image = image,
           let data = image.jpegData(compressionQuality: 0.8) {
            payload["image"] = [
                "base64": "data:image/jpeg;base64," + data.base64EncodedString()
            ]
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted]) else {
            print("❌ JSON serialization failed")
            return
        }

        let fileURL = folderURL.appendingPathComponent(filename)
        do {
            try jsonData.write(to: fileURL)
            print("✅ ログ保存成功: \(fileURL.path)")
        } catch {
            print("❌ ログ保存失敗: \(error)")
        }
    }
}
