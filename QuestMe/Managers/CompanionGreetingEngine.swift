//
//  CompanionGreetingEngine.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Engines/CompanionGreetingEngine.swift
//
//  🎯 ファイルの目的:
//      - CompanionStyle × LanguageOption に応じた挨拶文と操作説明を返す。
//      - 吹き出しと音声合成の強調語（emphasizedWords）も返す。
//      - GreetingBubbleView や CompanionGreetingView から使用される。
//
//  🔗 依存:
//      - CompanionStyle.swift
//      - LanguageOption.swift
//
//  👤 製作者: 津村 淳一
//  📅 作成日: 2025年10月16日
//

import Foundation

struct CompanionGreeting {
    let text: String
    let emphasizedWords: [String]
}

struct CompanionGreetingEngine {
    static let shared = CompanionGreetingEngine()

    func openingGreeting(for style: CompanionStyle, in lang: LanguageOption) -> CompanionGreeting {
        switch (style, lang.code) {
        case (.gentle, "ja"):
            return CompanionGreeting(
                text: "おかえりなさい。今日も一緒にがんばりましょうね。",
                emphasizedWords: ["おかえりなさい", "一緒に"]
            )
        case (.gentle, "en"):
            return CompanionGreeting(
                text: "Welcome back. Let's take it easy today.",
                emphasizedWords: ["Welcome", "easy"]
            )
        case (.logical, "ja"):
            return CompanionGreeting(
                text: "状況を整理して、最適な選択を始めましょう。",
                emphasizedWords: ["整理", "最適"]
            )
        case (.logical, "en"):
            return CompanionGreeting(
                text: "Let's analyze the situation and begin with clarity.",
                emphasizedWords: ["analyze", "clarity"]
            )
        case (.poetic, "ja"):
            return CompanionGreeting(
                text: "朝露が光るこの瞬間、あなたの一日が輝きますように。",
                emphasizedWords: ["朝露", "輝きます"]
            )
        case (.poetic, "en"):
            return CompanionGreeting(
                text: "As morning dew glistens, may your day shine with grace.",
                emphasizedWords: ["glistens", "shine"]
            )
        // 他スタイル・言語も順次追加可能
        default:
            return CompanionGreeting(
                text: lang.code == "ja" ? "こんにちは。" : "Hello.",
                emphasizedWords: []
            )
        }
    }

    func openingInstruction(for style: CompanionStyle, in lang: LanguageOption) -> CompanionGreeting {
        switch (style, lang.code) {
        case (.gentle, "ja"):
            return CompanionGreeting(
                text: "この画面では、私が優しく挨拶します。操作は不要です。",
                emphasizedWords: ["優しく", "操作"]
            )
        case (.gentle, "en"):
            return CompanionGreeting(
                text: "This screen is just for a gentle greeting. No action needed.",
                emphasizedWords: ["gentle", "No action"]
            )
        case (.logical, "ja"):
            return CompanionGreeting(
                text: "この画面は挨拶フェーズです。次のステップは自動で案内されます。",
                emphasizedWords: ["挨拶フェーズ", "自動"]
            )
        case (.logical, "en"):
            return CompanionGreeting(
                text: "This is the greeting phase. The next step will be guided automatically.",
                emphasizedWords: ["greeting phase", "automatically"]
            )
        case (.poetic, "ja"):
            return CompanionGreeting(
                text: "言葉の余韻を感じながら、静かに始めましょう。",
                emphasizedWords: ["余韻", "静かに"]
            )
        case (.poetic, "en"):
            return CompanionGreeting(
                text: "Let the words linger as we begin softly.",
                emphasizedWords: ["linger", "softly"]
            )
        default:
            return CompanionGreeting(
                text: lang.code == "ja" ? "この画面では、挨拶のみが行われます。" : "This screen is for greeting only.",
                emphasizedWords: []
            )
        }
    }
}
