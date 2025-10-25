//
//  LabResult.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/LabResult.swift
//
//  🎯 ファイルの目的:
//      検査結果データのモデル定義（複数項目対応）
//      - LabItem を配列で保持
//      - OCRや履歴表示、アドバイス生成に利用
//
//  🔗 連動:
//      - Models/LabItem.swift
//      - Managers/LabResultStorageManager.swift
//      - Views/Lab/LaboView.swift
//      - Views/Lab/LabHistoryView.swift
//      - Views/Lab/LabAdviceView.swift
//
//  👤 作成者: 津村 淳一
//  📅 改変日: 2025年10月24日
//

import Foundation

struct LabResult: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var items: [LabItem]          // 検査項目の配列
    var notes: String?            // AI解析コメントなど
    var emotion: String?          // VoiceIntentRouter 用

    /// JSON保存用の辞書化
    func toDictionary() -> [String: Any] {
        [
            "id": id.uuidString,
            "date": ISO8601DateFormatter().string(from: date),
            "items": items.map { [
                "id": $0.id.uuidString,
                "name": $0.name,
                "value": $0.value,
                "unit": $0.unit ?? "",
                "range": $0.referenceRange ?? "",
                "abnormal": $0.isAbnormal ?? false
            ]},
            "notes": notes ?? "",
            "emotion": emotion ?? ""
        ]
    }
}
