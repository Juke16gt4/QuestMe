//
//  DynamicCompanionView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/DynamicCompanionView.swift
//
//  🎯 ファイルの目的:
//      CoreML やテンプレートに応じて CompanionExpression を受け取り、
//      CompanionFaceView を通じて表情を動的に描画するビュー。
//      - 表情の変化をリアルタイムに反映。
//      - CompanionSpeechBubbleView や FloatingCompanionView の補助として使用可能。
//      - Companion の感情状態を視覚的に提示する。
//
//  🔗 依存:
//      - CompanionExpression.swift（表情定義）
//      - CompanionFaceView.swift（絵文字描画）
//      - SwiftUI（UI構造）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月29日

import SwiftUI


struct DynamicCompanionView: View {
    public let expression: CompanionExpression

    public init(expression: CompanionExpression) {
        self.expression = expression
    }

    public var body: some View {
        VStack {
            CompanionFaceView(expression: expression)
            Text("Current Expression: \(expression.rawValue)")
        }
    }
}
