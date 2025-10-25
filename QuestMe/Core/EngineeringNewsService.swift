//
//  EngineeringNewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Engineering/EngineeringNewsService.swift
//
//  🎯 ファイルの目的:
//      工学分野のニュースを取得するサービス。
//      - 分類結果に応じてダミー記事を返す。
//      - SwiftUI の @EnvironmentObject で注入可能。
//
//  🔗 依存/連動:
//      - EngineeringView.swift
//      - ConversationSubject.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月15日
//

import Foundation
import Combine

final class EngineeringNewsService: ObservableObject {
    @Published var articles: [String] = []

    func fetch(for subject: ConversationSubject) async {
        let keyword = subject.label.lowercased()
        switch true {
        case keyword.contains("ai"), keyword.contains("人工知能"), keyword.contains("機械学習"):
            articles = [
                "AIによる設計最適化が進展",
                "生成モデルの工学応用が注目",
                "機械学習による故障予測技術"
            ]
        case keyword.contains("ロボット"), keyword.contains("制御"), keyword.contains("自律"):
            articles = [
                "ロボットアームの精度向上",
                "自律移動制御の新アルゴリズム",
                "制御理論の応用事例"
            ]
        case keyword.contains("材料"), keyword.contains("構造"), keyword.contains("強度"):
            articles = [
                "新素材による軽量化技術",
                "構造解析の最新手法",
                "材料疲労のAI予測"
            ]
        case keyword.contains("電気"), keyword.contains("回路"), keyword.contains("半導体"):
            articles = [
                "次世代半導体の開発競争",
                "電力効率を高める回路設計",
                "電気自動車向けインバータ技術"
            ]
        default:
            articles = [
                "工学全般に関する最近の話題",
                "技術革新と社会実装の動向",
                "研究開発のトレンド"
            ]
        }
    }
}
