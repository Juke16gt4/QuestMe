//
//  ProfileView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Profile/ProfileView.swift
//
//  🎯 ファイルの目的:
//      ユーザープロファイルを表示・編集するビュー。
//      - 郵便番号入力完了時に PostalCodeResolver を呼び出し、地域を自動補完。
//      - CompanionOverlay による音声確認と応答。
//      - UserProfileManager により保存、ChangeLogManager により履歴記録。
//
//  🔗 依存:
//      - UserProfileManager.swift（保存）
//      - PostalCodeResolver.swift（地域補完）
//      - ChangeLogManager.swift（履歴）
//      - CompanionOverlay.swift（音声）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import SwiftUI

struct ProfileView: View {
    @ObservedObject var profileManager = UserProfileManager.shared
    
    // テスト用：アプリ起動時に履歴を1件追加する
    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ChangeLogManager().insert(
                userId: 1,
                entityType: "UserProfile",
                entityId: "user-001",
                field: "region",
                action: "autofill",
                oldValue: "",
                newValue: "島根県益田市",
                reason: "postalCodeResolver"
            )
            print("✅ ChangeLog に履歴を追加しました")
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("基本情報")) {
                TextField("郵便番号", text: $profileManager.profile.postalCode)
                    .keyboardType(.numberPad)
                    .onChange(of: profileManager.profile.postalCode) { newValue in
                        // 入力が7桁揃ったら自動補完開始（日本の場合）
                        if newValue.count == 7 {
                            PostalCodeResolver.shared.resolve(
                                postalCode: newValue,
                                country: profileManager.profile.country
                            ) { region in
                                DispatchQueue.main.async {
                                    if let region = region {
                                        profileManager.profile.region = region
                                        CompanionOverlay.shared.speak("\(region)ですね。自動入力しました。")
                                        UserProfileManager.shared.updateProfile(profileManager.profile)
                                    } else {
                                        CompanionOverlay.shared.speak("住所を特定できませんでした。")
                                    }
                                }
                            }
                        }
                    }
                
                TextField("地域", text: $profileManager.profile.region)
            }
        }
        .navigationTitle("プロフィール")
        .onAppear {
            CompanionOverlay.shared.attach(to: self)
        }
    }
}
