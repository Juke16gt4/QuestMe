//
//  EmotionTimelinePlayerView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/EmotionTimelinePlayerView.swift
//
//  🎯 目的:
//      AIコンパニオンの感情履歴（joy, sadness, anger, surprise, trust）を日付ごとに再生。
//      - CompanionState/yyyyMMdd.json を読み込み
//      - 各感情スコアをアニメーションで表示
//      - 再生/停止/日付スライダーを提供
//
//  🔗 連動:
//      - CompanionEmotionManager.swift（保存元）
//      - CompanionAvatarView.swift（表情連動）
//      - CompanionSpeechBubbleView.swift（トーン連動）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025-10-23
//

import SwiftUI

struct EmotionSnapshot: Identifiable {
    let id = UUID()
    let date: String
    let joy: Double
    let sadness: Double
    let anger: Double
    let surprise: Double
    let trust: Double
}

struct EmotionTimelinePlayerView: View {
    @State private var snapshots: [EmotionSnapshot] = []
    @State private var currentIndex: Int = 0
    @State private var isPlaying: Bool = false

    private let timer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 16) {
            Text("🧠 コンパニオンの感情履歴")
                .font(.title2)
                .bold()

            if snapshots.isEmpty {
                Text("履歴が見つかりませんでした。")
            } else {
                let current = snapshots[currentIndex]

                Text("📅 \(current.date)").font(.headline)

                EmotionBar(label: "Joy", value: current.joy, color: .blue)
                EmotionBar(label: "Sadness", value: current.sadness, color: .gray)
                EmotionBar(label: "Anger", value: current.anger, color: .red)
                EmotionBar(label: "Surprise", value: current.surprise, color: .green)
                EmotionBar(label: "Trust", value: current.trust, color: .purple)

                CompanionAvatarView(image: UIImage(systemName: "person.circle.fill")!,
                                    emotion: .constant(emotionHint(for: current)))

                HStack {
                    Button(isPlaying ? "⏸ 停止" : "▶️ 再生") {
                        isPlaying.toggle()
                    }
                    .buttonStyle(.borderedProminent)

                    Slider(value: Binding(
                        get: { Double(currentIndex) },
                        set: { currentIndex = Int($0) }
                    ), in: 0...Double(snapshots.count - 1), step: 1)
                }
            }
        }
        .padding()
        .onAppear {
            snapshots = EmotionTimelineLoader.loadSnapshots()
        }
        .onReceive(timer) { _ in
            guard isPlaying, !snapshots.isEmpty else { return }
            currentIndex = (currentIndex + 1) % snapshots.count
        }
    }

    private func emotionHint(for snapshot: EmotionSnapshot) -> EmotionType {
        if snapshot.joy > 1.2 { return .happy }
        if snapshot.sadness > 1.0 { return .sad }
        if snapshot.anger > 0.8 { return .angry }
        if snapshot.trust > 1.0 { return .gentle }
        if snapshot.surprise > 1.0 { return .surprised }
        return .neutral
    }
}

// MARK: - 感情バー表示
struct EmotionBar: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(label): \(String(format: "%.2f", value))")
            GeometryReader { geo in
                Rectangle()
                    .fill(color)
                    .frame(width: CGFloat(value / 1.5) * geo.size.width, height: 12)
                    .animation(.easeInOut, value: value)
            }
            .frame(height: 12)
        }
    }
}

// MARK: - ローダー
struct EmotionTimelineLoader {
    static func loadSnapshots() -> [EmotionSnapshot] {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("CompanionState", isDirectory: true)

        guard let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) else {
            return []
        }

        var snapshots: [EmotionSnapshot] = []

        for file in files where file.pathExtension == "json" {
            if let data = try? Data(contentsOf: file),
               let state = try? JSONDecoder().decode(CompanionEmotionState.self, from: data) {
                let date = file.deletingPathExtension().lastPathComponent
                snapshots.append(EmotionSnapshot(
                    date: date,
                    joy: state.joy,
                    sadness: state.sadness,
                    anger: state.anger,
                    surprise: state.surprise,
                    trust: state.trust
                ))
            }
        }

        return snapshots.sorted { $0.date < $1.date }
    }
}
