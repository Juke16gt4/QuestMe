//
//  ReviewQuizView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Certification/ReviewQuizView.swift
//
//  🎯 ファイルの目的:
//      ユーザーが過去に間違えた問題を復習する画面。
//      - 難易度を優しくしてランダム出題。
//      - 解説欄に「初回解答日」を明記。
//      - 全問終了後に「弱点克服まとめ」を作成するか確認。
//      - 保存はカレンダーホルダー、FolderName=弱点命題、FileName=日付＋連番。
//      - 「閉じる」でコンパニオン拡大画面へ戻る。
//      - 初回のみ音声案内を流す。
//      - 前回保存したまとめを起動時に読み込み、冒頭＋アドバイス部分を音声で案内。
//      - AIアドバイスは正答率とキーワードに応じて動的生成。
//

import SwiftUI

struct ReviewQuizView: View {
    let weakPointName: String
    let reviewQuestions: [ReviewQuestion]
    
    @State private var currentIndex = 0
    @State private var correctCount = 0
    @State private var showExplanation = false
    @State private var finished = false
    @State private var askForSummary = false
    @State private var summaryCreated = false
    @State private var lastSummary: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("🔁 復習モード: \(weakPointName)")
                    .font(.title2).bold()
                Text("過去に間違えた問題を優しく復習します。")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // ✅ 前回のまとめ表示
            if let summary = lastSummary {
                VStack(alignment: .leading, spacing: 8) {
                    Text("📖 前回の弱点克服まとめ")
                        .font(.headline)
                    ScrollView {
                        Text(summary)
                            .font(.footnote)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
            }
            
            if !finished {
                Text("問題 \(currentIndex + 1) / \(reviewQuestions.count)")
                    .font(.headline)
                
                Text(reviewQuestions[currentIndex].text)
                    .font(.title3)
                    .padding()
                
                HStack {
                    Button("○") { answer(true) }
                        .buttonStyle(.borderedProminent)
                    Button("×") { answer(false) }
                        .buttonStyle(.borderedProminent)
                }
                
                if showExplanation {
                    VStack(spacing: 12) {
                        Text("解答・解説")
                            .font(.headline)
                        Text(reviewQuestions[currentIndex].explanation)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .scaleEffect(1.4)
                            .animation(.easeInOut(duration: 0.3), value: showExplanation)
                        
                        Text("初回解答日: \(reviewQuestions[currentIndex].firstAnsweredAt)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        Button("次の問題へ") {
                            nextQuestion()
                        }
                    }
                }
                
                if currentIndex > 0 {
                    Text("正答数: \(correctCount) / \(currentIndex)  正答率: \(correctRate(), specifier: "%.1f")%")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            } else {
                Text("復習が終了しました。お疲れさまでした。")
                    .font(.title3)
                    .padding()
                
                Text("最終正答率: \(correctRate(), specifier: "%.1f")%")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                if !summaryCreated {
                    Button("弱点克服まとめを作成しますか？") {
                        CompanionOverlay.shared.speak("あなたの弱点克服へのまとめを作成しますか？", emotion: .gentle)
                        askForSummary = true
                    }
                }
                
                if askForSummary {
                    HStack {
                        Button("はい") {
                            createSummary()
                        }
                        Button("いいえ") {
                            CompanionOverlay.shared.speak("まとめは作成せず、問題画面に戻ります。", emotion: .neutral)
                            askForSummary = false
                        }
                    }
                }
                
                if summaryCreated {
                    Text("弱点克服まとめを保存しました。")
                        .foregroundColor(.green)
                }
                
                Divider()
                Button("閉じる") {
                    // Companion拡大画面へ戻る処理
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            // ✅ 初回のみ音声案内
            let hasShownGuide = UserDefaults.standard.bool(forKey: "ReviewQuizGuideShown")
            if !hasShownGuide {
                CompanionOverlay.shared.speak(
                    "ここでは過去に間違えた問題を優しく復習します。解説には初回解答日も表示されます。",
                    emotion: .gentle
                )
                UserDefaults.standard.set(true, forKey: "ReviewQuizGuideShown")
            }
            
            // ✅ 前回のまとめを読み込み
            if let lastPath = UserDefaults.standard.string(forKey: "LastSummaryPath") {
                if let text = try? String(contentsOf: URL(fileURLWithPath: lastPath)) {
                    // 要約（タイトル＋アドバイス部分のみ抽出）
                    let lines = text.split(separator: "\n")
                    let title = lines.first ?? ""
                    let adviceIndex = lines.firstIndex(where: { $0.contains("AIからのアドバイス") })
                    var advice = ""
                    if let idx = adviceIndex, idx + 1 < lines.count {
                        advice = lines[(idx+1)...].joined(separator: "\n")
                    }
                    let summaryText = "\(title)\n\n💡 アドバイス:\n\(advice)"
                    lastSummary = summaryText
                    
                    CompanionOverlay.shared.speak("前回のまとめです。\(title)。アドバイスは次の通りです。\(advice)", emotion: .gentle)
                }
            }
        }
    }
    
    // MARK: - 回答処理
    private func answer(_ userAnswer: Bool) {
        if userAnswer == reviewQuestions[currentIndex].isCorrect {
            correctCount += 1
            CompanionOverlay.shared.speak("正解です。", emotion: .happy)
        } else {
            CompanionOverlay.shared.speak("不正解です。", emotion: .sad)
        }
        showExplanation = true
    }
    
    // MARK: - 次の問題へ
    private func nextQuestion() {
        if currentIndex + 1 < reviewQuestions.count {
            currentIndex += 1
            showExplanation = false
        } else {
            finished = true
            CompanionOverlay.shared.speak("復習が終了しました。お疲れさまでした。", emotion: .encouraging)
        }
    }
    
    // MARK: - 正答率計算
    private func correctRate() -> Double {
        guard currentIndex > 0 else { return 0 }
        return (Double(correctCount) / Double(currentIndex)) * 100
    }
    
    // MARK: - 弱点克服まとめ作成
    private func createSummary() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        let fileName = "\(formatter.string(from: Date())).md"
        
        let keywords = reviewQuestions.map { $0.keyword }.joined(separator: ", ")
        let rate = correctRate()
        
        // ✅ 正答率に応じた動的アドバイス
        let advice: String
        switch rate {
        case 80...100:
            advice = "- 正答率が高く、基礎は十分に理解できています。\n- 今後は「\(keywords)」に関連する応用問題に挑戦すると良いでしょう。"
        case 50..<80:
            advice = "- 一部に弱点が見られます。「\(keywords)」を重点的に復習しましょう。\n- 間違えた問題を繰り返し解くことで理解が深まります。"
        default:
            advice = "- 正答率が低めです。まずは「\(keywords)」の基礎を整理しましょう。\n- 教科書や基本問題集を使って土台を固めることをおすすめします。"
        }
        
        let markdown = """
                # 弱点克服まとめ（\(weakPointName)）
                
                ## 📅 作成日
                \(Date())
                
                ## 🎯 弱点の命題
                - \(weakPointName)
                
                ## 📌 関連キーワード
                - \(keywords)
                
                ## 📊 復習結果
                - 出題数: \(reviewQuestions.count)問
                - 正答数: \(correctCount)問
                - 正答率: \(String(format: "%.1f", rate))%
                
                ## 📝 解答履歴
                \(reviewQuestions.enumerated().map {
                    "\($0+1). 初回解答日: \($1.firstAnsweredAt) → 今回: \($1.isCorrect ? "正解" : "不正解")"
                }.joined(separator: "\n"))
                
                ## 💡 AIからのアドバイス
                \(advice)
                """
        
        // 保存処理（例: DocumentDirectory 内に保存）
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let folderURL = dir.appendingPathComponent(weakPointName)
            try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            let fileURL = folderURL.appendingPathComponent(fileName)
            try? markdown.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // ✅ 前回のまとめパスを記録して次回起動時に読み上げ可能にする
            UserDefaults.standard.set(fileURL.path, forKey: "LastSummaryPath")
        }
        
        CompanionOverlay.shared.speak("弱点克服まとめを保存しました。", emotion: .happy)
        summaryCreated = true
    }
}

