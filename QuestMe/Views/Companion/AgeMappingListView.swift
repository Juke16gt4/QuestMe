//
//  AgeMappingListView.swift
//  QuestMe
//
//  📂 格納先:
//      QuestMe/Views/Companion/AgeMappingListView.swift
//
//  🎯 目的:
//      - 年齢ごとの声質プリセット（ageMappings）を一覧表示・編集・削除
//      - VoiceFormationView で保存したプリセットを管理し、透明性と儀式性を高める
//
//  🔗 連携・関連先:
//      - Views/Companion/FloatingCompanionExpandedView.swift（遷移元・保存処理）
//      - Models/VoiceProfile.swift（声質データ構造）
//      - Enums: VoiceStyle / VoiceTone / VoiceSpeed（編集対象の列挙体）
//
//  ⚙️ 依存関係:
//      import SwiftUI
//      VoiceProfile, VoiceStyle, VoiceTone, VoiceSpeed がプロジェクト内に定義済みであること
//
//  🧭 責務:
//      - ageMappings を年齢順で一覧表示
//      - 行タップで編集モーダル（EditVoicePresetView）を開き、スタイル/トーン/速度を変更
//      - スワイプ削除でプリセットを削除
//
//  👤 製作者: 津村 淳一
//  📅 製作日時: 2025-10-11 JST
//

import SwiftUI

// MARK: - 年齢別プリセット一覧ビュー
struct AgeMappingListView: View {
    @Binding var ageMappings: [Int: VoiceProfile]

    @State private var editingAge: Int?
    @State private var tempVoice: VoiceProfile = VoiceProfile(style: .calm, tone: .neutral, speed: .normal)

    var body: some View {
        List {
            // 保存済みプリセット
            Section(header: Text("保存済みプリセット")) {
                if ageMappings.isEmpty {
                    Text("まだプリセットが保存されていません")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(ageMappings.keys.sorted(), id: \.self) { age in
                        HStack(spacing: 12) {
                            Text("\(age)歳")
                                .font(.headline)
                            Spacer()
                            LabelValueView(label: "スタイル", value: ageMappings[age]?.style.rawValue ?? "-")
                            LabelValueView(label: "トーン", value: ageMappings[age]?.tone.rawValue ?? "-")
                            LabelValueView(label: "速度", value: ageMappings[age]?.speed.rawValue ?? "-")
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            tempVoice = ageMappings[age] ?? VoiceProfile(style: .calm, tone: .neutral, speed: .normal)
                            editingAge = age
                        }
                    }
                    .onDelete { indices in
                        let sortedAges = ageMappings.keys.sorted()
                        for index in indices {
                            let key = sortedAges[index]
                            ageMappings.removeValue(forKey: key)
                        }
                    }
                }
            }

            // 未設定ガイド
            Section(header: Text("未設定の年齢")) {
                Text("スライダーから年齢を選び「この年齢の設定を保存」で追加できます。")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(item: Binding(
            get: { editingAge.map { IdentifiableInt(value: $0) } },
            set: { editingAge = $0?.value }
        )) { identifiableAge in
            EditVoicePresetView(age: identifiableAge.value, voice: $tempVoice) { newVoice, shouldSave in
                if shouldSave {
                    ageMappings[identifiableAge.value] = newVoice
                }
                editingAge = nil
            }
        }
        .navigationTitle("年齢別プリセット一覧")
    }
}

// MARK: - ラベル＋値の小さなビュー
struct LabelValueView: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
        }
    }
}

// MARK: - シート用の Identifiable ラッパー
struct IdentifiableInt: Identifiable {
    let value: Int
    var id: Int { value }
}

// MARK: - プリセット編集モーダル
struct EditVoicePresetView: View {
    let age: Int
    @Binding var voice: VoiceProfile
    var onClose: (VoiceProfile, Bool) -> Void // (更新後の声, 保存するかどうか)

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("年齢: \(age)歳")) {
                    Picker("スタイル", selection: $voice.style) {
                        ForEach(VoiceStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }

                    Picker("トーン", selection: $voice.tone) {
                        ForEach(VoiceTone.allCases, id: \.self) { tone in
                            Text(tone.rawValue).tag(tone)
                        }
                    }

                    Picker("速度", selection: $voice.speed) {
                        ForEach(VoiceSpeed.allCases, id: \.self) { speed in
                            Text(speed.rawValue).tag(speed)
                        }
                    }
                }

                Section(header: Text("プレビュー（簡易）")) {
                    // ここに簡易プレビュー UI や試聴ボタンを後で拡張可能
                    Text("スタイル: \(voice.style.rawValue)")
                    Text("トーン: \(voice.tone.rawValue)")
                    Text("速度: \(voice.speed.rawValue)")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("プリセット編集")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { onClose(voice, false) }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { onClose(voice, true) }
                }
            }
        }
    }
}
