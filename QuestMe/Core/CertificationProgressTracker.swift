//
//  CertificationProgressTracker.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/CertificationProgressTracker.swift
//
//  🎯 ファイルの目的:
//      資格ごとの進捗管理。
//      - ObservableObject として UI と同期。
//      - 進捗項目（名前／達成率／目標日）を公開。
//
//  🔗 連動ファイル:
//      - CertificationView.swift
//
//  👤 作成者: 津村 淳一 (Junichi Tsumura)
//  📅 作成日: 2025年10月16日
//

import Foundation
import Combine

struct ProgressItem: Identifiable {
    let id = UUID()
    let name: String
    let completedPercent: Double
    let goalDate: Date
}

@MainActor
final class CertificationProgressTracker: ObservableObject {
    @Published var progressList: [ProgressItem] = [
        ProgressItem(name: "薬剤師国家試験", completedPercent: 42.0, goalDate: Calendar.current.date(byAdding: .day, value: 60, to: Date())!),
        ProgressItem(name: "基本情報技術者", completedPercent: 58.0, goalDate: Calendar.current.date(byAdding: .day, value: 40, to: Date())!),
        ProgressItem(name: "TOEIC", completedPercent: 30.0, goalDate: Calendar.current.date(byAdding: .day, value: 21, to: Date())!)
    ]
}
