//
//  BeautyCompareView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Beauty/BeautyCompareView.swift
//
//  🎯 目的:
//      初回（基準画像）と最新の並列比較。良くなった点を強調し、Companionがポジティブに案内。
//      ・解析ログから「改善点/提案」を提示。
//      ・比較はモチベーションを高めるための儀式。
//      ・共通ナビ（メイン画面へ/もどる/ヘルプ）を統合。
//
//  🔗 依存:
//      - SwiftUI
//      - BeautyStorageManager.swift（ログ型）
//      - CompanionOverlay（発話）
//
//  🔗 関連/連動ファイル:
//      - BeautyCaptureView.swift
//      - BeautyHistoryView.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-21

import SwiftUI

struct BeautyCompareView: View {
    @Environment(\.dismiss) private var dismiss
    let firstImage: UIImage
    let latestImage: UIImage
    let firstLog: BeautyLog?
    let latestLog: BeautyLog?

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack {
                    Text(NSLocalizedString("First", comment: "初回")).font(.headline)
                    Image(uiImage: firstImage).resizable().scaledToFit()
                }
                VStack {
                    Text(NSLocalizedString("Latest", comment: "最新")).font(.headline)
                    Image(uiImage: latestImage).resizable().scaledToFit()
                }
            }
            .padding()

            if let latest = latestLog {
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("EmphasizeGoodPoints", comment: "良い点を強調")).font(.headline)
                    latest.analysis.improvements.forEach { Text("・\($0)") }
                    Text(NSLocalizedString("Suggestions", comment: "提案")).font(.headline).padding(.top, 8)
                    latest.analysis.suggestions.forEach { Text("・\($0)") }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }

            Spacer()
        }
        .onAppear {
            CompanionOverlay.shared.speak(NSLocalizedString("CompareIntro", comment: "初回と最新の比較です。良い変化に注目しましょう。"), emotion: .happy)
        }
        .padding()
        .navigationTitle(NSLocalizedString("CompareTitle", comment: "比較"))
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
    }
}
