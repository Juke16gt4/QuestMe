//
//  CompanionOverlay+Confirmation.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/CompanionOverlay+Confirmation.swift
//
//  🎯 ファイルの目的:
//      CompanionOverlay に「確認待ち」機能を追加する拡張。
//      - ユーザーに「はい／いいえ」で答えさせ、結果をハンドラに返す。
//      - EditSessionManager から呼び出され、変更適用前の確認に利用される。
//      - CompanionOverlay の音声合成と SpeechRecognizer を統合して動作。
//      - 将来的には UI 側で「はい／いいえ」ボタンを併用可能にする。
//
//  🔗 依存:
//      - CompanionOverlay.swift（音声発話基盤）
//      - SpeechRecognizer.swift（音声入力）
//      - EditSessionManager.swift（確認呼び出し元）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import Foundation

extension CompanionOverlay {
    /// ユーザーに「はい／いいえ」で確認を求める
    /// - Parameter handler: true = 承認, false = 拒否
    func awaitConfirmation(handler: @escaping (Bool) -> Void) {
        // 確認プロンプトを発話
        speak("はい、または、いいえで答えてください。", emotion: .confused)

        // 音声認識を開始
        SpeechRecognizer.shared.start { transcript in
            let lower = transcript.lowercased()
            if lower.contains("はい") || lower.contains("yes") {
                handler(true)
            } else if lower.contains("いいえ") || lower.contains("no") {
                handler(false)
            } else {
                // 判定不能時は再度確認
                self.speak("すみません、はい か いいえ で答えてください。", emotion: .confused)
                self.awaitConfirmation(handler: handler)
            }
        }
    }
}
