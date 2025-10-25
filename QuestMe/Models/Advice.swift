//
//  Advice.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/Advice.swift
//
//  🎯 ファイルの目的:
//      - ユーザーのアドバイスデータを表現するモデル。
//      - CompanionAdviceView や AdviceStorageManager から利用される。
//      - 保存・読み込み・表示に必要な最低限の情報を保持する。
//
//  🧑‍💻 作成者: 津村 淳一 (Junichi Tsumura)
//  🗓️ 製作日時: 2025-10-10 JST
//
//  🔗 依存先:
//      - Foundation（UUID, Date, Codable 利用のため）
//      - AdviceStorageManager（保存・読み込み処理で利用）
//      - CompanionAdviceView（UI 表示で利用）
//

import Foundation

/// アドバイスデータモデル
struct Advice: Codable, Identifiable {
    /// 一意識別子
    var id = UUID()
    /// アドバイス本文
    var text: String
    /// 作成日時
    var date: Date
}
