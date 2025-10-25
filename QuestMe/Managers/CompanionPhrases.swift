//
//  CompanionPhrases.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/Companion/CompanionPhrases.swift
//
//  🎯 ファイルの目的:
//      運動シーンごとに複数の励ましフレーズを用意し、ランダムに返すユーティリティ。
//      - 開始・中・終了・振り返りの4場面に対応。
//      - ユーザーの記録データに応じて動的にメッセージを生成可能。
//      - CompanionOverlay や ExerciseStorageManager から呼び出される。
//
//  🔗 依存:
//      - ExerciseScene（場面定義）
//      - ExerciseStorageManager.swift（記録連動）
//      - CompanionOverlay.swift（音声表示）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import Foundation

enum ExerciseScene {
    case start
    case during
    case finish
    case review(totalCalories: Double, days: Int)
}

struct CompanionPhrases {
    static func phrase(for scene: ExerciseScene) -> String {
        switch scene {
        case .start:
            let options = [
                "よし、冒険の始まりです！今日はどんな一歩を刻みますか？",
                "準備は整いましたか？一緒にリズムを作っていきましょう。",
                "深呼吸して、最初の一歩を踏み出しましょう。"
            ]
            return options.randomElement()!

        case .during:
            let options = [
                "その調子！体が軽くなってきましたね。",
                "あと少しで区切りです、集中していきましょう。",
                "いいリズムです！呼吸を意識して。"
            ]
            return options.randomElement()!

        case .finish:
            let options = [
                "お疲れさまでした！今日の努力は確かに記録されました。",
                "素晴らしい！未来の自分に贈り物をしましたね。",
                "今日もよく頑張りました。続ける力があなたの強さです。"
            ]
            return options.randomElement()!

        case .review(let totalCalories, let days):
            let options = [
                "見てください、この積み重ね。あなたの努力が形になっています。",
                "\(days)日間で合計 \(Int(totalCalories)) kcal を消費しました！誇っていい成果です。",
                "昨日より今日、今日より明日──確実に前進しています。"
            ]
            return options.randomElement()!
        }
    }
}
