//
//  CompanionFaceView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/CompanionFaceView.swift
//
//  🎯 ファイルの目的:
//      CompanionExpression に応じて、Companion の表情を絵文字で描画するビュー。
//      - 表情は SwiftUI の Text による絵文字表示。
//      - 表情種別は CompanionExpression に準拠。
//      - FloatingCompanionView や DynamicCompanionView から呼び出される。
//
//  🔗 依存:
//      - CompanionExpression.swift（表情定義）
//      - SwiftUI（UI構造）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月29日

import SwiftUI

/// Companion の表情を描画する View
 struct CompanionFaceView: View {
    public let expression: CompanionExpression

    public init(expression: CompanionExpression) {
        self.expression = expression
    }

     public var body: some View {
        switch expression {
        case .joy: Text("😄")
        case .sadness: Text("😢")
        case .anger: Text("😠")
        case .surprise: Text("😲")
        case .calm: Text("😌")
        case .neutral: Text("😐")
        case .smile: Text("😊")
        case .sad: Text("😭")
        case .surprised: Text("😮")
        case .serious: Text("😑")
        case .confused: Text("😕")
        case .discomfort: Text("😣")
        case .disgust: Text("🤢")
        }
    }
}
