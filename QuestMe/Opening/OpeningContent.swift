//
//  OpeningContent.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Opening/OpeningContent.swift
//
//  🎯 ファイルの目的:
//      オープニング儀式で表示する文言や演出用テキストを一元管理。
//      - OpeningConstants.swift が担う定数群と補完関係にある。
//      - Companion の初回挨拶や UI に表示するキャッチコピーを保持。
//      - OpeningFlowView から参照される。
//
//  🔗 依存:
//      - OpeningConstants.swift（音声・ラベル定数）
//      - LanguageOption.swift（言語定義）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月15日
//

import Foundation

enum OpeningContent {
    // アプリタイトル
    static let appTitle = "QuestMe"

    // サブタイトル・キャッチコピー
    static let subtitle = "自分を見つめ直す旅へ"

    // 初回表示用の詩的なフレーズ
    static let poeticIntro = """
    これは、あなた自身の物語。
    一歩を踏み出すことで、世界は変わり始めます。
    """

    // 言語ごとの初回挨拶（OpeningConstants と連携）
    static func greeting(for code: String) -> String {
        switch code {
        case "ja":
            return OpeningConstants.companionGreetingJP
        case "en":
            return OpeningConstants.companionGreetingEN
        default:
            return "Welcome to QuestMe."
        }
    }
}
