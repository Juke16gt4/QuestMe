//
//  ProfileSettingsView.swift
//  QuestMe
//
//  Created by 津村淳一 on 2025/10/06.
//
//  目的:
//  - ②「プロファイル設定」ボタンを提供し、
//    「プロファイル修正」「SQLデータ呼び出し」の2分岐を実装する。
//  - プロファイル修正では UserProfile モデルに基づいたフォームを表示する。
//  - 起動時に UserProfileStorage.shared.loadLatest() を呼び出し、
//    最新のプロフィールをフォームに反映する。
//  - SQLデータ呼び出しでは append-only SQL の履歴を参照し、行・列単位で削除可能にする。
//
//  格納先:
//  - Swiftファイル: Views/Profile/ProfileSettingsView.swift
//

import SwiftUI

struct ProfileSettingsView: View {
    @State private var showProfileOptions = false
    @State private var showProfileEditor = false
    @State private var showSQLData = false

    // 最新プロフィールを保持
    @State private var userProfile: UserProfile = .empty()

    var body: some View {
        VStack {
            Button("② プロファイル設定") {
                showProfileOptions = true
            }
            .buttonStyle(.borderedProminent)
            .confirmationDialog("プロファイル設定", isPresented: $showProfileOptions, titleVisibility: .visible) {
                Button("プロファイル修正") {
                    showProfileEditor = true
                }
                Button("SQLデータ呼び出し") {
                    showSQLData = true
                }
                Button("キャンセル", role: .cancel) {}
            }
        }
        // 起動時に最新プロフィールをロード
        .onAppear {
            if let latest = UserProfileStorage.shared.loadLatest() {
                userProfile = latest
            } else {
                userProfile = .empty()
            }
        }
        // プロファイル修正画面
        .sheet(isPresented: $showProfileEditor) {
            NavigationStack {
                ProfileEditView(profile: userProfile)
            }
        }
        // SQLデータ呼び出し画面
        .sheet(isPresented: $showSQLData) {
            NavigationStack {
                SQLDataView()
            }
        }
    }
}
