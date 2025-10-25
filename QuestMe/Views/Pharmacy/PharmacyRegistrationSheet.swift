//
//  PharmacyRegistrationSheet.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Pharmacy/PharmacyRegistrationSheet.swift
//
//  🎯 ファイルの目的:
//      未登録薬局ボタン押下時に表示される登録画面。
//      - 薬局名とFax番号を入力し、PharmacyFaxManagerに保存。
//      - Companionが音声で登録完了を復唱する。
//      - 最大3件まで登録可能。
//
//  🔗 依存:
//      - Managers/PharmacyFaxManager.swift
//      - Models/PharmacyFaxEntry.swift
//      - CompanionOverlay.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import SwiftUI

struct PharmacyRegistrationSheet: View {
    let index: Int
    var onComplete: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var fax: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("🏥 薬局登録（枠 \(index + 1)）")
                .font(.headline)

            TextField("薬局名", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Fax番号", text: $fax)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            HStack {
                Button("登録") {
                    PharmacyFaxManager.shared.save(pharmacy: name, fax: fax)
                    CompanionOverlay.shared.speak("薬局「\(name)」を登録しました。Fax番号は「\(fax)」です。")
                    onComplete()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Button("キャンセル") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding()
    }
}
