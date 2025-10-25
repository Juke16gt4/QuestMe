//
//  CompanionAvatarView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionAvatarView.swift
//
//  🎯 目的:
//      コンパニオンの画像を縦長楕円で表示し、タップ・長押し・スワイプで感情を切り替える。
//      EmotionType に基づき枠線色を変更し、ユーザーとのインタラクションを演出する。
//      CompanionSpeechBubbleView と連動できるように onEmotionChange を提供する。
//
//  🔗 依存:
//      - EmotionType.swift（感情の色やアイコン定義）
//      - CompanionSpeechBubbleView.swift（吹き出し連動用）
//      - CompanionProfile.swift（画像の取得元となるプロフィール定義）
//      - DeceasedAssetStore.swift（故人画像の保存・読み込み）
//
//  👤 作成者: 津村 淳一
//  📅 改変日: 2025年10月11日
//

import SwiftUI

struct CompanionAvatarView: View {
    let image: UIImage
    @Binding var emotion: EmotionType
    var onEmotionChange: ((EmotionType) -> Void)? = nil

    @State private var scale: CGFloat = 1.0

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 180)
            .clipShape(Ellipse())
            .overlay(Ellipse().stroke(emotion.color, lineWidth: 3))
            .scaleEffect(scale)
            .gesture(
                TapGesture()
                    .onEnded {
                        // ランダムに感情を切り替え
                        if let newEmotion = EmotionType.allCases.randomElement() {
                            updateEmotion(newEmotion)
                        }
                        animateTap()
                    }
            )
            .gesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        updateEmotion(.sad)
                        animateTap()
                    }
            )
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        if value.translation.width > 0 {
                            updateEmotion(.happy)
                        } else {
                            updateEmotion(.angry)
                        }
                        animateTap()
                    }
            )
    }

    // MARK: - Helper
    private func updateEmotion(_ newEmotion: EmotionType) {
        emotion = newEmotion
        onEmotionChange?(newEmotion)
    }

    private func animateTap() {
        withAnimation(.easeInOut) { scale = 1.2 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut) { scale = 1.0 }
        }
    }
}
