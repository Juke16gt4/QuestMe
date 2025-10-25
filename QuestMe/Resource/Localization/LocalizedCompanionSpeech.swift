//
//  LocalizedCompanionSpeech.swift
//  QuestMe
//
//  Created by 淳一 on 2025/09/30.
//  このファイルは言語別のCompanionセリフを管理し、文化的共鳴を生む
//

import Foundation

public struct LocalizedCompanionSpeech {
    public static func greeting(for language: String) -> String {
        switch language {
        case "ja": return "こんにちは、私はあなたのコンパニオンです"
        case "en": return "Hello, I'm your companion"
        case "fr": return "Bonjour, je suis votre compagnon"
        case "zh": return "你好，我是你的伙伴"
        case "de": return "Hallo, ich bin dein Begleiter"
        case "ko": return "안녕하세요, 저는 당신의 동반자입니다"
        case "hi": return "नमस्ते, मैं आपका साथी हूँ"
        case "sv": return "Hej, jag är din följeslagare"
        case "no": return "Hei, jeg er din følgesvenn"
        default: return "Hello"
        }
    }
}
