//
//  CompanionBubbleView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/CompanionBubbleView.swift
//
//  🎯 ファイルの目的:
//      CompanionOverlay の吹き出しテキストを表示するビュー。
//      - bubbleText を監視して表示。
//      - 表情や感情に応じたスタイルに拡張可能。
//
//  🔗 依存:
//      - CompanionOverlay.swift（@Published bubbleText）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月10日
//

import SwiftUI
import Combine

struct CompanionBubbleView: View {
    @StateObject private var observer = CompanionOverlayObserver()

    var body: some View {
        if let text = observer.bubbleText {
            Text(text)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 4)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: text)
        }
    }
}

// ✅ CompanionOverlay を SwiftUI に適応させる ObservableObject ラッパー
final class CompanionOverlayObserver: ObservableObject {
    @Published var bubbleText: String? = nil
    private var cancellable: AnyCancellable?

    init() {
        bubbleText = CompanionOverlay.shared.bubbleText
        cancellable = CompanionOverlay.shared
            .objectWillChange
            .sink { [weak self] in
                self?.bubbleText = CompanionOverlay.shared.bubbleText
                self?.objectWillChange.send()
            }
    }
}
