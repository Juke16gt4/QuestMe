//
//  MedicationDialogLauncherView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Medication/MedicationDialogLauncherView.swift
//
//  🎯 ファイルの目的:
//      「おくすり」ボタン押下時に表示される統合儀式ダイアログ。
//      - 音声・QR・GS1・ヒートシール・手入力・一覧・Fax送付の儀式を統合。
//      - 各儀式は個別のViewに遷移し、MedicationManagerに保存される。
//      - CompanionOverlay による音声案内と連携。
//
//  🔗 依存:
//      - SpeechInputView.swift（音声）
//      - QRCodeScannerView.swift（QR）
//      - GS1ScannerView.swift（バーコード）
//      - HeatSealScannerView.swift（OCR）
//      - MedicationDialog.swift（手入力）
//      - MedicationListView.swift（一覧）
//      - PrescriptionFaxFlowView.swift（Fax）
//      - MedicationManager.swift（保存）
//      - CompanionOverlay.swift（音声）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import SwiftUI

struct MedicationDialogLauncherView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showSpeech = false
    @State private var showQR = false
    @State private var showGS1 = false
    @State private var showHeatSeal = false
    @State private var showManual = false
    @State private var showList = false
    @State private var showFaxFlow = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("💊 おくすり登録・送付")
                    .font(.title3)
                    .bold()

                Button("🎤 音声で登録") { showSpeech = true }
                Button("📄 QRコードから登録") { showQR = true }
                Button("🔍 GS1バーコードから登録") { showGS1 = true }
                Button("💊 ヒートシールから登録") { showHeatSeal = true }
                Button("⌨️ 手入力で登録") { showManual = true }
                Button("📋 登録済み一覧") { showList = true }
                Button("📠 処方箋Fax送付") { showFaxFlow = true }

                Spacer()
            }
            .padding()
            .navigationTitle("おくすり儀式")
            .sheet(isPresented: $showSpeech) {
                SpeechInputView { result in
                    switch result {
                    case .success(let text):
                        let name = parseDrugName(from: text)
                        let dosage = parseDrugDosage(from: text)
                        MedicationManager.shared.insertMedication(userId: 1, name: name, dosage: dosage, source: "voice")
                        CompanionOverlay.shared.speak("「\(name) \(dosage)」を音声で登録しました。")
                        dismiss()
                    case .failure(let error):
                        CompanionOverlay.shared.speak("音声登録に失敗しました。")
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showQR) {
                QRCodeScannerView { result in
                    switch result {
                    case .success(let code):
                        let name = parseDrugName(from: code)
                        let dosage = parseDrugDosage(from: code)
                        MedicationManager.shared.insertMedication(userId: 1, name: name, dosage: dosage, source: "qr")
                        CompanionOverlay.shared.speak("「\(name) \(dosage)」をQRコードから登録しました。")
                        dismiss()
                    case .failure:
                        CompanionOverlay.shared.speak("QRコードの読み取りに失敗しました。")
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showGS1) {
                GS1ScannerView { result in
                    switch result {
                    case .success(let code):
                        let name = parseDrugName(from: code)
                        let dosage = parseDrugDosage(from: code)
                        MedicationManager.shared.insertMedication(userId: 1, name: name, dosage: dosage, source: "gs1")
                        CompanionOverlay.shared.speak("「\(name) \(dosage)」をGS1バーコードから登録しました。")
                        dismiss()
                    case .failure:
                        CompanionOverlay.shared.speak("GS1バーコードの読み取りに失敗しました。")
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showHeatSeal) {
                HeatSealScannerView { result in
                    switch result {
                    case .success(let (name, dosage)):
                        MedicationManager.shared.insertMedication(userId: 1, name: name, dosage: dosage, source: "heatseal")
                        CompanionOverlay.shared.speak("「\(name) \(dosage)」をヒートシールから登録しました。")
                        dismiss()
                    case .failure:
                        CompanionOverlay.shared.speak("ヒートシールの読み取りに失敗しました。")
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showManual) {
                MedicationDialog()
            }
            .sheet(isPresented: $showList) {
                MedicationListView()
            }
            .sheet(isPresented: $showFaxFlow) {
                PrescriptionFaxFlowView()
            }
        }
    }

    // MARK: - 簡易解析関数（QR/GS1/音声共通）
    private func parseDrugName(from text: String) -> String {
        if text.contains("アムロジピン") { return "アムロジピン錠" }
        if text.contains("ロサルタン") { return "ロサルタン錠" }
        return "不明薬剤"
    }

    private func parseDrugDosage(from text: String) -> String {
        if text.contains("5mg") { return "5mg" }
        if text.contains("50mg") { return "50mg" }
        return "規格不明"
    }
}
