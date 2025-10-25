//
//  ExerciseSessionView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Exercise/ExerciseSessionView.swift
//
//  🎯 ファイルの目的:
//      Companionアニメーション＋音声ガイド＋ストップウォッチ＋自動保存＋ダッシュボード遷移＋健康アドバイス
//
//  🔗 依存:
//      - CompanionOverlay.swift（音声）
//      - CompanionExerciseAnimationView.swift（アニメーション）
//      - ExerciseActivity.swift（運動定義）
//      - ExerciseStorageManager.swift（集計）
//      - MLAdvisor.swift（運動アドバイス）
//      - ExerciseDashboardView.swift（遷移先）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月19日
//

import SwiftUI

struct ExerciseSessionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedActivity: ExerciseActivity = ExerciseActivity(name: "速歩", mets: 4.3, minutesPerEx: 30)
    @State private var duration: Int = 0
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var weightKg: Double = 65
    @State private var showSaved = false
    @State private var navigateToDashboard = false
    @State private var navigateToMain = false
    @State private var animationState: CompanionExerciseAnimationView.AnimationState = .idle
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // 🧍‍♂️ Companionアニメーション
                CompanionExerciseAnimationView(state: animationState)
                
                Text("🏃‍♂️ 運動セッション")
                    .font(.title2)
                    .bold()
                
                Picker("運動項目", selection: $selectedActivity) {
                    ForEach(ExerciseActivity.defaultList, id: \.id) { activity in
                        Text("\(activity.name) (\(String(format: "%.1f", activity.mets)) METs)").tag(activity)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 120)
                
                HStack {
                    Text("体重 (kg)")
                    Spacer()
                    TextField("kg", value: $weightKg, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                }
                .padding(.horizontal)
                
                Text("⏱ 経過時間: \(duration) 分")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    Button("Start") {
                        startTimer()
                    }.disabled(isRunning)
                    
                    Button("Pause") {
                        pauseTimer()
                    }.disabled(!isRunning)
                    
                    Button("Stop") {
                        stopAndSave()
                    }.disabled(!isRunning)
                }
                
                Divider().padding(.vertical)
                
                VStack(spacing: 8) {
                    Text("🔥 今回の消費カロリー: \(Int(currentCalories())) kcal")
                    Text("📅 本日の合計: \(Int(todayCalories())) kcal")
                }
                
                Divider().padding(.vertical)
                
                Button("運動ダッシュボードに戻る") {
                    CompanionOverlay.shared.speak("運動ダッシュボードに戻ります。記録を振り返ってみましょう。")
                    navigateToDashboard = true
                }
                .buttonStyle(.bordered)
                
                Button("メイン画面へ戻る") {
                    CompanionOverlay.shared.speak("メイン画面に戻ります。お疲れさまでした！")
                    navigateToMain = true
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
            .padding()
            .navigationTitle("運動記録")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("❓ヘルプ") {
                        CompanionOverlay.shared.speak(helpText(for: currentLang()))
                    }
                }
            }
            .onAppear {
                CompanionOverlay.shared.speak("""
                運動ですね。下に運動項目があります。
                選択した運動項目に従って消費カロリー（METS方式）が表示されていますから、
                これからされる運動を探して貰い、決定ボタンを押してください。
                では、おけがされない程度に頑張ってきてください。
                """)
                animationState = .warmup
            }
            .navigationDestination(isPresented: $navigateToDashboard) {
                ExerciseDashboardView()
            }
            .navigationDestination(isPresented: $navigateToMain) {
                ExpandedCompanionView()
            }
        }
    }
    
    // MARK: - タイマー制御
    private func startTimer() {
        isRunning = true
        animationState = .exercising
        CompanionOverlay.shared.speak("記録を開始しました。がんばってください！")
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            duration += 1
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        CompanionOverlay.shared.speak("一時停止しました。再開するには Start を押してください。")
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        animationState = .cheering
    }
    
    // MARK: - 保存処理
    private func stopAndSave() {
        stopTimer()
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let fileName = formatter.string(from: now)
        
        let year = Calendar.current.component(.year, from: now)
        let month = Calendar.current.component(.month, from: now)
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Calendar/\(year)年/\(month)月/運動", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        
        let hours = Double(duration) / 60.0
        let kcal = selectedActivity.mets * hours * weightKg * 1.05
        
        let payload: [String: Any] = [
            "activity": selectedActivity.name,
            "mets": selectedActivity.mets,
            "durationMinutes": duration,
            "weightKg": weightKg,
            "calories": kcal,
            "timestamp": ISO8601DateFormatter().string(from: now)
        ]
        
        let fileURL = folder.appendingPathComponent("\(fileName).json")
        if let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted]) {
            try? data.write(to: fileURL)
            CompanionOverlay.shared.speak("保存しました。お疲れさまでした！")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                CompanionOverlay.shared.speak("今回の運動は \(selectedActivity.name)、\(duration) 分、消費カロリーは \(Int(kcal)) キロカロリーでした。")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    CompanionOverlay.shared.speak("健康アドバイスを表示します。")
                    navigateToDashboard = true
                }
            }
        }
    }
    
    // MARK: - カロリー計算
    private func currentCalories() -> Double {
        let hours = Double(duration) / 60.0
        return selectedActivity.mets * hours * weightKg * 1.05
    }
    
    private func todayCalories() -> Double {
        ExerciseStorageManager.shared.totalCaloriesToday()
    }
    
    // MARK: - 言語対応
    private func currentLang() -> String {
        SpeechSync().currentLanguage
    }
    
    private func helpText(for lang: String) -> String {
        switch lang {
        case "ja":
            return "運動項目を選び、Startで記録を開始してください。Stopを押すと自動保存され、消費カロリーが表示されます。Companionが応援してくれますので、安心して取り組んでください。"
            
        case "en":
            return "Select an exercise and press Start to begin recording. Press Stop to save automatically and view calories burned. Your Companion will cheer you on!"
            
        case "fr":
            return "Sélectionnez une activité et appuyez sur Start pour commencer l'enregistrement. Appuyez sur Stop pour enregistrer automatiquement et voir les calories brûlées. Votre compagnon vous encourage !"
            
        case "de":
            return "Wählen Sie eine Aktivität und drücken Sie Start, um die Aufzeichnung zu beginnen. Stop speichert automatisch und zeigt die verbrannten Kalorien an. Ihr Begleiter feuert Sie an!"
            
        case "es":
            return "Seleccione una actividad y presione Start para comenzar. Presione Stop para guardar automáticamente y ver las calorías quemadas. ¡Su compañero lo animará!"
            
        case "zh":
            return "选择运动项目后点击开始记录，点击停止将自动保存并显示消耗的卡路里。您的AI伙伴会为您加油！"
            
        case "ko":
            return "운동 항목을 선택하고 시작을 누르면 기록이 시작됩니다. 정지를 누르면 자동 저장되며 소모 칼로리가 표시됩니다. 컴패니언이 응원해줍니다!"
            
        case "ru":
            return "Выберите упражнение и нажмите Start для начала записи. Нажмите Stop для автоматического сохранения и просмотра сожжённых калорий. Ваш компаньон поддержит вас!"
            
        case "ar":
            return "اختر النشاط واضغط على Start لبدء التسجيل. اضغط على Stop للحفظ التلقائي وعرض السعرات المحروقة. سيرافقك مساعدك بالتشجيع!"
            
        case "pt":
            return "Selecione uma atividade e pressione Start para começar. Pressione Stop para salvar automaticamente e ver as calorias queimadas. Seu companheiro irá animá-lo!"
            
        case "it":
            return "Seleziona un'attività e premi Start per iniziare. Premi Stop per salvare automaticamente e vedere le calorie bruciate. Il tuo compagno ti incoraggerà!"
            
        case "hi":
            return "व्यायाम चुनें और Start दबाएँ। Stop दबाने पर स्वतः सहेजें और कैलोरी देखें। आपका साथी आपको प्रोत्साहित करेगा!"
            
        default:
            return "Select an exercise and press Start to begin. Press Stop to save and view calories burned. Your Companion will cheer you on!"
        }
    }
}
