//
//  FloatingCompanionView.swift
//  QuestMe
//
//  Created by 淳一 on 2025/09/29.
//

/**
 Companionの表情を画面上に浮遊表示するビュー。

 ## 目的
 CompanionExpression を受け取り、画面上に浮かぶように表情を描画する。
 CompanionFaceView を内部で使用する。
 */

import SwiftUI


struct FloatingCompanionView: View {
    public let expression: CompanionExpression

    public init(expression: CompanionExpression) {
        self.expression = expression
    }

    public var body: some View {
        ZStack {
            Color.clear
            CompanionFaceView(expression: expression)
                .scaleEffect(1.5)
                .shadow(radius: 10)
        }
        .frame(width: 100, height: 100)
    }
}
