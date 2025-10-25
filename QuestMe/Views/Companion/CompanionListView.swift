//
//  CompanionListView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionListView.swift
//
//  🎯 目的:
//      保存済みコンパニオンの一覧表示。タップでダイアログ（交代/削除）を提示し実行。
//      - 12言語対応
//      - 戻る・メイン画面ボタン
//
//  🔗 依存:
//      - SwiftUI
//      - CompanionProfileRepository.swift
//
//  🔗 関連/連動ファイル:
//      - CompanionFinalView.swift（一覧遷移）
//      - FloatingCompanionOverlayView.swift（交代反映）
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-21

import SwiftUI

struct CompanionListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var profiles: [CompanionProfile] = []
    @State private var selectedProfile: CompanionProfile?
    @State private var showActionDialog = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(profiles) { p in
                    HStack(spacing: 12) {
                        Image(uiImage: UIImage(data: p.imageData) ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))

                        VStack(alignment: .leading) {
                            Text(p.name).font(.headline)
                            Text(p.style.rawValue).font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedProfile = p
                        showActionDialog = true
                    }
                }
                .onDelete { idx in
                    let items = idx.map { profiles[$0] }
                    items.forEach { CompanionProfileRepository.shared.delete(id: $0.id) }
                    refresh()
                }
            }
            .navigationTitle(NSLocalizedString("CompanionListTitle", comment: "コンパニオン一覧"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("MainScreen", comment: "メイン画面へ")) { dismiss() }
                    Button(NSLocalizedString("Back", comment: "もどる")) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Help", comment: "ヘルプ")) {
                        CompanionOverlay.shared.speak(NSLocalizedString("ListScreenHelp", comment: "一覧から交代・削除ができます。"), emotion: .neutral)
                    }
                }
            }
            .onAppear { refresh() }
            .confirmationDialog(NSLocalizedString("ChooseAction", comment: "操作を選択"), isPresented: $showActionDialog, titleVisibility: .visible) {
                Button(NSLocalizedString("SwitchCompanion", comment: "交代")) {
                    if let sp = selectedProfile {
                        CompanionProfileRepository.shared.setActive(id: sp.id)
                        CompanionOverlay.shared.speak(String(format: NSLocalizedString("SwitchedToFormat", comment: "%@ に交代しました。"), sp.name), emotion: .happy)
                    }
                }
                Button(NSLocalizedString("Delete", comment: "削除"), role: .destructive) {
                    if let sp = selectedProfile {
                        CompanionProfileRepository.shared.delete(id: sp.id)
                        refresh()
                    }
                }
                Button(NSLocalizedString("Cancel", comment: "キャンセル"), role: .cancel) {}
            }
        }
    }

    private func refresh() {
        profiles = CompanionProfileRepository.shared.loadAll()
    }
}
