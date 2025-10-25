//
//  FloatingCompanionOverlayView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/FloatingCompanionOverlayView.swift
//
//  🎯 目的:
//      フローティングコンパニオンをタップして儀式パネルを開き、各種儀式ビューへ遷移。
//      - 表情操作・吹き出し表示・音声発話・感情ログ保存に対応。
//      - 健康アドバイスメニューで「おくすり/食事/運動/総合/美容」の5分岐ダイアログ表示。
//      - 12言語対応の「メイン画面へ」「もどる」「ヘルプ」ボタンを標準化（各画面で実装）。
//
//  🔗 連動:
//      - CompanionSpeechBubbleView.swift
//      - CompanionAvatarView.swift
//      - EmotionLogRepository.swift
//      - MedicationDialogLauncherView.swift / NutritionCameraRecordView.swift /   ExerciseSessionView.swift / LaboView.swift
//      - CalendarView.swift / MeetingRecordingView.swift / LocationInfoView.swift / CompanionGeneratorView.swift / UserProfileEditorView.swift
//      - CertificationView.swift
//      - HealthAdviceView.swift（健康アドバイスの他分岐）
//      - BeautyCaptureView.swift / BeautyHistoryView.swift / SleepTimerView.swift（美容アドバイス配下）
//
//  👤 作成者: 津村 淳一
//  📅 改変日: 2025-10-22（コンパニオン設定 → CompanionGeneratorView に変更）
//

import SwiftUI
import CoreLocation
import AVFoundation

struct FloatingCompanionOverlayView: View {
    @State private var showRitualPanel = false
    @State private var showSpeechBubble = false
    @State private var currentEmotion: EmotionType = .neutral
    @State private var currentSpeechText: String = ""
    @State private var companionImage: UIImage = UIImage(systemName: "person.crop.circle.fill")!

    // 儀式表示状態（メイン）
    @State private var showMedicationDialog = false
    @State private var showNutritionView = false
    @State private var showExerciseView = false
    @State private var showLabDataDialog = false
    @State private var showRegionInfo = false
    @State private var showScheduleView = false
    @State private var showCompanionCreation = false
    @State private var showVoiceSetting = false
    @State private var showLegacyInsert = false
    @State private var showProfileEdit = false
    @State private var showRecordingConversion = false
    @State private var showSpecializedKnowledge = false

    // 健康アドバイス（5分岐ダイアログ）
    @State private var showHealthAdvice = false
    @State private var showMedicationAdvice = false
    @State private var showNutritionAdvice = false
    @State private var showExerciseAdvice = false
    @State private var showLifestyleAdvice = false
    @State private var showBeautyAdvice = false

    // 海外交流関連
    @State private var showInterpreterSubmenu = false
    @State private var showInterpreterDialog = false
    @State private var showMannersDialog = false
    @State private var regionManners: RegionManners?

    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 12) {
                    if showSpeechBubble {
                        CompanionSpeechBubbleView(text: currentSpeechText, emotion: currentEmotion)
                            .padding(.horizontal, 16)
                    }

                    CompanionAvatarView(image: companionImage, emotion: $currentEmotion) { newEmotion in
                        currentSpeechText = String(format: NSLocalizedString("NowFeelingFormat", comment: "今は %@ の気分です。"), newEmotion.label)
                        showSpeechBubble = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { showSpeechBubble = false }
                    }

                    Spacer()

                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .onTapGesture {
                            speak(NSLocalizedString("OpenPanel", comment: "コンパニオン操作パネルを開きます。"), emotion: .gentle)
                            showRitualPanel = true
                        }
                        .padding(.bottom, 12)
                }
            }
            .navigationTitle(NSLocalizedString("CompanionScreenTitle", comment: "コンパニオン画面"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Help", comment: "ヘルプ")) {
                        speak(NSLocalizedString("CompanionScreenHelp", comment: "この画面の説明"), emotion: .neutral)
                    }
                }
            }
        }

        // 儀式一覧パネル
        .sheet(isPresented: $showRitualPanel) {
            VStack(spacing: 12) {
                Text(NSLocalizedString("OperationList", comment: "🧭 操作一覧")).font(.headline)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    Button(NSLocalizedString("Medicines", comment: "💊 おくすり")) {
                        speak(NSLocalizedString("StartMedicine", comment: "おくすり登録他を開始します。"), emotion: .encouraging)
                        showMedicationDialog = true
                    }
                    Button(NSLocalizedString("NutritionMeal", comment: "🥗 栄養・食事")) {
                        speak(NSLocalizedString("StartMealPhoto", comment: "食事を撮影します。"), emotion: .thinking)
                        showNutritionView = true
                    }
                    Button(NSLocalizedString("Exercise", comment: "🏃‍♂️ 運動")) {
                        speak(NSLocalizedString("StartExercise", comment: "運動記録を開始します。"), emotion: .happy)
                        showExerciseView = true
                    }
                    Button(NSLocalizedString("HealthAdvice", comment: "🩺 健康アドバイス")) {
                        speak(NSLocalizedString("StartHealthAdvice", comment: "健康アドバイスを開始します。"), emotion: .neutral)
                        showHealthAdvice = true
                    }
                    Button(NSLocalizedString("RegionInfo", comment: "🌏 地域情報")) {
                        speak(NSLocalizedString("StartRegionInfo", comment: "地域情報の取得を開始します。"), emotion: .happy)
                        showRegionInfo = true
                    }
                    Button(NSLocalizedString("ScheduleMyEvent", comment: "🗓 スケジュール・マイイベント")) {
                        speak(NSLocalizedString("StartSchedule", comment: "スケジュールとマイイベントの組込を開始します。"), emotion: .thinking)
                        showScheduleView = true
                    }
                    Button(NSLocalizedString("MeetingLecture", comment: "🎓 会議・講義")) {
                        speak(NSLocalizedString("StartMeetingLecture", comment: "会議・講義の録音と議事録保存を開始します。"), emotion: .neutral)
                        showRecordingConversion = true
                    }
                    Button(NSLocalizedString("CompanionSettings", comment: "🛠 コンパニオン設定")) {
                        speak(NSLocalizedString("StartCompanionSettings", comment: "コンパニオンの設定を開始します。"), emotion: .encouraging)
                        showCompanionCreation = true
                    }
                    Button(NSLocalizedString("ProfileSettings", comment: "📄 プロファイル設定")) {
                        speak(NSLocalizedString("StartProfileSettings", comment: "プロフィール設定を開始します。"), emotion: .neutral)
                        showProfileEdit = true
                    }
                    Button(NSLocalizedString("LabData", comment: "🧪 検査値データ")) {
                        speak(NSLocalizedString("StartLabData", comment: "検査値データの記録と読み取りを開始します。"), emotion: .neutral)
                        showLabDataDialog = true
                    }
                    Button(NSLocalizedString("InternationalTravel", comment: "🌍 海外旅行")) {
                        speak(NSLocalizedString("OpenTravelMenu", comment: "海外旅行メニューを開きます。"), emotion: .gentle)
                        showInterpreterSubmenu = true
                    }
                    Button(NSLocalizedString("CertAndSpecialty", comment: "🧠 専門・資格取得")) {
                        speak(NSLocalizedString("StartCertification", comment: "QuestMeは専門知識にも対応しています。"), emotion: .gentle)
                        showSpecializedKnowledge = true
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .presentationDetents([.fraction(0.05), .medium, .large])
            .presentationDragIndicator(.visible)
        }

        // 各儀式ビューとの連動（メイン）
                .sheet(isPresented: $showMedicationDialog) { MedicationDialogLauncherView() }
                .sheet(isPresented: $showNutritionView) { NutritionCameraRecordView() }
                .sheet(isPresented: $showExerciseView) { ExerciseSessionView() }
                .sheet(isPresented: $showLabDataDialog) { LaboView() }
                .sheet(isPresented: $showRecordingConversion) { MeetingRecordingView() }
                .sheet(isPresented: $showRegionInfo) { LocationInfoView() }
                .sheet(isPresented: $showScheduleView) { CalendarView() }
                // ✅ 修正箇所：CompanionSetupView → CompanionGeneratorView に変更
                .sheet(isPresented: $showCompanionCreation) { CompanionGeneratorView() }
                .sheet(isPresented: $showProfileEdit) { UserProfileEditorView(profile: UserProfile.empty()) }
                .sheet(isPresented: $showSpecializedKnowledge) { CertificationView() }

                // 海外旅行サブメニュー
                .sheet(isPresented: $showInterpreterSubmenu) {
                    VStack(spacing: 16) {
                        Text(NSLocalizedString("TravelMenuTitle", comment: "🌍 海外旅行メニュー"))
                            .font(.title2).bold()
                        Button(NSLocalizedString("LocalManners", comment: "📍 現地マナー")) {
                            speak(NSLocalizedString("CheckManners", comment: "現地マナーを確認します。"), emotion: .neutral)
                            MannersAPIManager.shared.fetchManners(
                                for: CLLocationCoordinate2D(latitude: 34.67, longitude: 131.85)
                            ) { result in
                                DispatchQueue.main.async {
                                    self.regionManners = result
                                    self.showMannersDialog = true
                                }
                            }
                        }
                        Button(NSLocalizedString("InterpreterPods", comment: "🎧 通訳（iPods連携）")) {
                            speak(NSLocalizedString("SwitchInterpreter", comment: "iPodsを利用した通訳モードに切り替えます。"), emotion: .sad)
                            showInterpreterDialog = true
                        }
                        Spacer()
                    }
                    .padding()
                }
                .sheet(isPresented: $showMannersDialog) {
                    if let regionManners = regionManners {
                        MannersExplanationView(regionManners: regionManners)
                    } else {
                        Text(NSLocalizedString("MannersFetchFailed", comment: "マナー情報を取得できませんでした。"))
                    }
                }
                .sheet(isPresented: $showInterpreterDialog) {
                    InterpreterModeSelector { text, emotion in
                        speak(text, emotion: emotion)
                    }
                }

                // 健康アドバイス（5分岐ダイアログ）
                .sheet(isPresented: $showHealthAdvice) {
                    VStack(spacing: 16) {
                        Text(NSLocalizedString("HealthAdviceMenu", comment: "🩺 健康アドバイスメニュー"))
                            .font(.title2).bold()

                        Button(NSLocalizedString("MedicationAdvice", comment: "💊 おくすりアドバイス")) {
                            speak(NSLocalizedString("MedicationAdviceStart", comment: "服薬状況を確認します。"), emotion: .neutral)
                            showMedicationAdvice = true
                        }
                        Button(NSLocalizedString("FoodAdvice", comment: "🍽 食事アドバイス")) {
                            speak(NSLocalizedString("FoodAdviceStart", comment: "食事記録を確認します。"), emotion: .neutral)
                            showNutritionAdvice = true
                        }
                        Button(NSLocalizedString("ExerciseAdvice", comment: "🏃‍♀️ 運動アドバイス")) {
                            speak(NSLocalizedString("ExerciseAdviceStart", comment: "運動記録を確認します。"), emotion: .neutral)
                            showExerciseAdvice = true
                        }
                        Button(NSLocalizedString("LifestyleAdvice", comment: "🧠 総合アドバイス")) {
                            speak(NSLocalizedString("LifestyleAdviceStart", comment: "生活習慣全体を評価します。"), emotion: .neutral)
                            showLifestyleAdvice = true
                        }
                        Button(NSLocalizedString("BeautyAdvice", comment: "💄 美容アドバイス")) {
                            speak(NSLocalizedString("BeautyAdviceStart", comment: "美容チェックを開始します。撮影して解析しましょう。"), emotion: .happy)
                            showBeautyAdvice = true
                        }
                    }
                    .padding()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }

                // 分岐先の各アドバイスビュー（モーダル遷移）
                .sheet(isPresented: $showMedicationAdvice) {
                    LabAdviceView(results: LabResultStorageManager.shared.loadAll())
                }
                .sheet(isPresented: $showNutritionAdvice) { NutritionAdviceView() }
                .sheet(isPresented: $showExerciseAdvice) { ExerciseAdviceView() }
                .sheet(isPresented: $showLifestyleAdvice) { LifestyleAdviceView() }
        // 美容アドバイス配下のツールバー
                .sheet(isPresented: $showBeautyAdvice) {
                    NavigationStack {
                        List {
                            NavigationLink(NSLocalizedString("PhotoAndAnalysis", comment: "📷 撮影と解析"), destination: BeautyCaptureView())
                            NavigationLink(NSLocalizedString("HistoryReview", comment: "📊 履歴の振り返り"), destination: BeautyHistoryView())
                            NavigationLink(NSLocalizedString("BeautySleepTimer", comment: "⏰ 美容専用睡眠タイマー"), destination: SleepTimerView())
                        }
                        .navigationTitle(NSLocalizedString("BeautyAdviceTitle", comment: "美容アドバイス"))
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarLeading) {
                                Button(NSLocalizedString("MainScreen", comment: "メイン画面へ")) {
                                    // ✅ メイン画面へ戻る際に声紋認証を再ロック
                                    VoiceprintAuthManager.shared.restoreIfNeeded()
                                    // メイン画面へ戻る処理
                                }
                                Button(NSLocalizedString("Back", comment: "もどる")) {
                                    // シート閉鎖処理
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(NSLocalizedString("Help", comment: "ヘルプ")) {
                                    speak(NSLocalizedString("BeautyAdviceMenuHelp", comment: "美容アドバイスメニューの説明"), emotion: .neutral)
                                }
                            }
                        }
                    }
                }
            }
        }
        // MARK: - 発話と感情ログ保存
        private extension FloatingCompanionOverlayView {
            func speak(_ text: String, emotion: EmotionType) {
                currentEmotion = emotion
                currentSpeechText = text
                showSpeechBubble = true

                let utterance = AVSpeechUtterance(string: text)
                utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
                utterance.rate = 0.5
                synthesizer.speak(utterance)

                EmotionLogRepository.shared.saveLog(
                    text: text,
                    emotion: emotion,
                    ritual: "FloatingCompanionOverlayView",
                    metadata: [
                        "regionMannersLoaded": regionManners != nil,
                        "sheetStates": [
                            "showRitualPanel": showRitualPanel,
                            "showInterpreterSubmenu": showInterpreterSubmenu,
                            "showMannersDialog": showMannersDialog,
                            "showInterpreterDialog": showInterpreterDialog,
                            "showCompanionCreation": showCompanionCreation,
                            "showVoiceSetting": showVoiceSetting,
                            "showLegacyInsert": showLegacyInsert,
                            "showProfileEdit": showProfileEdit,
                            "showRecordingConversion": showRecordingConversion,
                            "showRegionInfo": showRegionInfo,
                            "showScheduleView": showScheduleView,
                            "showHealthAdvice": showHealthAdvice,
                            "showMedicationAdvice": showMedicationAdvice,
                            "showNutritionAdvice": showNutritionAdvice,
                            "showExerciseAdvice": showExerciseAdvice,
                            "showLifestyleAdvice": showLifestyleAdvice,
                            "showBeautyAdvice": showBeautyAdvice,
                            "showNutritionView": showNutritionView,
                            "showExerciseView": showExerciseView,
                            "showMedicationDialog": showMedicationDialog,
                            "showSpecializedKnowledge": showSpecializedKnowledge,
                            "showLabDataDialog": showLabDataDialog
                        ]
                    ]
                )

                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    showSpeechBubble = false
                }
            }
        }
