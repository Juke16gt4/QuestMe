//
//  MainTabView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/MainTabView.swift
//
//  🎯 ファイルの目的:
//      全分野の View を統合し、タブ切り替えでアクセス可能にする。
//      - 各分野の View を TabView に登録
//      - DomainKnowledgeEngine を EnvironmentObject として共有
//
//  🔗 依存:
//      - DomainKnowledgeEngine.swift
//      - ConversationSubject.swift
//      - 各分野の View 群
//
//  👤 製作者: 津村 淳一
//  📅 作成日: 2025年10月15日
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var engine = DomainKnowledgeEngine()

    var body: some View {
        TabView {
            ArtsMusicView()
                .tabItem {
                    Label("芸術・音楽", systemImage: "paintpalette")
                }

            ClassicsView()
                .tabItem {
                    Label("古典・歴史", systemImage: "book.closed")
                }

            EconomicsView()
                .tabItem {
                    Label("経済", systemImage: "chart.bar")
                }

            PsychologyView()
                .tabItem {
                    Label("心理・福祉", systemImage: "brain.head.profile")
                }

            NaturalScienceView()
                .tabItem {
                    Label("自然科学", systemImage: "atom")
                }

            RehabSportsView()
                .tabItem {
                    Label("リハビリ・スポーツ", systemImage: "figure.run")
                }

            SocialWelfareView()
                .tabItem {
                    Label("社会福祉", systemImage: "person.3")
                }

            StocksView()
                .tabItem {
                    Label("株式", systemImage: "chart.line.uptrend.xyaxis")
                }

            CertificationsView()
                .tabItem {
                    Label("資格", systemImage: "checkmark.seal")
                }

            InternationalView()
                .tabItem {
                    Label("国際", systemImage: "globe")
                }

            LiteratureView()
                .tabItem {
                    Label("現代文学", systemImage: "text.book.closed")
                }
        }
        .environmentObject(engine) // 全 View にエンジンを共有
    }
}
