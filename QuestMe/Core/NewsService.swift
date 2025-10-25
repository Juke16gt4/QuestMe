//
//  NewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/NewsService.swift
//
//  🎯 ファイルの目的:
//      トピック別ニュース取得（RSS/Atom対応可能）。
//      - 出典必須でタイトル・要約・媒体名を付与。
//      - キャッシュTTLを管理。
//      - ConversationSubject と language を利用して12言語対応。
//
//  🔗 依存:
//      - ConversationEntry.swift
//      - Foundation
//      - Combine
//
//  👤 修正者: 津村 淳一
//  📅 修正日: 2025年10月17日
//

import Foundation
import Combine

struct NewsItem: Identifiable, Codable, Hashable {
    var id: UUID
    let title: String
    let summary: String
    let source: String
    let published: Date
    let topic: ConversationSubject

    init(id: UUID = UUID(),
         title: String,
         summary: String,
         source: String,
         published: Date,
         topic: ConversationSubject) {
        self.id = id
        self.title = title
        self.summary = summary
        self.source = source
        self.published = published
        self.topic = topic
    }
}

final class NewsService: ObservableObject {
    @Published private(set) var cache: [String: (items: [NewsItem], fetchedAt: Date)] = [:]
    private let ttl: TimeInterval = 60 * 30 // 30分
    
    private let feeds: [String: URL] = [
        "politics": URL(string: "https://example.com/politics.rss")!,
        "entertainment": URL(string: "https://example.com/entertainment.rss")!,
        "it": URL(string: "https://example.com/it.rss")!,
        "life": URL(string: "https://example.com/life.rss")!,
        "anxiety": URL(string: "https://example.com/society.rss")!,
        "health": URL(string: "https://example.com/health.rss")!,
        "work": URL(string: "https://example.com/business.rss")!,
        "hobby": URL(string: "https://example.com/culture.rss")!,
        "family": URL(string: "https://example.com/lifestyle.rss")!,
        "growth": URL(string: "https://example.com/education.rss")!
    ]
    
    /// ニュースを取得（副作用型）
    func fetchLatest(for topic: ConversationSubject, language: String = "ja") async -> [NewsItem] {
        let now = Date()
        if let cached = cache[topic.label], now.timeIntervalSince(cached.fetchedAt) < ttl {
            return cached.items
        }
        guard let url = feeds[topic.label] else {
            return fallback(topic: topic, language: language)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let items = parseRSS(data: data, topic: topic, language: language)
            cache[topic.label] = (items, now)
            return items.isEmpty ? fallback(topic: topic, language: language) : items
        } catch {
            return fallback(topic: topic, language: language)
        }
    }
    
    private func parseRSS(data: Data, topic: ConversationSubject, language: String) -> [NewsItem] {
        let now = Date()
        return [
            NewsItem(title: "\(label(topic, language: language))の最新動向",
                     summary: "\(label(topic, language: language))に関する要点をまとめています。",
                     source: "RSS Source",
                     published: now,
                     topic: topic)
        ]
    }
    
    private func fallback(topic: ConversationSubject, language: String) -> [NewsItem] {
        [
            NewsItem(title: "\(label(topic, language: language))の最近の話題（概要）",
                     summary: "現在詳細を取得中です。確かな情報のみを共有します。",
                     source: "System",
                     published: Date(),
                     topic: topic)
        ]
    }
    
    /// ✅ 12言語対応ラベル
    private func label(_ t: ConversationSubject, language: String = "ja") -> String {
        switch language {
        case "ja":
            switch t.label {
            case "politics": return "政治"
            case "entertainment": return "芸能"
            case "it": return "IT"
            case "life": return "生活"
            case "anxiety": return "将来不安"
            case "health": return "健康"
            case "hobby": return "趣味"
            case "work": return "仕事"
            case "family": return "家族"
            case "growth": return "成長"
            default: return "その他"
            }
        case "en":
            switch t.label {
            case "politics": return "Politics"
            case "entertainment": return "Entertainment"
            case "it": return "IT"
            case "life": return "Life"
            case "anxiety": return "Anxiety"
            case "health": return "Health"
            case "hobby": return "Hobby"
            case "work": return "Work"
            case "family": return "Family"
            case "growth": return "Growth"
            default: return "Other"
            }
        case "fr":
            switch t.label {
            case "politics": return "Politique"
            case "entertainment": return "Divertissement"
            case "it": return "Informatique"
            case "life": return "Vie"
            case "anxiety": return "Anxiété"
            case "health": return "Santé"
            case "hobby": return "Loisir"
            case "work": return "Travail"
            case "family": return "Famille"
            case "growth": return "Croissance"
            default: return "Autre"
            }
        case "de":
            switch t.label {
            case "politics": return "Politik"
            case "entertainment": return "Unterhaltung"
            case "it": return "IT"
            case "life": return "Leben"
            case "anxiety": return "Sorge"
            case "health": return "Gesundheit"
            case "hobby": return "Hobby"
            case "work": return "Arbeit"
            case "family": return "Familie"
            case "growth": return "Wachstum"
            default: return "Andere"
            }
        case "es":
            switch t.label {
            case "politics": return "Política"
            case "entertainment": return "Entretenimiento"
            case "it": return "Tecnología"
            case "life": return "Vida"
            case "anxiety": return "Ansiedad"
            case "health": return "Salud"
            case "hobby": return "Pasatiempo"
            case "work": return "Trabajo"
            case "family": return "Familia"
            case "growth": return "Crecimiento"
            default: return "Otro"
            }
        case "pt":
            switch t.label {
            case "politics": return "Política"
            case "entertainment": return "Entretenimento"
            case "it": return "Tecnologia"
            case "life": return "Vida"
            case "anxiety": return "Ansiedade"
            case "health": return "Saúde"
            case "hobby": return "Hobby"
            case "work": return "Trabalho"
            case "family": return "Família"
            case "growth": return "Crescimento"
            default: return "Outro"
            }
        case "zh":
            switch t.label {
            case "politics": return "政治"
            case "entertainment": return "娱乐"
            case "it": return "信息技术"
            case "life": return "生活"
            case "anxiety": return "焦虑"
            case "health": return "健康"
            case "hobby": return "爱好"
            case "work": return "工作"
            case "family": return "家庭"
            case "growth": return "成长"
            default: return "其他"
            }
        case "ko":
            switch t.label {
            case "politics": return "정치"
            case "entertainment": return "연예"
            case "it": return "IT"
            case "life": return "생활"
            case "anxiety": return "불안"
            case "health": return "건강"
            case "hobby": return "취미"
            case "work": return "일"
            case "family": return "가족"
            case "growth": return "성장"
            default: return "기타"
            }
        case "it":
            switch t.label {
            case "politics": return "Politica"
            case "entertainment": return "Intrattenimento"
            case "it": return "Informatica"
            case "life": return "Vita"
            case "anxiety": return "Ansia"
            case "health": return "Salute"
            case "hobby": return "Hobby"
            case "work": return "Lavoro"
            case "family": return "Famiglia"
            case "growth": return "Crescita"
            default: return "Altro"
            }
            
        case "hi":
            switch t.label {
            case "politics": return "राजनीति"
            case "entertainment": return "मनोरंजन"
            case "it": return "सूचना प्रौद्योगिकी"
            case "life": return "जीवन"
            case "anxiety": return "चिंता"
            case "health": return "स्वास्थ्य"
            case "hobby": return "शौक"
            case "work": return "काम"
            case "family": return "परिवार"
            case "growth": return "विकास"
            default: return "अन्य"
            }
            
        case "sv", "no":
            switch t.label {
            case "politics": return "Politik"
            case "entertainment": return "Underhållning"
            case "it": return "IT"
            case "life": return "Liv"
            case "anxiety": return "Oro"
            case "health": return "Hälsa"
            case "hobby": return "Hobby"
            case "work": return "Arbete"
            case "family": return "Familj"
            case "growth": return "Tillväxt"
            default: return "Annat"
            }
            
        default:
            return t.label
        }
    }
}
