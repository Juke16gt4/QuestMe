//
//  MedicationAdviceResponder.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Responder/MedicationAdviceResponder.swift
//
//  🎯 目的:
//      ユーザーの質問に応じて、適切な服薬アドバイスと感情分類を返す。
//      - TemplateAdviceResponder（テンプレートベース）
//      - LLMAdviceResponder（自然言語応答）
//      - モック・テスト用の切り替えも可能
//
//  🔗 連動:
//      - MedicationAdviceView.swift（注入先）
//      - MedicationEmotionLogger.swift（感情ログ）
//      - EmotionType.swift（UI連動）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月23日

import Foundation

public protocol MedicationAdviceResponder {
    func generateResponse(for question: String, langCode: String) -> String
    func emotionFor(question: String) -> MedicationEmotionLogger.MedicationEmotion
}

public final class TemplateAdviceResponder: MedicationAdviceResponder {
    public init() {}

    public func generateResponse(for question: String, langCode: String) -> String {
        let lowercased = question.lowercased()

        if lowercased.contains("なぜ") || lowercased.contains("続け") || lowercased.contains("必要") {
            return adviceWhyContinue(langCode)
        } else if lowercased.contains("減ら") || lowercased.contains("やめ") || lowercased.contains("少なく") {
            return adviceHowToReduce(langCode)
        } else if lowercased.contains("副作用") || lowercased.contains("こわい") || lowercased.contains("不安") {
            return adviceSideEffects(langCode)
        } else if lowercased.contains("医師") || lowercased.contains("質問") || lowercased.contains("聞く") {
            return adviceHowToAskDoctor(langCode)
        } else if lowercased.contains("つらい") || lowercased.contains("続けられ") || lowercased.contains("疲れ") {
            return adviceMotivation(langCode)
        } else {
            return langCode == "ja"
                ? "その件について調べてみますね。少々お待ちください。"
                : "Let me look into that for you. Please hold on a moment."
        }
    }

    public func emotionFor(question: String) -> MedicationEmotionLogger.MedicationEmotion {
        let lowercased = question.lowercased()

        if lowercased.contains("なぜ") || lowercased.contains("続け") || lowercased.contains("必要") {
            return .encouraging
        } else if lowercased.contains("減ら") || lowercased.contains("やめ") || lowercased.contains("少なく") {
            return .thinking
        } else if lowercased.contains("副作用") || lowercased.contains("こわい") || lowercased.contains("不安") {
            return .feltAnxious
        } else if lowercased.contains("医師") || lowercased.contains("質問") || lowercased.contains("聞く") {
            return .gentle
        } else if lowercased.contains("つらい") || lowercased.contains("続けられ") || lowercased.contains("疲れ") {
            return .sad
        } else {
            return .neutral
        }
    }

    // MARK: - テンプレート群（言語切替対応）
    private func adviceWhyContinue(_ lang: String) -> String {
        return lang == "ja"
            ? "この薬は、症状を抑えるだけでなく、合併症の進展を防ぐためにも重要です。..."
            : "This medicine not only controls symptoms but also prevents complications..."
    }

    private func adviceHowToReduce(_ lang: String) -> String {
        return lang == "ja"
            ? "薬を減らすには、生活習慣の見直しが必要なんです。...食事、運動の記録をこちらに残しておけば、どのように見直せば良いかお話しできますよ。"
            : "Improving your lifestyle can help your doctor consider reducing your medication..."
    }

    private func adviceSideEffects(_ lang: String) -> String {
        return lang == "ja"
            ? "副作用が心配なときは、症状を記録して医師に伝えるのが大切です。...どんな副作用が出そうなのかご心配ですよね。そんなときは私があらかじめお答えすることが出来ますから、悩んだときはいつでも質問しても良いですよ。"
            : "If you’re worried about side effects, keep a record and share it with your doctor..."
    }

    private func adviceHowToAskDoctor(_ lang: String) -> String {
        return lang == "ja"
            ? "診察のときは『この薬はいつまで飲まないといけませんか？』と主治医に質問するのもよいでしょう。"
            : "Before your appointment, jot down questions like 'How long will I take this?'..."
    }

    private func adviceMotivation(_ lang: String) -> String {
        return lang == "ja"
            ? "続けるのがつらいと感じるときもありますよね。でも、あなたの体はおくすりで守られているのですよ。"
            : "It’s okay to feel tired of continuing. Your body is being protected..."
    }
}
