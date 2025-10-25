//  MeetingManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/Meeting/MeetingManager.swift
//
//  🎯 ファイルの目的:
//      - ミーティング進行を管理する。
//      - CompanionOverlay を通じて感情表現と音声ガイドを提供する。
//      - 状況に応じて感情を切り替え、ユーザーにフィードバックを返す。
//
//  🔗 依存ファイル:
//      - Foundation
//      - Overlay/CompanionOverlay.swift
//          → CompanionOverlay.shared.speak() を利用
//      - Models/CompanionEmotion.swift
//          → CompanionEmotion の各ケースを利用
//
//  👤 作成者: Tsumura Junichi
//  🗓 作成日: 2025/10/10
//

import Foundation

class MeetingManager {
    func startMeeting() {
        // 例: ミーティング開始時に励ましの言葉を発話
        CompanionOverlay.shared.speak("Let's begin the meeting!", emotion: EmotionType.encouraging)
    }

    func handleIssue() {
        // 例: 問題発生時に悲しい感情で発話
        CompanionOverlay.shared.speak("We encountered an issue.", emotion: EmotionType.sad)
    }

    func wrapUp() {
        // 例: 終了時にニュートラルな感情で発話
        CompanionOverlay.shared.speak("The meeting has ended.", emotion: EmotionType.neutral)
    }
}
