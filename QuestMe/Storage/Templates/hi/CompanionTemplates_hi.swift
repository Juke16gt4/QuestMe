//
//  CompanionTemplates_hi.swift
//  QuestMe
//
//  Created by 淳一 on 2025/09/29.
//

/**
 Companion का हिंदी टेम्पलेट।

 ## उद्देश्य
 हिंदी उपयोगकर्ताओं के लिए अभिवादन, विदाई और भावनात्मक लेबल प्रदान करना।
 */

import Foundation
import Combine

struct CompanionTemplates_hi: CompanionTemplates {
    var greeting: String { "शुभ प्रभात। मैं आज आपके साथ हूँ।" }
    var farewell: String { "ध्यान रखना। मैं हमेशा यहाँ हूँ।" }
    var emotionLabels: [String] {
        ["खुशी", "दुख", "गुस्सा", "आश्चर्य", "शांति"]
    }
}
