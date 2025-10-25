//
//  PrescriptionFaxFlowView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Pharmacy/PrescriptionFaxFlowView.swift
//
//  🎯 ファイルの目的:
//      処方箋Fax送付の儀式UI。
//      - 音声でメールアドレス登録 → 薬局登録・削除 → Fax送信。
//      - 最大3件まで薬局登録可能。
//      - Companionが復唱・確認・送信応答を行う。
//      - AirPrint送信処理と連携。
//
//  🔗 依存:
//      - Models/PharmacyFaxEntry.swift
//      - Managers/PharmacyFaxManager.swift
//      - Views/Pharmacy/PharmacyRegistrationSheet.swift
//      - Services/Pharmacy/PrescriptionFaxSender.swift
//      - CompanionOverlay.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import SwiftUI

struct PrescriptionFaxFlowView: View {
    @State private var emailInput: String = ""
    @State private var confirmedEmail: String?
    @State private var showPharmacyDialog = false
    @State private var pharmacies: [PharmacyFaxEntry] = PharmacyFaxManager.shared.all()
    @State private var showRegistrationSheet = false
    @State private var registrationIndex: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("📠 処方箋Fax送付の儀式")
                    .font(.title3)
                    .bold()

                // 音声メール登録フェーズ
                if confirmedEmail == nil {
                    Text("メールアドレスを音声で登録してください")
                    TextField("例: taro@example.com", text: $emailInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("復唱して確認") {
                        confirmedEmail = emailInput
                        CompanionOverlay.shared.speak("\(emailInput) ですね。こちらでよろしいですか？")
                    }
                } else {
                    Text("📧 登録メール: \(confirmedEmail!)")
                    Button("OK") {
                        showPharmacyDialog = true
                    }
                }

                // 薬局登録・削除・送信フェーズ
                if showPharmacyDialog {
                    Text("🏥 かかりつけ薬局（最大3件）")
                        .font(.headline)

                    ForEach(0..<3) { index in
                        if index < pharmacies.count {
                            let pharmacy = pharmacies[index]
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(pharmacy.name)
                                    Text("Fax: \(pharmacy.faxNumber)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button("送信") {
                                    if let root = UIApplication.shared.windows.first?.rootViewController {
                                        PrescriptionFaxSender.sendFax(to: pharmacy, from: root)
                                    }
                                }
                                .buttonStyle(.borderedProminent)

                                Button("削除") {
                                    PharmacyFaxManager.shared.delete(pharmacy: pharmacy.name)
                                    pharmacies = PharmacyFaxManager.shared.all()
                                }
                                .foregroundColor(.red)
                            }
                        } else {
                            Button("未登録\(index + 1)") {
                                registrationIndex = index
                                showRegistrationSheet = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("処方箋Fax送付")
            .sheet(isPresented: $showRegistrationSheet) {
                PharmacyRegistrationSheet(index: registrationIndex) {
                    pharmacies = PharmacyFaxManager.shared.all()
                }
            }
        }
    }
}
