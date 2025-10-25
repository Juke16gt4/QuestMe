//
//  ProfileEditView.swift
//  QuestMe
//
//  Created by 津村淳一 on 2025/10/06.
//
//  目的:
//  - UserProfile モデルに基づき、ユーザープロファイルを編集するフォームを提供する。
//  - 「名前」「生年月日」「id」「lastUpdated」「BMI関連」は変更不可（表示のみ）。
//  - 住所・身長・体重・健康状態・職業・サプリメント・喫煙習慣などは手動で変更可能。
//  - 保存時に lastUpdated を自動更新し、UserProfileStorage を通じて SQLite に append-only で記録する。
//  - Companion が参照する基盤データをユーザー自身が管理できるようにする。
//
//  格納先:
//  - Swiftファイル: Views/Profile/ProfileEditView.swift
//

import SwiftUI

struct ProfileEditView: View {
    @State var profile: UserProfile

    var body: some View {
        Form {
            // MARK: - 変更不可
            Section(header: Text("変更不可")) {
                if let id = profile.id {
                    HStack {
                        Text("ID")
                        Spacer()
                        Text("\(id)")
                            .foregroundColor(.secondary)
                    }
                }
                HStack {
                    Text("名前")
                    Spacer()
                    Text(profile.name)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("生年月日")
                    Spacer()
                    Text(profile.birthdate, style: .date)
                        .foregroundColor(.secondary)
                }
                if let updated = profile.lastUpdated {
                    HStack {
                        Text("最終更新")
                        Spacer()
                        Text(updated, style: .date)
                            .foregroundColor(.secondary)
                    }
                }
                HStack {
                    Text("BMI")
                    Spacer()
                    Text(String(format: "%.1f", profile.bmi))
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("BMIカテゴリ")
                    Spacer()
                    Text(profile.bmiCategory)
                        .foregroundColor(.secondary)
                }
            }

            // MARK: - 基本情報
            Section(header: Text("基本情報")) {
                TextField("プロフィールタイトル", text: $profile.title)
                TextField("郵便番号", text: $profile.postalCode)
                TextField("地域", text: $profile.region)
                Stepper(value: $profile.heightCm, in: 0...250, step: 0.5) {
                    Text("身長: \(profile.heightCm, specifier: "%.1f") cm")
                }
                Stepper(value: $profile.weightKg, in: 0...200, step: 0.5) {
                    Text("体重: \(profile.weightKg, specifier: "%.1f") kg")
                }
            }

            // MARK: - 健康状態
            Section(header: Text("健康状態")) {
                Toggle("健康ですか？", isOn: $profile.isHealthy)
                if !profile.isHealthy {
                    TextField("疾患（カンマ区切り）", text: Binding(
                        get: { profile.diseases.joined(separator: ", ") },
                        set: { profile.diseases = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
                    ))
                }
            }

            // MARK: - 職業
            Section(header: Text("職業")) {
                TextField("職業", text: $profile.occupation)
            }

            // MARK: - サプリメント
            Section(header: Text("サプリメント")) {
                ForEach(profile.supplements) { supp in
                    VStack(alignment: .leading) {
                        Text(supp.name).bold()
                        if let dosage = supp.dosage {
                            Text("用量: \(dosage)")
                        }
                        if let purpose = supp.purpose {
                            Text("目的: \(purpose)")
                        }
                    }
                }
                Button("サプリメントを追加") {
                    profile.supplements.append(Supplement(name: "新規サプリ", dosage: nil, purpose: nil, startedAt: Date()))
                }
            }

            // MARK: - 喫煙習慣
            Section(header: Text("喫煙習慣")) {
                Picker("喫煙種類", selection: $profile.tobaccoType) {
                    Text("非喫煙者").tag(TobaccoType.none)
                    Text("紙巻きたばこ").tag(TobaccoType.cigarette)
                    Text("電子タバコ").tag(TobaccoType.vape)
                    Text("その他").tag(TobaccoType.other)
                }
                if profile.tobaccoType != .none {
                    Stepper(value: $profile.cigarettesPerDay, in: 0...60) {
                        Text("1日の本数: \(profile.cigarettesPerDay)")
                    }
                }
            }

            // MARK: - 保存
            Section {
                Button("保存") {
                    var updated = profile
                    updated.lastUpdated = Date()
                    UserProfileStorage.shared.save(updated)
                    print("✅ プロファイル保存: \(updated)")
                }
            }
        }
        .navigationTitle("ユーザープロファイル修正")
    }
}
