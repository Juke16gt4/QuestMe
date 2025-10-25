//
//  MedicationDialog.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Medication/MedicationDialog.swift
//
//  🎯 ファイルの目的:
//      ユーザーに「おくすり登録方法」を提示するダイアログビュー。
//      - 音声・QR・GS1・ヒートシール・手入力に対応。
//      - 日本居住者のみ QR・GS1 ボタンを表示。
//      - MedicationManager により Medication.sqlite3 に保存。
//      - CompanionOverlay と連携し、登録時に音声応答可能。
//
//  🔗 依存:
//      - MedicationManager.swift（保存）
//      - GS1ScannerView.swift / HeatSealScannerView.swift（読み取り）
//      - SpeechInputView.swift（音声）
//      - QRCodeScannerView.swift（QR）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import SwiftUI
import AVFoundation

struct MedicationDialog: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showManualInput = false
    @State private var medicineName = ""
    @State private var dosage = ""
    @State private var showingScanner = false
    @State private var scannedText: String?

    private let manager = MedicationManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("おくすり登録方法")
                .font(.headline)

            // 音声登録
            // 音声登録
            Button("🎤 音声登録") {
                showingSpeechInput = true
            }
            .sheet(isPresented: $showingSpeechInput) {
                SpeechInputView { result in
                    switch result {
                    case .success(let text):
                        // 簡易解析: 薬剤名と容量を抽出
                        let parsedName = parseDrugName(from: text)
                        let parsedDosage = parseDrugDosage(from: text)

                        MedicationManager().insertMedication(
                            userId: 1,
                            name: parsedName,
                            dosage: parsedDosage,
                            source: "voice"
                        )
                        dismiss()

                    case .failure(let error):
                        print("音声入力失敗: \(error.localizedDescription)")
                        dismiss()
                    }
                }
            }

            // 処方箋QRコード（日本限定）
            if Locale.current.region?.identifier == "JP" {
                Button("📄 処方箋QRコード読み取り") {
                    showingScanner = true
                }
                .sheet(isPresented: $showingScanner) {
                    QRCodeScannerView { result in
                        switch result {
                        case .success(let code):
                            // QRコード文字列から薬剤名・容量を抽出する処理（例示）
                            let parsedName = parseDrugName(from: code)
                            let parsedDosage = parseDrugDosage(from: code)

                            manager.insertMedication(
                                userId: 1,
                                name: parsedName,
                                dosage: parsedDosage,
                                source: "qr"
                            )
                            dismiss()

                        case .failure(let error):
                            print("QR読み取り失敗: \(error.localizedDescription)")
                            dismiss()
                        }
                    }
                }
            }

            // GS1コード（日本限定＋専用カメラ）
            if Locale.current.region?.identifier == "JP" {
                Button("🔍 GS1コード読み取り") {
                    // TODO: GS1コード専用カメラ処理
                }
            }

            // ヒートシール読み取り
            Button("💊 ヒートシールから読み込み") {
                // TODO: カメラ撮影処理
            }

            // 手入力
            Button("⌨️ 手入力") {
                showManualInput = true
            }
        }
        .padding()
        .sheet(isPresented: $showManualInput) {
            VStack(spacing: 16) {
                TextField("薬剤名", text: $medicineName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("容量・規格 (例: 10mg)", text: $dosage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("保存") {
                    manager.insertMedication(
                        userId: 1,
                        name: medicineName,
                        dosage: dosage,
                        source: "manual"
                    )
                    dismiss()
                }
            }
            .padding()
        }
    }

    // MARK: - QRコード解析用の簡易関数
    private func parseDrugName(from code: String) -> String {
        // 実際にはQRコード仕様に基づいて解析
        return code.contains("アムロジピン") ? "アムロジピン錠" : "不明薬剤"
    }

    private func parseDrugDosage(from code: String) -> String {
        // 実際にはQRコード仕様に基づいて解析
        return code.contains("5mg") ? "5mg" : "規格不明"
    }
}
