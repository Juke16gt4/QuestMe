//
//  NutritionRecordView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Nutrition/NutritionRecordView.swift
//
//  🎯 ファイルの目的:
//      栄養記録の一連フローを提供するビュー。
//      - 撮影前ガイド音声 → 撮影 → メニュー質問 → 推定 → OK保存。
//      - CompanionOverlay.awaitConfirmation により「はい」で保存、「いいえ」でキャンセル。
//      - 保存は NutritionStorageManager により append-only で行われる。
//
//  🔗 依存:
//      - CompanionOverlay.swift（音声ガイド＋確認）
//      - NutritionStorageManager.swift（保存）
//      - MealRecord.swift（モデル）
//      - ImagePicker.swift（撮影）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import SwiftUI
import UIKit

struct NutritionRecordView: View {
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var userInput: String = ""
    @State private var estimatedCalories: Double?
    @State private var showSavedAlert = false
    @State private var showCancelledAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 220)
                        .cornerRadius(12)
                }

                if estimatedCalories == nil {
                    Button {
                        // 撮影前ガイド音声
                        CompanionOverlay.shared.speak("食事を撮影します。撮影枠にいっぱいになるように撮影してくださいね。")
                        showCamera = true
                    } label: {
                        Label("食事を撮影する", systemImage: "camera")
                    }
                    .buttonStyle(.borderedProminent)
                }

                if let cal = estimatedCalories {
                    Text("推定摂取カロリー: \(Int(cal)) kcal")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("今日の食事のメニューは何ですか？")
                            .font(.subheadline)
                        TextField("例: 焼き魚定食、サラダ、味噌汁", text: $userInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)

                    Button {
                        // ✅ 保存確認フロー
                        CompanionOverlay.shared.awaitConfirmation { confirmed in
                            if confirmed {
                                saveMeal(calories: cal)
                                showSavedAlert = true
                            } else {
                                CompanionOverlay.shared.speak("保存をキャンセルしました。")
                                showCancelledAlert = true
                            }
                        }
                    } label: {
                        Label("OK（記録する）", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("栄養記録")
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $capturedImage, onImagePicked: { image in
                self.capturedImage = image
                // 撮影完了後の質問
                CompanionOverlay.shared.speak("今日の食事のメニューは何ですか？")
                // 仮の推定処理（実運用では解析APIと連動）
                self.estimatedCalories = 520.0
            })
        }
        .alert("記録しました", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("保存をキャンセルしました", isPresented: $showCancelledAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    private func saveMeal(calories: Double) {
        let record = MealRecord(
            mealType: "朝食",
            userInput: userInput,
            calories: calories,
            protein: 20,
            fat: 15,
            carbs: 60,
            compressedImage: capturedImage
        )
        NutritionStorageManager.shared.saveMeal(record) // append-only
        CompanionOverlay.shared.speak("記録しました。今日もバランスの良い一日を！")
    }
}
