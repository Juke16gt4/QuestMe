//
//  StayMemoSheet.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Region/StayMemoSheet.swift
//
//  🎯 ファイルの目的:
//      到着イベント時に滞在メモ（短い感想）を入力・保存するシートUI。
//      - 場所名の確認→テキスト入力→「保存」「スキップ」。
//      - 保存時はコールバックで UserEventHistory へ impression を反映。
//      - 12言語に合わせてボタンラベルを差し替え可能（LocationInfoView.localized を利用）
//
//  🔗 関連/連動ファイル:
//      - LocationInfoView.swift（到着時にシート表示）
//      - UserEventHistory.swift（impression 保存）
//      - SpeechSync.swift（音声案内）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月20日
//

import SwiftUI

struct StayMemoSheet: View {
    let placeName: String
    @Binding var memoText: String
    var onSave: (String) -> Void
    var onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("📝 滞在メモ")
                    .font(.title3)
                    .bold()
                    .padding(.top, 8)

                Text("場所: \(placeName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextEditor(text: $memoText)
                    .frame(height: 160)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)

                HStack(spacing: 10) {
                    Button("保存") {
                        onSave(memoText)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("スキップ") {
                        onCancel()
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← 閉じる") { dismiss() }
                }
            }
        }
        .onAppear {
            SpeechSync().speak("到着しました。短い感想をメモしますか？")
        }
    }
}
