//
//  CompanionApp.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/App/CompanionApp.swift
//
//  🎯 ファイルの目的:
//      アプリのエントリーポイント。
//      - 環境依存オブジェクト（StorageService, TopicClassifier, EthicalFilter, NewsService, SpeechSync, ReflectionService, LocalizationManager）の初期化。
//      - MainView に環境オブジェクトを注入し、アプリ全体で利用可能にする。
//      - ReflectionService と SpeechSync のバインドを行う。
//
//  🔗 依存:
//      - StorageService.swift
//      - TopicClassifier.swift
//      - EthicalFilter.swift
//      - NewsService.swift
//      - SpeechSync.swift
//      - ReflectionService.swift
//      - LocalizationManager.swift
//      - MainView.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import SwiftUI

@main
struct CompanionApp: App {
    @StateObject private var storage = StorageService()
    @StateObject private var topics = TopicClassifier()
    @StateObject private var ethics = EthicalFilter()
    @StateObject private var news = NewsService()
    @StateObject private var speech = SpeechSync()
    @StateObject private var reflector = ReflectionService()
    @StateObject private var locale = LocalizationManager()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(storage)
                .environmentObject(topics)
                .environmentObject(ethics)
                .environmentObject(news)
                .environmentObject(speech)
                .environmentObject(reflector)
                .environmentObject(locale)
                .onAppear {
                    reflector.bindServices(storage: storage, speech: speech)
                }
        }
    }
}
