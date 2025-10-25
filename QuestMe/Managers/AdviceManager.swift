//
//  AdviceManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/AdviceManager.swift
//
//  🎯 ファイルの目的:
//      - ユーザー入力や外部要因からアドバイスを生成する責務を持つ。
//      - 現段階ではスタブ実装として、入力テキストをそのまま Advice に変換する。
//      - 将来的には AI やアルゴリズムによるアドバイス生成ロジックを追加予定。
//
//  🧑‍💻 作成者: 津村 淳一 (Junichi Tsumura)
//  🗓️ 製作日時: 2025-10-10 JST
//
//  🔗 依存先:
//      - Foundation（Date, UUID 利用のため）
//      - Models/Advice.swift（生成対象のデータモデル）
//

import Foundation

final class AdviceManager {
    /// 入力テキストからアドバイスを生成する（スタブ実装）
    func generateAdvice(from text: String) -> Advice {
        return Advice(text: text, date: Date())
    }
}
