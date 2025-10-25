//
//  LanguageManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/LanguageManager.swift
//
//  🎯 ファイルの目的:
//      アプリ全体の言語設定を管理するシングルトン。
//      - iPhone売上上位20カ国から抽出した主要12言語をサポート。
//      - UserDefaults に保存・復元し、SwiftUI から監視可能。
//      - localizedString(for:) により簡易ローカライズを提供。
//
//  🔗 依存:
//      - UserDefaults（保存）
//      - SwiftUI / Combine（監視）
//      - LogoView.swift / MotherTongueSelectionView.swift（表示）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月2日

import Foundation
import Combine

final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    private let storageKey = "QuestMe.selectedLanguage"

    // ✅ 商用化対応: iPhone売上上位国から抽出した12言語
    let supportedLanguages: [String] = [
        "en",       // 英語（US, UK, Canada, Australia, Singapore）
        "zh-Hans",  // 中国語（簡体字：中国本土、シンガポール）
        "zh-Hant",  // 中国語（繁体字：香港、台湾）
        "ja",       // 日本語（日本）
        "de",       // ドイツ語（ドイツ）
        "fr",       // フランス語（フランス、カナダ一部）
        "ko",       // 韓国語（韓国）
        "es",       // スペイン語（スペイン、メキシコ）
        "pt",       // ポルトガル語（ブラジル）
        "th",       // タイ語（タイ）
        "ar",       // アラビア語（UAE）
        "hi"        // ヒンディー語（インド）
    ]

    @Published var selectedLanguage: String {
        didSet { UserDefaults.standard.set(selectedLanguage, forKey: storageKey) }
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: storageKey),
           supportedLanguages.contains(saved) {
            selectedLanguage = saved
        } else {
            selectedLanguage = "en" // デフォルトは英語
        }
    }

    // 簡易ローカライズ例
    func localizedString(for key: String) -> String {
        switch key {
        case "welcome":
            switch selectedLanguage {
            case "ja": return "ようこそ"
            case "en": return "Welcome"
            case "fr": return "Bienvenue"
            case "de": return "Willkommen"
            case "es": return "Bienvenido"
            case "pt": return "Bem-vindo"
            case "ko": return "환영합니다"
            case "ru": return "Добро пожаловать" // 予備（未使用）
            case "zh-Hans": return "欢迎"
            case "zh-Hant": return "歡迎"
            case "th": return "ยินดีต้อนรับ"
            case "ar": return "أهلاً وسهلاً"
            case "hi": return "स्वागत है"
            default: return key
            }
        default:
            return key
        }
    }
}
