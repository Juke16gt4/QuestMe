//
//  SupportedLanguage.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Companion/Core/SupportedLanguage.swift
//
//  🎯 ファイルの目的:
//      CompanionテンプレートやUI表示に使用する言語情報を一元管理する列挙型。
//      - LanguageManager.swift の supportedLanguages に準拠。
//      - 表示名や言語コードの整合性を保証。
//      - CompanionTemplates.swift や TemplateManager.swift で使用。
//
//  🔗 依存:
//      - LanguageManager.swift（選択言語）
//      - TemplateManager.swift（テンプレート分岐）
//      - CompanionGreetingView.swift（表示）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月29日
import Foundation

public enum SupportedLanguage: String, CaseIterable, Identifiable {
    case en        // 英語
    case zhHans    // 中国語（簡体字）
    case zhHant    // 中国語（繁体字）
    case ja        // 日本語
    case de        // ドイツ語
    case fr        // フランス語
    case ko        // 韓国語
    case es        // スペイン語
    case pt        // ポルトガル語
    case th        // タイ語
    case ar        // アラビア語
    case hi        // ヒンディー語

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .en: return "English"
        case .zhHans: return "中文（简体）"
        case .zhHant: return "中文（繁體）"
        case .ja: return "日本語"
        case .de: return "Deutsch"
        case .fr: return "Français"
        case .ko: return "한국어"
        case .es: return "Español"
        case .pt: return "Português"
        case .th: return "ไทย"
        case .ar: return "العربية"
        case .hi: return "हिन्दी"
        }
    }

    /// LanguageManager.swift の supportedLanguages に準拠した一覧
    public static var all: [SupportedLanguage] {
        return Self.allCases
    }
}
