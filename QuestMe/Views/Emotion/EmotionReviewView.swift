//
//  EmotionReviewView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Emotion/EmotionReviewView.swift
//
//  🎯 ファイルの目的:
//      感情履歴をグラフとリストで表示し、CompanionOverlay と連動して
//      最新の感情傾向を CompanionSpeechBubbleView で吹き出し表示する。
//      - EmotionLogStorageManager から読み込み。
//      - CompanionOverlay による音声案内と吹き出し表示を統合。
//      - 感情タイプ選択と変化説明機能を提供。
//      - コンパニオンの成長状態を CompanionGrowthView で表示可能。
//
//  🔗 依存ファイル:
//      - Models/EmotionLog.swift
//      - Models/EmotionType.swift
//      - Managers/EmotionLogStorageManager.swift
//      - Managers/CompanionEmotionManager.swift
//      - Views/Companion/CompanionSpeechBubbleView.swift
//      - Views/Companion/CompanionGrowthView.swift
//      - UI/CompanionOverlay.swift
//      - Charts
//
//  👤 作成者: 津村 淳一
//  📅 修正日: 2025年10月23日
//

import SwiftUI
import Charts

struct EmotionReviewView: View {
    @State private var logs: [EmotionLog] = []
    @State private var selectedEmotion: EmotionType = .happy
    @State private var showGrowthView = false
    @ObservedObject private var overlay = CompanionOverlay.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let text = overlay.bubbleText {
                    CompanionSpeechBubbleView(text: text, mood: overlay.currentMood)
                }

                Picker("感情タイプ", selection: $selectedEmotion) {
                    ForEach(EmotionType.allCases, id: \.self) { emotion in
                        Text(emotion.label).tag(emotion)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Button("🗣 感情の変化を説明") {
                    speakTrend(for: selectedEmotion)
                }
                .buttonStyle(.borderedProminent)

                Button("🧠 コンパニオンの成長を見る") {
                    showGrowthView = true
                }
                .buttonStyle(.bordered)

                Chart {
                    ForEach(filteredData(), id: \.id) { point in
                        LineMark(
                            x: .value("日付", point.date),
                            y: .value("頻度", point.count)
                        )
                        .foregroundStyle(point.emotion.color)
                        .symbol(.circle)
                    }
                }
                .frame(height: 240)
                .padding(.horizontal)

                ForEach(logs) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(log.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.headline)
                        Text("感情: \(log.emotion.label)")
                            .foregroundColor(log.emotion.color)
                        if let note = log.note {
                            Text("メモ: \(note)")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .onAppear {
            logs = EmotionLogStorageManager.shared.loadAll()

            // ✅ 感情履歴をコンパニオンに反映
            for log in logs {
                CompanionEmotionManager.shared.update(from: log.emotion)
            }

            let summary = summarizeEmotionLogs()
            overlay.speak(summary, emotion: determineDominantEmotion())
            overlay.checkSpecialAchievements(logs: logs)
        }
        .onDisappear {
            overlay.closingAfterReview()
        }
        .navigationTitle("感情レビュー")
        .sheet(isPresented: $showGrowthView) {
            CompanionGrowthView()
        }
    }

    // MARK: - グラフ用データ抽出
    func filteredData() -> [EmotionPoint] {
        let grouped = Dictionary(grouping: logs.filter { $0.emotion == selectedEmotion },
                                 by: { Calendar.current.startOfDay(for: $0.date) })
        return grouped.map { (date, entries) in
            EmotionPoint(date: date, count: entries.count, emotion: selectedEmotion, id: UUID())
        }.sorted { $0.date < $1.date }
    }

    struct EmotionPoint: Identifiable {
        var date: Date
        var count: Int
        var emotion: EmotionType
        var id: UUID
    }

    // MARK: - Companion による語りかけ
    func speakTrend(for emotion: EmotionType) {
        let points = filteredData().sorted { $0.date > $1.date }
        guard points.count >= 2 else {
            overlay.speak("感情履歴が少ないため、変化を説明できません。", emotion: .neutral)
            return
        }

        let latest = points[0]
        let previous = points[1]
        let delta = latest.count - previous.count
        let direction = delta > 0 ? "増加" : "減少"

        let dateStr = DateFormatter.localizedString(from: latest.date, dateStyle: .medium, timeStyle: .none)
        let message = "\(emotion.label) の記録は前回より \(abs(delta)) 件 \(direction) しました（\(dateStr)）。"
        overlay.speak(message, emotion: emotion)
    }

    // MARK: - 感情ログの要約生成
    func summarizeEmotionLogs() -> String {
        guard !logs.isEmpty else {
            return "感情ログがまだ記録されていません。"
        }

        let recent = logs.prefix(7)
        let emotions = recent.map { $0.emotion }
        let counts = Dictionary(grouping: emotions, by: { $0 }).mapValues { $0.count }
        let dominant = counts.max(by: { $0.value < $1.value })?.key ?? .neutral

        switch dominant {
        case .happy:
            return "😊 最近はポジティブな気持ちが多く記録されています。この調子でいきましょう！"
        case .sad:
            return "😢 最近は少し落ち込む傾向が見られます。無理せず、ゆっくり整えていきましょう。"
        case .angry:
            return "😠 怒りの感情が目立っています。深呼吸や休息を意識してみましょう。"
        case .neutral:
            return "😐 感情は安定しています。自分のペースを大切にしてください。"
        case .thinking:
            return "🤔 最近は考え込む時間が多いようです。じっくり整理していきましょう。"
        case .sexy:
            return "❤️ 自信と魅力が高まっています。素敵なエネルギーを活かしましょう。"
        case .encouraging:
            return "💪 周囲を励ます力が強まっています。あなたの言葉が力になります。"
        }
    }

    // MARK: - データ層の支配的感情を返す（音声合成用）
    func determineDominantEmotion() -> EmotionType {
        guard !logs.isEmpty else { return .neutral }

        let recent = logs.prefix(7)
        let emotions = recent.map { $0.emotion }
        let counts = Dictionary(grouping: emotions, by: { $0 }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key ?? .neutral
    }
}
