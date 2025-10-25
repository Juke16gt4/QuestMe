//
//  TagAnalyticsView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Certification/TagAnalyticsView.swift
//
//  🎯 ファイルの目的:
//      問題バンク内のタグを統合・整理し、タグごとの正答率を分析する。
//      - タグ一覧表示（出現数・正答率）
//      - タグのリネーム（統合）
//      - 保存は ProblemBankService
//
//  🔗 連動ファイル:
//      - Core/Model/TagStat.swift（唯一の定義を利用）
//      - RadarChartView.swift
//      - DashboardView.swift
//
//  👤 作成者: 津村 淳一
//  📅 修正日: 2025年10月16日
//

import SwiftUI

struct TagAnalyticsView: View {
    let certificationName: String
    @State private var questions: [BankQuestion] = []
    @State private var tagStats: [TagStat] = []
    @State private var selectedTag: String? = nil
    @State private var newTagName: String = ""

    var body: some View {
        VStack {
            Text("📊 タグ分析: \(certificationName)")
                .font(.title2).bold()

            List(tagStats) { stat in
                HStack {
                    VStack(alignment: .leading) {
                        Text(stat.name).font(.headline)
                        Text("出現数: \(stat.count)  正答率: \(String(format: "%.1f", stat.correctRate))%")
                            .font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                    Button("統合") {
                        selectedTag = stat.name
                        newTagName = stat.name
                    }
                    .buttonStyle(.bordered)
                }
            }

            Spacer()
        }
        .sheet(item: $selectedTag) { tag in
            VStack(spacing: 16) {
                Text("タグ統合: \(tag)").font(.headline)
                TextField("新しいタグ名", text: $newTagName)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("キャンセル") { selectedTag = nil }
                    Button("保存") {
                        unifyTag(old: tag, new: newTagName)
                        selectedTag = nil
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .onAppear {
            questions = ProblemBankService.load(for: certificationName)
            computeStats()
        }
    }

    // MARK: - タグ統合処理
    private func unifyTag(old: String, new: String) {
        var updated: [BankQuestion] = []
        for var q in questions {
            if q.tags.contains(old) {
                q.tags = q.tags.map { $0 == old ? new : $0 }
                updated.append(q)
            }
        }
        if !updated.isEmpty {
            ProblemBankService.merge(updated, into: certificationName)
            questions = ProblemBankService.load(for: certificationName)
            computeStats()
        }
    }

    // MARK: - タグ統計計算
    private func computeStats() {
        var dict: [String: (count: Int, corrects: Int, attempts: Int)] = [:]
        for q in questions {
            for tag in q.tags {
                var entry = dict[tag, default: (0,0,0)]
                entry.count += 1
                entry.attempts += q.attempts
                entry.corrects += (q.attempts - q.wrongs)
                dict[tag] = entry
            }
        }
        tagStats = dict.map { (tag, v) in
            let rate = v.attempts > 0 ? Double(v.corrects) / Double(v.attempts) * 100.0 : 0.0
            return TagStat(name: tag, count: v.count, correctRate: rate)
        }.sorted(by: { $0.correctRate < $1.correctRate })
    }
}
