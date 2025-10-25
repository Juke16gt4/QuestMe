//
//  GreetingBubbleView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/Shared/GreetingBubbleView.swift
//
//  🎯 ファイルの目的:
//      - AIコンパニオンの発話を吹き出しで表示。
//      - 強調語は1.4倍サイズで表示（音声と同期）。
//      - EmotionType に応じて背景色・アイコンを切り替え。
//
//  🔗 依存:
//      - EmotionType.swift
//
//  👤 製作者: 津村 淳一
//  📅 作成日: 2025年10月16日
//

import SwiftUI

struct GreetingBubbleView: View {
    let text: String
    let emphasizedWords: [String]
    let emotion: EmotionType

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(emotion.iconName)
                .resizable()
                .frame(width: 40, height: 40)

            Text(stylizedText(from: text))
                .padding()
                .background(emotion.backgroundColor)
                .cornerRadius(12)
                .foregroundColor(.primary)
        }
        .padding(.horizontal)
    }

    private func stylizedText(from text: String) -> AttributedString {
        var attributed = AttributedString(text)
        for word in emphasizedWords {
            if let range = attributed.range(of: word) {
                attributed[range].font = .system(size: 22, weight: .bold)
            }
        }
        return attributed
    }
}
