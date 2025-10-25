//
//  DomainViewProtocol.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Domain/DomainViewProtocol.swift
//
//  🎯 ファイルの目的:
//      各分野ビュー（HistoryView, EngineeringView など）の共通インターフェースを定義。
//      - ConversationSubject を入力として扱う
//      - TopicClassifier と NewsService を連動させる
//      - StorageService の履歴を表示する
//
//  🔗 依存:
//      - ConversationSubject.swift
//      - ConversationEntry.swift
//      - StorageService.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月15日
//

import Foundation
import Combine

/// 各ドメインビューが従うべき共通プロトコル
protocol DomainViewProtocol: ObservableObject {
    associatedtype Classifier: ObservableObject
    associatedtype NewsService: ObservableObject

    var storage: StorageService { get }
    var classifier: Classifier { get }
    var newsService: NewsService { get }
}
