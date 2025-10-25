//
//  SocialWelfareTopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/SocialWelfareTopicClassifier.swift
//
//  🎯 ファイルの目的:
//      社会福祉学分野のトピック分類。
//      - キーワードベースで一次分類。
//      - MLモデルがあれば補強。
//
//  🔗 依存:
//      - Foundation
//      - SocialWelfareModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

final class SocialWelfareTopicClassifier: ObservableObject {
    func classify(_ text: String) -> SocialWelfareTopic {
        let l = text.lowercased()
        if l.contains("高齢") || l.contains("介護") { return .elderly }
        if l.contains("障害") || l.contains("バリアフリー") { return .disability }
        if l.contains("児童") || l.contains("子供") { return .child }
        if l.contains("生活保護") || l.contains("貧困") { return .poverty }
        if l.contains("地域") || l.contains("コミュニティ") { return .community }
        if l.contains("国際") || l.contains("unicef") { return .international }
        return .other
    }
}
