//
//  CompanionOverlayView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionOverlayView.swift
//
//  🎯 目的:
//      コンパニオンの表情と吹き出しを連動表示する統合ビュー。
//      - CompanionEmotionManager の currentToneHint を参照。
//      - CompanionAvatarView と CompanionSpeechBubbleView を組み合わせ。
//      - CompanionOverlayExpandedView への遷移ボタンも提供。
//
//  🔗 依存:
//      - CompanionAvatarView.swift
//      - CompanionSpeechBubbleView.swift
//      - CompanionEmotionManager.swift
//      - CompanionOverlayExpandedView.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月23日
//

import SwiftUI

struct CompanionOverlayView: View {
    @State private var emotion: EmotionType = .neutral
    @State private var showExpanded = false
    @State private var bubbleText: String = "こんにちは、今日も一緒に進みましょう。"

    var body: some View {
        VStack(spacing: 12) {
            CompanionAvatarView(
                image: CompanionProfile.defaultImage,
                emotion: $emotion,
                onEmotionChange: { newEmotion in
                    bubbleText = newEmotion.defaultPhrase
                }
            )

            CompanionSpeechBubbleView(
                text: bubbleText,
                emotion: emotion
            )

            Button("📂 拡張ビューへ") {
                showExpanded = true
            }
            .buttonStyle(.bordered)

            Spacer(minLength: 0)
        }
        .padding()
        .onAppear {
            emotion = CompanionEmotionManager.shared.mapToneHintToEmotion()
            bubbleText = emotion.defaultPhrase
        }
        .sheet(isPresented: $showExpanded) {
            CompanionOverlayExpandedView()
        }
    }
}
