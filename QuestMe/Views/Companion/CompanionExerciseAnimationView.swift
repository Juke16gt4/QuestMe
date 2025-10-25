//
//  CompanionExerciseAnimationView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionExerciseAnimationView.swift
//
//  🎯 ファイルの目的:
//      運動中に Companion が応援するアニメーションを表示するビュー。
//      - 「動き」「表情」「セリフ」を組み合わせ、ユーザーのモチベーションを高める。
//      - 運動開始時は「準備運動モーション」、運動中は「リズム運動モーション」、終了時は「拍手・称賛モーション」。
//      - CompanionOverlay と連携し、音声応援と同期。
//
//  🔗 依存:
//      - CompanionOverlay.swift（音声）
//      - ExerciseRecordView.swift（起動元）
//      - ExerciseStorageManager.swift（記録連動）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import SwiftUI

struct CompanionExerciseAnimationView: View {
    enum AnimationState {
        case idle
        case warmup
        case exercising
        case cheering
    }

    @State private var state: AnimationState = .idle
    @State private var pulse = false
    @State private var bounce = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Companion のシンボル（仮: 丸いキャラクター）
                Circle()
                    .fill(stateColor)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text(faceEmoji)
                            .font(.system(size: 50))
                    )
                    .scaleEffect(pulse ? 1.1 : 1.0)
                    .offset(y: bounce ? -10 : 0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulse)
                    .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: bounce)
            }

            Text(stateMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .onAppear {
            startWarmup()
        }
    }

    // MARK: - 状態ごとの表情と色
    private var faceEmoji: String {
        switch state {
        case .idle: return "🙂"
        case .warmup: return "🤸"
        case .exercising: return "💪"
        case .cheering: return "👏"
        }
    }

    private var stateColor: Color {
        switch state {
        case .idle: return .gray
        case .warmup: return .orange
        case .exercising: return .blue
        case .cheering: return .green
        }
    }

    private var stateMessage: String {
        switch state {
        case .idle: return "準備はできていますか？"
        case .warmup: return "準備運動しましょう！"
        case .exercising: return "いいペースです！その調子！"
        case .cheering: return "お疲れさま！よく頑張りました！"
        }
    }

    // MARK: - アニメーション制御
    private func startWarmup() {
        state = .warmup
        pulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            startExercise()
        }
    }

    private func startExercise() {
        state = .exercising
        bounce = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            finishExercise()
        }
    }

    private func finishExercise() {
        state = .cheering
        pulse = false
        bounce = false
        CompanionOverlay.shared.speak("お疲れさまでした！今日の運動も素晴らしい成果です！")
    }
}
