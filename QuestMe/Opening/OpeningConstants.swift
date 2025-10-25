//
//  OpeningConstants.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Opening/OpeningConstants.swift
//
//  🎯 ファイルの目的:
//      オープニング儀式で使用する定数群。
//      - 音声ファイル名、表示タイミング、言語コード、ラベル文言、初期挨拶など。
//      - UI非依存で、演出・言語・音声の統一管理を担う。
//
//  🔗 依存:
//      - AudioReactiveLogoView.swift（音声ファイル名）
//      - LogoView.swift（挨拶文）
//      - LanguageSetupView.swift（言語コード）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月27日

import Foundation

enum OpeningConstants {
    // 表示・タイミング
    static let logoDisplayDuration: TimeInterval = 3.0

    // サウンド
    static let openingSoundFileName = "questme_flute_intro"
    static let openingSoundExtension = "mp3"
    static let openingSoundDefaultVolume: Float = 0.4

    // 言語（初期デフォルト）
    static let defaultLanguageCode = "ja"

    // ボタンラベル（必要に応じてLocalizable.stringsへ移行）
    static let labelUnderstood = "Understood"
    static let labelNoThanks = "No Thanks"
    static let labelOK = "OK"
    static let labelStartAdventure = "冒険を始める"

    // 挨拶（初期版：後にLocalizationへ移行）
    static let companionGreetingJP = """
    はじめまして。QuestMeの世界へようこそ。
    この世界は、自分の能力や生活を見つめ直す旅です。
    わたしは、あなたのそばで寄り添いながら、
    あなた自身への目覚めへと導いていきます。
    それでは──良い旅を。
    """

    static let companionGreetingEN = """
    Welcome to the world of QuestMe.
    This is a journey to rediscover your abilities and your life.
    I’ll be by your side, guiding you toward awakening to yourself.
    Let’s begin your adventure.
    """
}
