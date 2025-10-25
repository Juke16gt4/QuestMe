//
//  CertificationQuizView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Certification/CertificationQuizView.swift
//
//  🎯 ファイルの目的:
//      資格取得支援の問題演習画面。
//      - 20問を○×形式で出題（難易度1〜5を均等に振り分け）。
//      - 回答ごとに正誤判定と解説を提示（テキスト＋音声、解説は1.4倍表示）。
//      - 解説後に「理解できましたか？」と確認。
//      - 「いいえ」で質問入力欄を表示し、優しく丁寧に解答・解説。
//      - 各問題ごとに正答率を表示。
//      - 終了時に保存処理（カレンダーホルダー、フォルダ=資格取得支援）。
//
//  🔗 依存:
//      - QuizQuestion.swift（問題モデル）
//      - CompanionOverlay.shared.speak()
//      - EndOptionsView.swift（終了処理）
//

import SwiftUI

struct CertificationQuizView: View {
    let certificationName: String
    let questions: [QuizQuestion]

    @State private var currentIndex = 0
    @State private var correctCount = 0
    @State private var showExplanation = false
    @State private var showUnderstandingCheck = false
    @State private var showUserQuestionInput = false
    @State private var userQuestion: String = ""
    @State private var finished = false

    var body: some View {
        VStack(spacing: 20) {
            // ✅ ヘッダー
            VStack(spacing: 8) {
                Text("🎓 \(certificationName) 模擬試験")
                    .font(.title2).bold()
                Text("20問を○×形式で解答してください。難易度は5段階で均等に出題されます。")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            if !finished {
                // ✅ 問題文
                Text("問題 \(currentIndex + 1) / \(questions.count)")
                    .font(.headline)
                Text("難易度: \(questions[currentIndex].difficulty)/5")
                    .font(.subheadline)
                    .foregroundColor(.orange)

                Text(questions[currentIndex].text)
                    .font(.title3)
                    .padding()

                // ✅ 回答ボタン
                HStack {
                    Button("○") { answer(true) }
                        .buttonStyle(.borderedProminent)
                    Button("×") { answer(false) }
                        .buttonStyle(.borderedProminent)
                }

                // ✅ 解説表示
                if showExplanation {
                    VStack(spacing: 12) {
                        Text("解説")
                            .font(.headline)
                        Text(questions[currentIndex].explanation)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .scaleEffect(1.4) // 音声と同期して拡大表示
                            .animation(.easeInOut(duration: 0.3), value: showExplanation)

                        Button("理解確認へ") {
                            CompanionOverlay.shared.speak("理解できましたか？", emotion: .gentle)
                            showUnderstandingCheck = true
                        }
                    }
                }

                // ✅ 理解確認
                if showUnderstandingCheck {
                    HStack {
                        Button("はい") {
                            nextQuestion()
                        }
                        Button("いいえ") {
                            CompanionOverlay.shared.speak("どのようなことが理解できませんでしたか？", emotion: .gentle)
                            showUserQuestionInput = true
                        }
                    }
                }

                // ✅ ユーザー質問
                if showUserQuestionInput {
                    TextField("質問内容、どんなことでもかまいませんよ。", text: $userQuestion)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)

                    if !userQuestion.isEmpty {
                        Text("AIの優しく丁寧な解答・解説: \(userQuestion) に関する補足を提示します。")
                            .padding()
                    }
                }

                // ✅ 正答率表示
                if currentIndex > 0 {
                    Text("正答数: \(correctCount) / \(currentIndex)  正答率: \(correctRate(), specifier: "%.1f")%")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            } else {
                // ✅ 終了画面
                Text("全ての問題が終了しました。お疲れさまでした。")
                    .font(.title3)
                    .padding()

                Text("最終正答率: \(correctRate(), specifier: "%.1f")%")
                    .font(.headline)
                    .foregroundColor(.blue)

                Divider()

                EndOptionsView(
                    folderName: "資格取得支援",
                    fileName: generateFileName(),
                    content: "資格: \(certificationName)\n正答率: \(correctRate(), specifier: "%.1f")%"
                )
            }

            Spacer()
        }
        .padding()
        .onAppear {
            // ✅ 初回のみ音声案内
            let hasShownGuide = UserDefaults.standard.bool(forKey: "CertificationQuizGuideShown")
            if !hasShownGuide {
                CompanionOverlay.shared.speak(
                    "ここでは資格取得に向けた問題を解きます。○か×で回答してください。",
                    emotion: .gentle
                )
                UserDefaults.standard.set(true, forKey: "CertificationQuizGuideShown")
            }
        }
    }

    // MARK: - 回答処理
    private func answer(_ userAnswer: Bool) {
        if userAnswer == questions[currentIndex].isCorrect {
            correctCount += 1
            CompanionOverlay.shared.speak("正解です。", emotion: .happy)
        } else {
            CompanionOverlay.shared.speak("不正解です。", emotion: .sad)
        }
        showExplanation = true
    }

    // MARK: - 次の問題へ
    private func nextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            showExplanation = false
            showUnderstandingCheck = false
            showUserQuestionInput = false
            userQuestion = ""
        } else {
            finished = true
            CompanionOverlay.shared.speak("全ての問題が終了しました。お疲れさまでした。", emotion: .encouraging)
        }
    }

    // MARK: - 正答率計算
    private func correctRate() -> Double {
        guard currentIndex > 0 else { return 0 }
        return (Double(correctCount) / Double(currentIndex)) * 100
    }

    // MARK: - 保存用ファイル名生成
    private func generateFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return "\(certificationName)_\(formatter.string(from: Date()))"
    }
}
