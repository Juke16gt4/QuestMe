//
//  LanguageOption.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/LanguageOption.swift
//
//  🎯 ファイルの目的:
//      アプリ全体で取り扱う母国語の定義を一元管理する構造体。
//      - 表示名・言語コード・音声合成用コード・ウェルカム文言を保持。
//      - Picker や Companion 表示、音声再生、国際法掲示などに利用。
//      - 12言語を正規サポート対象とし、LanguageManager 経由で参照される。
//
//  🔗 依存:
//      - LanguageManager.swift（状態管理）
//      - SpeechManager.swift（音声合成）
//      - AgreementView.swift（法的表示）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月1日

import Foundation

struct LanguageOption: Identifiable, Equatable, Hashable {
    let id = UUID()
    let code: String
    let name: String
    let speechCode: String
    let welcome: String
}

extension LanguageOption {
    static let all: [LanguageOption] = [
        LanguageOption(code: "ja", name: "日本語", speechCode: "ja-JP", welcome: "ようこそ"),
        LanguageOption(code: "en", name: "English", speechCode: "en-US", welcome: "Welcome"),
        LanguageOption(code: "fr", name: "Français", speechCode: "fr-FR", welcome: "Bienvenue"),
        LanguageOption(code: "de", name: "Deutsch", speechCode: "de-DE", welcome: "Willkommen"),
        LanguageOption(code: "es", name: "Español", speechCode: "es-ES", welcome: "Bienvenido"),
        LanguageOption(code: "zh", name: "中文", speechCode: "zh-CN", welcome: "欢迎"),
        LanguageOption(code: "ko", name: "한국어", speechCode: "ko-KR", welcome: "환영합니다"),
        LanguageOption(code: "it", name: "Italiano", speechCode: "it-IT", welcome: "Benvenuto"),
        LanguageOption(code: "pt", name: "Português", speechCode: "pt-PT", welcome: "Bem-vindo"),
        LanguageOption(code: "sv", name: "Svenska", speechCode: "sv-SE", welcome: "Välkommen"),
        LanguageOption(code: "hi", name: "हिन्दी", speechCode: "hi-IN", welcome: "स्वागत है"),
        LanguageOption(code: "no", name: "Norsk", speechCode: "no-NO", welcome: "Velkommen")
    ]
}
