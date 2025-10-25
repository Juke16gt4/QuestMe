//
//  ExerciseRecordView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Exercise/ExerciseRecordView.swift
//
//  🎯 ファイルの目的:
//      運動記録を入力・保存するビュー。
//      - CompanionOverlay.awaitConfirmation により「はい」で保存、「いいえ」でキャンセル。
//      - 保存は ExerciseStorageManager により SQL に追加保存。
//      - Companion が音声で確認・応援する。
//
//  🔗 依存:
//      - CompanionOverlay.swift（音声）
//      - ExerciseStorageManager.swift（保存）
//      - ExerciseActivity.swift（活動定義）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import SwiftUI

struct ExerciseRecordView: View {
    @State private var selectedActivity: ExerciseActivity = ExerciseActivity(name: "速歩", mets: 4.3, minutesPerEx: 30)
    @State private var duration: Int = 30
    @State private var weightKg: Double = 65
    @State private var showSavedAlert = false
    @State private var showCancelledAlert = false

    // 仮の候補（本来はデータソースから取得）
    private let activities: [ExerciseActivity] = [
        ExerciseActivity(name: "速歩", mets: 4.3, minutesPerEx: 30),
        ExerciseActivity(name: "ジョギング", mets: 7.0, minutesPerEx: 30),
        ExerciseActivity(name: "水泳（中強度）", mets: 6.0, minutesPerEx: 30),
        ExerciseActivity(name: "サイクリング（中強度）", mets: 6.8, minutesPerEx: 30)
    ]

    var body: some View {
        Form {
            Section(header: Text("運動内容")) {
                Picker("活動", selection: $selectedActivity) {
                    ForEach(activities, id: \.id) { activity in
                        Text("\(activity.name) (\(String(format: "%.1f", activity.mets)) METs)").tag(activity)
                    }
                }
                Stepper("時間: \(duration) 分", value: $duration, in: 5...180, step: 5)
                HStack {
                    Text("体重")
                    Spacer()
                    TextField("kg", value: $weightKg, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
            }

            Button("保存する") {
                CompanionOverlay.shared.awaitConfirmation { confirmed in
                    if confirmed {
                        saveExercise()
                        showSavedAlert = true
                    } else {
                        CompanionOverlay.shared.speak("保存をキャンセルしました。")
                        showCancelledAlert = true
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("運動記録")
        .alert("運動を保存しました", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("保存をキャンセルしました", isPresented: $showCancelledAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    private func saveExercise() {
        ExerciseStorageManager.shared.saveRecord(
            userId: 1,
            activity: selectedActivity,
            durationMinutes: duration,
            weightKg: weightKg
        )
        CompanionOverlay.shared.speak("運動を保存しました。お疲れさまでした！")
    }
}
