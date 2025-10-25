//
//  CompanionTemplates_ko.swift
//  QuestMe
//
//  Created by 淳一 on 2025/09/29.
//

/**
 Companion의 한국어 템플릿.

 ## 목적
 한국어 사용자에게 인사말, 작별 인사, 감정 라벨을 제공한다.
 */

import Foundation
import Combine

struct CompanionTemplates_ko: CompanionTemplates {
    var greeting: String { "좋은 아침입니다. 오늘도 함께할게요." }
    var farewell: String { "잘 가요. 언제든지 불러주세요." }
    var emotionLabels: [String] {
        ["기쁨", "슬픔", "분노", "놀람", "평온"]
    }
}
