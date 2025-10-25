//
//  BeautyCaptureView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Beauty/BeautyCaptureView.swift
//
//  🎯 目的:
//      顔撮影→本人認証→解析→保存（初回永久/履歴+3ヶ月削除）→比較へ導線。
//      ・カメラは高感度（暗所OK）を想定。8MB程度の高精細JPEGで保存。
//      ・Companionがポジティブ提案で案内。
//      ・共通ナビ（メイン画面へ/もどる/ヘルプ）と追加提案（保存/履歴）ボタンを統合。
//
//  🔗 依存:
//      - SwiftUI
//      - BeautyAdviceEngine.swift
//      - BeautyStorageManager.swift
//      - FaceAuthManager.swift
//      - NotificationScheduler.swift
//      - CompanionOverlay（発話）/ CompanionSpeechBubbleView（吹き出し）
//
//  🔗 関連/連動ファイル:
//      - BeautyCompareView.swift
//      - BeautyHistoryView.swift
//      - SleepTimerView.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-21

import SwiftUI

struct BeautyCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var capturedImage: UIImage?
    @State private var analysisResult: BeautyAnalysisResult?
    @State private var showCompare = false
    @State private var showHistory = false
    @State private var lifestyle = LifestyleLinkInput(sleepHours: nil, balancedMealsRatio: nil, exerciseDaysPerWeek: nil)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CompanionSpeechBubbleView(text: NSLocalizedString("BeautyCheckIntro", comment: "美容チェックを開始できます。撮影後に解析して提案します。"), emotion: .gentle)

                if let image = capturedImage {
                    Image(uiImage: image).resizable().scaledToFit().frame(height: 280)
                } else {
                    Text(NSLocalizedString("PleaseTakeFacePhoto", comment: "📷 顔写真を撮影してください"))
                }

                HStack {
                    Button(NSLocalizedString("Capture", comment: "撮影")) { startCapture() }
                    Button(NSLocalizedString("SaveAndAnalyze", comment: "保存と解析")) {
                        saveAndAnalyze()
                    }
                    .disabled(capturedImage == nil)
                }

                if let res = analysisResult {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("AnalysisPositiveTitle", comment: "解析結果（ポジティブ提案）")).font(.headline)
                        Text(res.summary)
                        Text(String(format: NSLocalizedString("MetricsFormat", comment: "指標: 明度 %d・乾燥 %d・赤み %d"),
                                    Int(res.brightnessScore), Int(res.drynessScore), Int(res.rednessScore)))
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                HStack {
                    Button(NSLocalizedString("CompareFirstLatest", comment: "初回と最新を比較する")) { showCompare = true }
                    Button(NSLocalizedString("History", comment: "履歴")) { showHistory = true }
                        .sheet(isPresented: $showHistory) {
                            NavigationStack {
                                BeautyHistoryView()
                                    .toolbar {
                                        ToolbarItemGroup(placement: .navigationBarLeading) {
                                            Button(NSLocalizedString("MainScreen", comment: "メイン画面へ")) { dismiss() }
                                            Button(NSLocalizedString("Back", comment: "もどる")) { dismiss() }
                                        }
                                        ToolbarItem(placement: .navigationBarTrailing) {
                                            Button(NSLocalizedString("Help", comment: "ヘルプ")) {
                                                CompanionOverlay.shared.speak(NSLocalizedString("HistoryHelp", comment: "履歴画面の説明"), emotion: .neutral)
                                            }
                                        }
                                    }
                            }
                        }
                }

                // 下部の明示的保存ボタン（安心感のため）
                Button(NSLocalizedString("Save", comment: "保存")) {
                    if let img = capturedImage {
                        // 解析済みを優先、未解析なら簡易解析して保存
                        let res = analysisResult ?? BeautyAdviceEngine.shared.analyze(image: img, lifestyle: lifestyle)
                        if BeautyStorageManager.shared.hasFirstImage() {
                            BeautyStorageManager.shared.saveHistory(image: img, analysis: res)
                            CompanionOverlay.shared.speak(NSLocalizedString("SavedHistory", comment: "履歴として保存しました。"), emotion: .gentle)
                        } else {
                            BeautyStorageManager.shared.saveFirst(image: img, analysis: res)
                            CompanionOverlay.shared.speak(NSLocalizedString("SavedFirst", comment: "基準画像を保存しました。"), emotion: .happy)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .onAppear {
            NotificationScheduler.shared.scheduleBeautyCheckReminders()
        }
        .navigationTitle(NSLocalizedString("BeautyCheck", comment: "美容チェック"))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(NSLocalizedString("MainScreen", comment: "メイン画面へ")) { dismiss() }
                Button(NSLocalizedString("Back", comment: "もどる")) { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(NSLocalizedString("Help", comment: "ヘルプ")) {
                    CompanionOverlay.shared.speak(NSLocalizedString("BeautyCaptureHelp", comment: "美容撮影画面の説明"), emotion: .neutral)
                }
            }
        }
        .sheet(isPresented: $showCompare) {
            let first = BeautyStorageManager.shared.loadFirst()
            let latest = BeautyStorageManager.shared.loadLatest()
            NavigationStack {
                if let fi = first.image, let li = latest.image {
                    BeautyCompareView(firstImage: fi, latestImage: li, firstLog: first.log, latestLog: latest.log)
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarLeading) {
                                Button(NSLocalizedString("MainScreen", comment: "メイン画面へ")) { dismiss() }
                                Button(NSLocalizedString("Back", comment: "もどる")) { dismiss() }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(NSLocalizedString("Help", comment: "ヘルプ")) {
                                    CompanionOverlay.shared.speak(NSLocalizedString("CompareHelp", comment: "比較画面の説明"), emotion: .neutral)
                                }
                            }
                        }
                } else {
                    VStack {
                        Text(NSLocalizedString("NoCompareTargets", comment: "比較対象がありません"))
                        Text(NSLocalizedString("SaveFirstAndHistoryHint", comment: "基準画像と履歴を保存すると比較できます"))
                    }
                    .padding()
                }
            }
        }
    }

    private func startCapture() {
        // 実実装: AVCaptureSession で前面・高感度設定、8MB近似のJPEG品質で撮影
        capturedImage = UIImage(systemName: "person.crop.circle")! // ダミー
    }

    private func saveAndAnalyze() {
        guard let img = capturedImage else { return }
        let reference = BeautyStorageManager.shared.loadFirst().image
        if FaceAuthManager.shared.isSamePerson(current: img, reference: reference) {
            let res = BeautyAdviceEngine.shared.analyze(image: img, lifestyle: lifestyle)
            analysisResult = res
            if BeautyStorageManager.shared.hasFirstImage() {
                BeautyStorageManager.shared.saveHistory(image: img, analysis: res)
                CompanionOverlay.shared.speak(res.summary, emotion: .gentle)
            } else {
                BeautyStorageManager.shared.saveFirst(image: img, analysis: res)
                CompanionOverlay.shared.speak(NSLocalizedString("SavedFirstAndCompareNext", comment: "基準画像を保存しました。次回から比較できます。"), emotion: .happy)
            }
        } else {
            CompanionOverlay.shared.speak(NSLocalizedString("FaceAuthFailed", comment: "本人確認ができませんでした。他の方のお顔は撮影できません。"), emotion: .neutral)
        }
    }
}
