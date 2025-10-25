//
//  HealthAdviceView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Nutrition/HealthAdviceView.swift
//
//  🎯 ファイルの目的:
//      「食事」「運動」「おくすり」「トータル」の4分岐による健康アドバイスを提示し、
//      AIコンパニオンの音声＋吹き出しで対話を継続しながら、ユーザーの理解・実行を確認する。
//      - 食事：過去の食事から現在の食事のあり方を見直す提言（疾患・プロフィール考慮）
//      - 運動：過去の運動履歴から先の運動提案（疾患による制限の明示）
//      - おくすり：服薬・食事・運動・仕事運転に関する注意の提言（プロフィール参照）
//      - トータル：3分岐の要点を統合し、実行確認・未反応時の終了確認を行う
//      - すべてのアドバイスは SQL（AdviceLogManager）＋ CoreML（各Advisor）に保存可能
//
//  🔗 依存:
//      - CompanionOverlay.swift（音声）
//      - CompanionSpeechBubbleView.swift（吹き出しUI）
//      - UserProfile.swift / UserProfileStorage.swift（プロフィール）
//      - NutritionStorageManager.swift / MealRecord.swift（食事データ）
//      - NutritionAdvisorML.swift（栄養CoreML）
//      - ExerciseStorageManager.swift / ExerciseEntry（運動データ）
//      - ExerciseAdvisorML.swift（運動CoreML）
//      - AdviceLogManager.swift（アドバイスSQL保存）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月8日
//

import SwiftUI

struct HealthAdviceView: View {
    // アドバイステキスト（各分岐別）
    @State private var medicationAdvice: String = ""
    @State private var nutritionAdvice: String = ""
    @State private var exerciseAdvice: String = ""
    @State private var totalAdvice: String = ""

    // チェックボックス
    @State private var medUnderstood: Bool = false              // 💊「理解できた」
    @State private var nutritionWillDo: Bool = false            // 🍽「実行してみます」
    @State private var exerciseWillDo: Bool = false             // 🏃‍♂️「実行してみます」
    @State private var totalExecuted: Bool = false              // 🌐「実行しました」

    // ユーザー自由入力（考えの確認用）
    @State private var userConsiderationText: String = ""

    // 未反応監視
    @State private var lastInteraction: Date = Date()
    @State private var showExitPrompt: Bool = false

    // プロフィール
    private var profile: UserProfile? = UserProfileStorage.shared.loadLatest()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("🩺 健康アドバイス")
                        .font(.title2)
                        .bold()

                    // 吹き出し常時表示（最新のアドバイスを優先して表示）
                    CompanionSpeechBubbleView(text: currentBubbleText())

                    // MARK: - 食事アドバイス
                    adviceSection(
                        title: "🍽 食事に関するアドバイス",
                        prefaceSpeech: "過去の食事内容から現在の食事のあり方を見直すアドバイスです。",
                        action: generateNutritionAdvice,
                        adviceText: $nutritionAdvice
                    )
                    Toggle("実行してみます。", isOn: $nutritionWillDo)
                        .onChange(of: nutritionWillDo) { newValue in
                            touch()
                            if newValue {
                                CompanionOverlay.shared.speak("素晴らしいです！今日から一つずつ実践してみましょう。")
                            } else {
                                CompanionOverlay.shared.speak("なにかお考えはありますか？気軽に教えてください。")
                            }
                        }

                    // ユーザーの考え（自由入力）
                    if !nutritionWillDo {
                        considerationField()
                    }

                    Divider().padding(.vertical, 8)

                    // MARK: - 運動アドバイス
                    adviceSection(
                        title: "🏃‍♂️ 運動アドバイス",
                        prefaceSpeech: "過去の運動歴から、これから先どのような運動をすれば良いかご提案します。疾患の制限にも配慮します。",
                        action: generateExerciseAdvice,
                        adviceText: $exerciseAdvice
                    )
                    Toggle("実行してみます。", isOn: $exerciseWillDo)
                        .onChange(of: exerciseWillDo) { newValue in
                            touch()
                            if newValue {
                                CompanionOverlay.shared.speak("無理のない範囲で、短い時間から継続していきましょう。")
                            } else {
                                CompanionOverlay.shared.speak("なにかお考えはありますか？避けたい運動があれば教えてください。")
                            }
                        }

                    if !exerciseWillDo {
                        considerationField()
                    }

                    Divider().padding(.vertical, 8)

                    // MARK: - おくすりアドバイス
                    adviceSection(
                        title: "💊 おくすりアドバイス",
                        prefaceSpeech: "現在服用しているお薬の飲み合わせ、食べ物、運動、仕事・運転に関する注意点をお伝えします。",
                        action: generateMedicationAdvice,
                        adviceText: $medicationAdvice
                    )
                    Toggle("理解できた。", isOn: $medUnderstood)
                        .onChange(of: medUnderstood) { newValue in
                            touch()
                            if newValue {
                                CompanionOverlay.shared.speak("理解いただけて安心しました。不明点があればいつでも聞いてください。")
                            } else {
                                CompanionOverlay.shared.speak("どの部分が分かりにくかったでしょう？ポイントを教えてください。")
                            }
                        }

                    if !medUnderstood {
                        considerationField()
                    }

                    Divider().padding(.vertical, 8)

                    // MARK: - トータルアドバイス
                    Button {
                        touch()
                        generateTotalAdvice()
                        CompanionOverlay.shared.speak("実行してください！今日の一歩が未来を変えます。")
                    } label: {
                        Label("🌐 トータルアドバイスを提示", systemImage: "globe")
                    }
                    .buttonStyle(.borderedProminent)

                    if !totalAdvice.isEmpty {
                        Text(totalAdvice)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.blue.opacity(0.06))
                            .cornerRadius(8)
                    }

                    Toggle("トータルアドバイスを実行しました", isOn: $totalExecuted)
                        .onChange(of: totalExecuted) { newValue in
                            touch()
                            if newValue {
                                CompanionOverlay.shared.speak("素晴らしいです！今日はここで画面を閉じますね。")
                            } else {
                                CompanionOverlay.shared.speak("なにかお考えはありますか？実行しやすい形に調整しましょう。")
                            }
                        }

                    if !totalExecuted {
                        considerationField()
                    }

                    // 未反応時の終了確認表示
                    if showExitPrompt {
                        VStack(spacing: 12) {
                            Text("会話を終了してもよいですか？")
                                .font(.headline)
                            HStack(spacing: 16) {
                                Button("終了") {
                                    touch()
                                    CompanionOverlay.shared.speak("会話を終了します。またいつでも呼んでください。")
                                    // シートを閉じるのは親側で制御されるため、ここでは案内のみ
                                }
                                .buttonStyle(.borderedProminent)

                                Button("続ける") {
                                    touch()
                                    CompanionOverlay.shared.speak("続けましょう。あなたのペースで大丈夫です。")
                                    showExitPrompt = false
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.08))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("健康アドバイス")
        }
        .onAppear {
            touch()
            CompanionOverlay.shared.speak("お薬・食事・運動の観点から、あなたに最適な健康プランを提案します。")
            startInactivityTimer()
        }
    }

    // MARK: - 共通セクションビルダー
    private func adviceSection(title: String, prefaceSpeech: String, action: () -> Void, adviceText: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Button {
                touch()
                CompanionOverlay.shared.speak(prefaceSpeech)
                action()
            } label: {
                Label("アドバイスを生成", systemImage: "sparkles")
            }
            .buttonStyle(.bordered)

            if !adviceText.wrappedValue.isEmpty {
                Text(adviceText.wrappedValue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.gray.opacity(0.06))
                    .cornerRadius(8)
            }
        }
    }

    private func considerationField() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("あなたのお考え")
                .font(.subheadline)
            TextField("例: 今週は仕事が忙しいので、短い散歩から…", text: $userConsiderationText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: userConsiderationText) { _ in touch() }
        }
        .padding(.vertical, 4)
    }

    // MARK: - アドバイス生成（食事）
    private func generateNutritionAdvice() {
        let meals = NutritionStorageManager.shared.fetchAll()
        let summary = NutritionSummaryInput(
            days: 7,
            calories: meals.reduce(0) { $0 + $1.calories },
            protein: meals.reduce(0) { $0 + $1.protein },
            fat: meals.reduce(0) { $0 + $1.fat },
            carbs: meals.reduce(0) { $0 + $1.carbs }
        )
        var advice = NutritionAdvisorML().advice(for: summary)

        // 疾患配慮（プロフィールに基づく補記）
        if let p = profile, !p.isHealthy {
            let diseases = p.diseases.joined(separator: "・")
            advice += "\n【配慮事項】現在の疾患（\(diseases)）に合わせ、塩分・糖質・脂質の過剰摂取を避け、野菜とタンパク質中心の構成を意識しましょう。"
        }

        nutritionAdvice = advice
        saveAdviceSQL(kind: "Nutrition", text: advice)
    }

    // MARK: - アドバイス生成（運動）
    private func generateExerciseAdvice() {
        // 週集計（モデルに渡すダミー平均METsは今後詳細化）
        let totalWeek = ExerciseStorageManager.shared.totalCaloriesThisWeek()
        let sessionsCountEstimate =  max(1, Int(totalWeek / 120.0)) // ざっくり推定（将来は実セッション数に置換）
        let summary = ExerciseSummaryInput(days: 7, totalCalories: totalWeek, sessionsCount: sessionsCountEstimate, avgMets: 4.0)

        var advice = ExerciseAdvisorML().advice(for: summary)

        if let p = profile, !p.isHealthy, !p.diseases.isEmpty {
            advice += "\n【制限】医師の指示に従い、痛みや息切れを伴う運動は避け、短時間の歩行・ストレッチから始めましょう。"
        }

        exerciseAdvice = advice
        saveAdviceSQL(kind: "Exercise", text: advice)
    }

    // MARK: - アドバイス生成（おくすり）
    private func generateMedicationAdvice() {
        var advice = "服薬中のお薬と食事・運動・仕事運転に関する注意点をお伝えします。気になる食べ合わせがあれば事前に確認しましょう。"

        if let p = profile {
            if !p.supplements.isEmpty {
                advice += "\n【併用注意】サプリメント（例: \(p.supplements.first?.name ?? "サプリ")）は一部薬剤と作用が重なる場合があります。併用は注意してください。"
            }
            if p.tobaccoType != .none {
                advice += "\n【喫煙】喫煙は薬物代謝に影響する場合があります。服薬中の効果に変化が出ることがあります。"
            }
        }

        medicationAdvice = advice
        saveAdviceSQL(kind: "Medication", text: advice)
    }

    // MARK: - アドバイス生成（トータル）
    private func generateTotalAdvice() {
        var combined = [String]()
        if !medicationAdvice.isEmpty { combined.append("💊 おくすり: \(medicationAdvice)") }
        if !nutritionAdvice.isEmpty { combined.append("🍽 食事: \(nutritionAdvice)") }
        if !exerciseAdvice.isEmpty { combined.append("🏃‍♂️ 運動: \(exerciseAdvice)") }

        let header = "お薬・食事・運動の観点から、あなたに合う健康プランです。"
        totalAdvice = ([header] + combined).joined(separator: "\n\n")
        saveAdviceSQL(kind: "Total", text: totalAdvice)
    }

    // MARK: - SQL保存
    private func saveAdviceSQL(kind: String, text: String) {
        let uid = profile?.id ?? 0
        AdviceLogManager().insertAdvice(userId: uid, medicationName: kind, advice: text)
    }

    // MARK: - 吹き出し内容の決定
    private func currentBubbleText() -> String {
        if !totalAdvice.isEmpty { return totalAdvice }
        if !medicationAdvice.isEmpty { return medicationAdvice }
        if !nutritionAdvice.isEmpty { return nutritionAdvice }
        if !exerciseAdvice.isEmpty { return exerciseAdvice }
        return "必要なアドバイスのボタンを選んでください。"
    }

    // MARK: - 未反応監視
    private func startInactivityTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince(lastInteraction)
            if elapsed >= 5.0 && !showExitPrompt {
                showExitPrompt = true
                CompanionOverlay.shared.speak("会話を終了してもよいですか？「終了」または「続ける」を選んでください。")
            }
        }
    }

    private func touch() {
        lastInteraction = Date()
        if showExitPrompt { showExitPrompt = false }
    }
}
