//
//  TemplateManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/TemplateManager.swift
//
//  🎯 ファイルの目的:
//      Companion のテンプレート文言を言語別に取得するマネージャ。
//      - 言語コードに応じてテンプレート構造を切り替え、UIや音声に反映。
//      - CompanionGreetingEngine や CompanionNarrationEngine から呼び出される。
//      - CompanionTemplates_ja / CompanionTemplates_en などの構造体と連携。
//
//  🔗 依存:
//      - SupportedLanguage.swift（言語定義）
//      - CompanionTemplates_ja.swift など（テンプレート構造）
//      - LanguageManager.swift（選択言語）

import Foundation

class TemplateManager {
    static func templates(for language: SupportedLanguage) -> CompanionTemplates {
        switch language {
        case .ja: return CompanionTemplates_ja()
        case .en: return CompanionTemplates_en()
        case .zhHans: return CompanionTemplates_zhHans()
        case .zhHant: return CompanionTemplates_zhHant()
        case .fr: return CompanionTemplates_fr()
        case .ko: return CompanionTemplates_ko()
        case .hi: return CompanionTemplates_hi()
        case .de: return CompanionTemplates_de()
        case .es: return CompanionTemplates_es()
        case .pt: return CompanionTemplates_pt()
        case .th: return CompanionTemplates_th()
        case .ar: return CompanionTemplates_ar()
        }
    }
}
