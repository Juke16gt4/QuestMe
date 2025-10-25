//
//  MockExamView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Certification/MockExamView.swift
//
//  🎯 ファイルの目的:
//      本番に近い模擬試験体験を提供する。
//      - 制限時間（例: 60分）
//      - 50問ランダム出題（問題バンクから最適化＋ランダム）
//      - 終了時にスコアと弱点分析をMarkdownで保存（弱点命題フォルダ）
//      - 「閉じる」でコンパニオン拡大画面へ戻る
//
//  🔗 依存:
//      - ProblemBankService
//      - CompanionOverlay.shared.speak()
//

import SwiftUI

struct MockExamView: View {
    let certificationName: String
    let timeLimitMinutes: Int = 60
    let totalQuestions: Int = 50

    @State private var questions: [BankQuestion] = []
    @State private var currentIndex = 0
    @State private var answers: [UUID: Bool] = [:]
    @State private var remainingSeconds: Int = 0
    @State private var finished = false

    var body: some View {
        VStack(spacing: 16) {
            // ヘッダー＆タイマー
            HStack {
                Text("🧪 模擬試験: \(certificationName)")
                    .font(.title3).bold()
                Spacer()
                Text("残り時間: \(format(remainingSeconds))")
                    .font(.headline)
                    .foregroundColor(remainingSeconds <= 300 ? .red : .blue)
            }

            if !finished, currentIndex < questions.count {
                let q = questions[currentIndex]

                Text("問題 \(currentIndex + 1) / \(questions.count)  難易度: \(q.difficulty)")
                    .font(.subheadline).foregroundColor(.orange)

                Text(q.text)
                    .font(.title3)
                    .padding()

                HStack {
                    Button("○") { selectAnswer(true) }
                        .buttonStyle(.borderedProminent)
                    Button("×") { selectAnswer(false) }
                        .buttonStyle(.borderedProminent)
                }

                HStack {
                    Button("次へ") { goNext() }
                        .buttonStyle(.bordered)
                    Button("終了") { finishExam() }
                        .buttonStyle(.bordered)
                        .tint(.red)
                }
            } else {
                // 結果表示
                let score = scoreRate()
                Text("模擬試験が終了しました。お疲れさまでした。")
                    .font(.headline)
                Text("スコア: \(String(format: "%.1f", score))%")
                    .font(.title2).foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 8) {
                    Text("弱点分析（誤答タグ出現頻度）").font(.headline)
                    ForEach(weakTagCounts().sorted(by: { $0.value > $1.value }), id: \.key) { tag, cnt in
                        HStack { Text(tag); Spacer(); Text("\(cnt)回") }
                    }
                }
                .padding()

                HStack {
                    Button("結果を保存") { saveResultMarkdown(score: score) }
                        .buttonStyle(.borderedProminent)
                    Button("閉じる") {
                        // Companion拡大画面へ戻る処理
                    }
                    .buttonStyle(.bordered)
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            // 問題準備（最適化＋乱択）
            var base = ProblemBankService.optimizedQuestions(for: certificationName, count: totalQuestions * 2)
            if base.count < totalQuestions {
                // 足りない場合はバンク全体から追加
                base = ProblemBankService.load(for: certificationName)
            }
            questions = Array(base.shuffled().prefix(totalQuestions))
            remainingSeconds = timeLimitMinutes * 60
            CompanionOverlay.shared.speak("模擬試験を開始します。制限時間は\(timeLimitMinutes)分です。健闘を祈ります。", emotion: .encouraging)
            startTimer()
        }
    }

    // MARK: - 進行管理
    private func selectAnswer(_ ans: Bool) {
        let q = questions[currentIndex]
        answers[q.id] = ans
        ProblemBankService.recordResult(for: certificationName, questionID: q.id, isCorrect: ans == q.correct)
    }

    private func goNext() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
        } else {
            finishExam()
        }
    }

    private func finishExam() {
        finished = true
        CompanionOverlay.shared.speak("模擬試験を終了します。お疲れさまでした。", emotion: .gentle)
    }

    // MARK: - タイマー
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if finished { timer.invalidate(); return }
            remainingSeconds -= 1
            if remainingSeconds <= 0 {
                timer.invalidate()
                finishExam()
            }
        }
    }

    private func format(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - スコア & 弱点分析
    private func scoreRate() -> Double {
        guard !questions.isEmpty else { return 0 }
        let corrects = questions.filter { answers[$0.id] == $0.correct }.count
        return (Double(corrects) / Double(questions.count)) * 100.0
    }

    private func weakTagCounts() -> [String: Int] {
        var dict: [String: Int] = [:]
        for q in questions {
            let isWrong = (answers[q.id] ?? false) != q.correct
            if isWrong {
                for tag in q.tags { dict[tag, default: 0] += 1 }
            }
        }
        return dict
    }

    // MARK: - 結果保存（Markdown）
    private func saveResultMarkdown(score: Double) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        let fileName = "\(formatter.string(from: Date())).md"

        let sortedWeak = weakTagCounts().sorted(by: { $0.value > $1.value })
        let weakList = sortedWeak.map { "- \($0.key): \($0.value)回" }.joined(separator: "\n")

        let markdown = """
        # 模擬試験結果（\(certificationName)）

        ## 📅 実施日
        \(Date())

        ## 🧮 スコア
        - 正答率: \(String(format: "%.1f", score))%

        ## ❗ 弱点分析（タグ別）
        \(weakList.isEmpty ? "- 目立った弱点はありませんでした。" : weakList)

        ## 🎯 次の一歩（AIからの提案）
        \(score >= 80 ? "- 応用問題への挑戦をおすすめします。" :
           score >= 50 ? "- 苦手タグを重点的に復習しましょう。" :
                         "- 基礎からやり直し、タグごとに小ステップで復習しましょう。")
        """

        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let folderURL = dir.appendingPathComponent(certificationName + "_模擬試験")
            try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            let fileURL = folderURL.appendingPathComponent(fileName)
            try? markdown.write(to: fileURL, atomically: true, encoding: .utf8)
            CompanionOverlay.shared.speak("模擬試験の結果を保存しました。", emotion: .happy)
        }
    }
}
