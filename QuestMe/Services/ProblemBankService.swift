//
//  ProblemBankService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/ProblemBankService.swift
//
//  🎯 ファイルの目的:
//      資格ごとの問題バンクをJSONで保存・読み込み・マージ・最適化出題する。
//      - 保存先: Documents/資格名/problems.json
//      - 既存問題に新規問題（過去問/AI生成）をマージ。
//      - 出題時にユーザー履歴（正答/誤答）を参照して優先度を調整。
//      - 復習用に「誤答問題」も抽出可能。
//
//  🔗 依存:
//      - Codableモデル: BankQuestion
//

import Foundation

struct BankQuestion: Codable, Identifiable {
    let id: UUID
    var text: String
    var correct: Bool
    var explanation: String
    var difficulty: Int // 1..5
    var tags: [String]
    // 履歴
    var attempts: Int
    var wrongs: Int
    var lastAnsweredAt: Date?

    init(id: UUID = UUID(), text: String, correct: Bool, explanation: String, difficulty: Int, tags: [String]) {
        self.id = id
        self.text = text
        self.correct = correct
        self.explanation = explanation
        self.difficulty = difficulty
        self.tags = tags
        self.attempts = 0
        self.wrongs = 0
        self.lastAnsweredAt = nil
    }
}

struct ProblemBankService {
    static func bankURL(for certificationName: String) -> URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let folder = dir.appendingPathComponent(certificationName)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("problems.json")
    }

    static func load(for certificationName: String) -> [BankQuestion] {
        guard let url = bankURL(for: certificationName), let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([BankQuestion].self, from: data)) ?? []
    }

    static func save(_ questions: [BankQuestion], for certificationName: String) {
        guard let url = bankURL(for: certificationName) else { return }
        let data = try? JSONEncoder().encode(questions)
        try? data?.write(to: url, options: .atomic)
    }

    static func merge(_ newItems: [BankQuestion], into certificationName: String) {
        var current = load(for: certificationName)
        // マージ（同一idは更新、未登録は追加）
        for item in newItems {
            if let idx = current.firstIndex(where: { $0.id == item.id }) {
                current[idx] = item
            } else {
                current.append(item)
            }
        }
        save(current, for: certificationName)
    }

    // 最適化出題: 誤答率・経過時間・難易度に応じて重み付け
    static func optimizedQuestions(for certificationName: String, count: Int) -> [BankQuestion] {
        let all = load(for: certificationName)
        if all.isEmpty { return [] }

        let weighted = all.map { q -> (BankQuestion, Double) in
            // 重み: 誤答率を強化し、古い問題を優先、難易度は低〜中を多め
            let wrongRate = q.attempts == 0 ? 0.5 : Double(q.wrongs) / Double(q.attempts)
            let ageDays = q.lastAnsweredAt.map { max(1.0, Date().timeIntervalSince($0) / 86400.0) } ?? 7.0
            let difficultyBias = q.difficulty <= 3 ? 1.2 : 0.8
            let weight = wrongRate * difficultyBias * log(ageDays + 1.0)
            return (q, weight)
        }

        // 重みでソートして上位から選択
        let sorted = weighted.sorted { $0.1 > $1.1 }.map { $0.0 }
        return Array(sorted.prefix(count))
    }

    static func wrongOnly(for certificationName: String) -> [BankQuestion] {
        return load(for: certificationName).filter { $0.wrongs > 0 }
    }

    static func recordResult(for certificationName: String, questionID: UUID, isCorrect: Bool) {
        var bank = load(for: certificationName)
        guard let idx = bank.firstIndex(where: { $0.id == questionID }) else { return }
        bank[idx].attempts += 1
        if !isCorrect { bank[idx].wrongs += 1 }
        bank[idx].lastAnsweredAt = Date()
        save(bank, for: certificationName)
    }
}
