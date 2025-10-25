//
//  CertificationSupportView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Certification/CertificationSupportView.swift
//
//  🎯 ファイルの目的:
//      ユーザーが目指す資格を入力し、その資格に応じた問題演習画面へ遷移する。
//      - 入力はテキストまたは音声で可能（自動判定）。
//      - 初回のみ音声案内を流す。
//      - OKボタン押下で CertificationQuizView に遷移。
//      - テキストボックスにはプレースホルダーを設定し、うっすらと文字が浮かぶようにする。
//
//  🔗 依存:
//      - CertificationQuizView.swift
//      - CompanionOverlay.shared.speak()
//

import SwiftUI

struct CertificationSupportView: View {
    @State private var certificationName: String = ""
    @State private var startQuiz = false

    var body: some View {
        VStack(spacing: 20) {
            // ✅ 目的付きヘッダー
            VStack(spacing: 8) {
                Text("🎓 資格取得支援")
                    .font(.title2).bold()
                Text("ここでは目指す資格を入力し、その資格に応じた問題演習を開始できます。音声入力も可能です。")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            HStack {
                TextField("どのような資格取得を目指していますか？音声でも入力できます。", text: $certificationName)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                Button("OK") {
                    if !certificationName.isEmpty {
                        startQuiz = true
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .onAppear {
            // ✅ 初回のみ音声案内
            let hasShownGuide = UserDefaults.standard.bool(forKey: "CertificationSupportGuideShown")
            if !hasShownGuide {
                CompanionOverlay.shared.speak(
                    "ここでは取得したい資格を入力してください。音声でも入力できます。",
                    emotion: .gentle
                )
                UserDefaults.standard.set(true, forKey: "CertificationSupportGuideShown")
            }
        }
        // ✅ OK押下で問題演習画面へ遷移
        .sheet(isPresented: $startQuiz) {
            CertificationQuizView(
                certificationName: certificationName,
                questions: generateQuestions(for: certificationName)
            )
        }
    }

    // MARK: - 資格に応じた問題生成（仮）
    private func generateQuestions(for name: String) -> [QuizQuestion] {
        // 本来は資格ごとに過去問やAI生成問題を用意する
        // ここではダミー問題を20問生成
        var result: [QuizQuestion] = []
        for i in 1...20 {
            let difficulty = (i - 1) % 5 + 1 // 1〜5を均等に振り分け
            result.append(
                QuizQuestion(
                    text: "\(name) に関する問題 \(i)",
                    isCorrect: Bool.random(),
                    explanation: "\(name) に関する問題 \(i) の解説です。",
                    difficulty: difficulty
                )
            )
        }
        return result
    }
}
