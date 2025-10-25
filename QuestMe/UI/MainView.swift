//
//  MainView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/MainView.swift
//
//  🎯 ファイルの目的:
//      入出力UIの統合（資格取得分野対応）。
//      - ユーザー入力を保存→資格分類→ニュース取得→免責文付与→表現安全化→音声同期→ログ保存。
//      - 資格取得（国内/国際）に関する話題も通常モードで対応。
//      - コンパニオン発話を1.4倍で表示。
//      - 削除試行時は警告を表示し、音声で通知。
//
//  🔗 依存:
//      - SwiftUI
//      - AVFoundation
//      - StorageService.swift
//      - CertificationTopicClassifier.swift
//      - CertificationEthicsPolicy.swift
//      - CertificationNewsService.swift
//      - SpeechSync.swift
//      - ReflectionService.swift
//      - TriggerManager.swift
//      - LocalizationManager.swift
//      - ConversationEntry.swift
//
//  👤 修正者: 津村 淳一
//  📅 修正日: 2025年10月23日
//

import SwiftUI
import AVFoundation

struct MainView: View {
    @EnvironmentObject var storage: StorageService
    @EnvironmentObject var certifier: CertificationTopicClassifier
    @EnvironmentObject var ethics: CertificationEthicsPolicy
    @EnvironmentObject var news: CertificationNewsService
    @EnvironmentObject var speech: SpeechSync
    @EnvironmentObject var reflector: ReflectionService
    @EnvironmentObject var locale: LocalizationManager

    @State private var userInput: String = ""
    @State private var deletionWarning: String?
    private let triggerManager = TriggerManager()

    var body: some View {
        VStack(spacing: 12) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(storage.loadAll().filter { $0.speaker == "companion" }, id: \.id) { entry in
                        CompanionPhraseView(
                            phrase: entry.text,
                            emotion: EmotionType(rawValue: entry.emotion) ?? .neutral
                        )
                        .scaleEffect(x: 1.0, y: 1.4, anchor: .topLeading)
                    }
                }
                .padding(.horizontal)
            }

            HStack {
                TextField("ここに入力してください", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: 18))
                Button("送信") { handleUserInput() }
            }
            .padding(.horizontal)

            if let warning = deletionWarning {
                Text(warning)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }

    private func handleUserInput() {
        let trimmed = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let topic = certifier.classify(trimmed)
        let disclaimer = CertificationDisclaimerProvider.disclaimerJP()

        let userEntry = ConversationEntry(
            speaker: "user",
            text: trimmed,
            emotion: EmotionType.neutral.rawValue,
            topic: ConversationSubject(label: topic.rawValue)
        )
        storage.append(userEntry)

        Task {
            let items = await news.fetchLatest(for: topic)
            let info = items.first

            var reply = "\(disclaimer)\n\(label(topic))に関する最近の話題です。"
            if let i = info {
                let safeTitle = CertificationToneGuard.soften(i.title)
                let safeSummary = CertificationToneGuard.soften(i.summary)
                reply += "『\(safeTitle)』 — \(safeSummary)（\(CertificationToneGuard.enforceSourcePrefix(i.source))）"
            } else {
                reply += "公式資料に基づく確認を推奨します。"
            }

            speech.speak(reply, language: locale.current == .japanese ? "ja-JP" : "en-US", rate: 0.5)

            let compEntry = ConversationEntry(
                speaker: "companion",
                text: reply,
                emotion: EmotionType.neutral.rawValue,
                topic: ConversationSubject(label: topic.rawValue)
            )
            storage.append(compEntry)
        }

        userInput = ""
    }

    private func label(_ t: CertificationTopic) -> String {
        switch t {
        case .domesticMedical: return "国内医療資格"
        case .domesticLegal: return "国内法律資格"
        case .domesticIT: return "国内IT資格"
        case .domesticFinance: return "国内金融資格"
        case .internationalLanguage: return "国際語学資格"
        case .internationalTech: return "国際技術資格"
        case .internationalBusiness: return "国際ビジネス資格"
        case .other: return "資格一般"
        }
    }
}
