//
//  DomainKnowledgeEngine.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Engine/DomainKnowledgeEngine.swift
//
//  🎯 目的:
//      全分野の知識エンジン（心臓部）。
//      - ConversationSubject を利用して話題を管理
//      - 各 NewsService を呼び出して記事を取得
//      - 発話と Core Data ログ保存を統合
//
//  🔗 依存:
//      - ConversationSubject.swift
//      - EmotionType.swift
//      - EmotionLogRepository.swift
//      - AVFoundation
//      - 各分野の Models / NewsService 群
//
//  👤 製作者: 津村 淳一
//  📅 改変日: 2025年10月15日
//

import Foundation
import Combine
import AVFoundation

final class DomainKnowledgeEngine: ObservableObject {
    @Published var currentSubject: ConversationSubject = ConversationSubject(label: "未設定")
    @Published var classification: String = ""
    @Published var articles: [String] = []

    private let synthesizer = AVSpeechSynthesizer()

    // ✅ 方法①適用：private → internal に変更
    /// 文学ニュースサービス（外部ビューから直接アクセス可能）
    let literatureNews = LiteratureNewsService()

    // 分類
    func classify(_ subject: ConversationSubject) {
        let t = subject.label
        switch true {
        case t.contains("文学"), t.contains("小説"), t.contains("詩"), t.contains("作家"):
            classification = "現代文学"
        default:
            classification = "一般ニュース"
        }
    }

    // ニュース取得
    func fetchNews(for subject: ConversationSubject) async {
        classify(subject)
        switch classification {
        case "現代文学":
            let items = await literatureNews.fetchLatest(for: .novel)
            articles = items.map { $0.title }
        default:
            articles = ["一般ニュースのダミー記事"]
        }
    }

    // 発話＋ログ保存
    func speakAndLog(text: String,
                     emotion: EmotionType,
                     ritual: String,
                     metadata: [String: Any] = [:]) {
        let u = AVSpeechUtterance(string: text)
        u.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        u.rate = 0.5
        synthesizer.speak(u)

        EmotionLogRepository.shared.saveLog(
            text: text,
            emotion: emotion,
            ritual: ritual,
            metadata: metadata
        )
    }
}
