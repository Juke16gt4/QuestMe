//
//  VoiceProfileSelectionView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/VoiceProfileSelectionView.swift
//
//  🎯 目的:
//      コンパニオンの声のタイプ・声色・速度（VoiceProfile）を選択し、最終合成画面へ遷移。
//      - 12言語対応のボタン群（決定・次へ・戻る・メイン画面・ヘルプ・保存）。
//      - 選択状態を保持し、合成で自己紹介に利用。
//      - Pickerで VoiceStyle / VoiceTone / VoiceSpeed を選ぶ。
//
//  🔗 依存:
//      - SwiftUI
//      - VoiceProfile.swift（声属性）
//      - EmotionType.swift（発話）
//
//  🔗 関連/連動ファイル:
//      - CompanionFinalView.swift（合成・保存）
//      - CompanionGeneratorView.swift（戻る）
//      - CompanionProfileRepository.swift（保存）
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-21

import SwiftUI

struct VoiceProfileSelectionView: View {
    @Environment(\.dismiss) private var dismiss

    let selectedCompanionIDs: [UUID]
    let generatedCompanions: [GeneratedCompanion]
    let givenName: String
    let conditionsText: String

    @State private var selectedStyle: VoiceStyle = .gentle
    @State private var selectedTone: VoiceTone = .neutral
    @State private var selectedSpeed: VoiceSpeed = .normal

    @State private var navigateFinal = false

    var body: some View {
        NavigationStack {
            Form {
                Section(NSLocalizedString("VoiceStyleSection", comment: "声のタイプ")) {
                    Picker(NSLocalizedString("VoiceStylePicker", comment: "スタイル"), selection: $selectedStyle) {
                        ForEach(VoiceStyle.allCases, id: \.self) { s in
                            Text(label(for: s)).tag(s)
                        }
                    }
                }
                Section(NSLocalizedString("VoiceToneSection", comment: "声色")) {
                    Picker(NSLocalizedString("VoiceTonePicker", comment: "トーン"), selection: $selectedTone) {
                        ForEach(VoiceTone.allCases, id: \.self) { t in
                            Text(label(for: t)).tag(t)
                        }
                    }
                }
                Section(NSLocalizedString("VoiceSpeedSection", comment: "話速")) {
                    Picker(NSLocalizedString("VoiceSpeedPicker", comment: "速度"), selection: $selectedSpeed) {
                        ForEach(VoiceSpeed.allCases, id: \.self) { v in
                            Text(label(for: v)).tag(v)
                        }
                    }
                }

                Section {
                    HStack {
                        Button(NSLocalizedString("Help", comment: "ヘルプ")) {
                            CompanionOverlay.shared.speak(NSLocalizedString("VoiceSelectHelp", comment: "声のスタイル、声色、速度を選んでください。決定で保存、次へで合成画面へ。"), emotion: .neutral)
                        }
                        Spacer()
                        Button(NSLocalizedString("Save", comment: "保存")) {
                            CompanionOverlay.shared.speak(NSLocalizedString("VoicePrefSaved", comment: "声の設定を保存しました。"), emotion: .gentle)
                            // 必要なら暫定設定を端末に保存
                        }
                        Button(NSLocalizedString("Confirm", comment: "決定")) {
                            CompanionOverlay.shared.speak(NSLocalizedString("VoiceConfirmed", comment: "声の設定を確定しました。"), emotion: .happy)
                        }
                        Button(NSLocalizedString("Next", comment: "次へ")) {
                            navigateFinal = true
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("SelectVoiceTitle", comment: "声のタイプ選択"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("MainScreen", comment: "メイン画面へ")) { dismiss() }
                    Button(NSLocalizedString("Back", comment: "もどる")) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Help", comment: "ヘルプ")) {
                        CompanionOverlay.shared.speak(NSLocalizedString("VoiceSelectScreenHelp", comment: "この画面では声の属性を選択できます。"), emotion: .neutral)
                    }
                }
            }

            NavigationLink("", isActive: $navigateFinal) {
                CompanionFinalView(
                    selectedCompanionIDs: selectedCompanionIDs,
                    generatedCompanions: generatedCompanions,
                    givenName: givenName,
                    conditionsText: conditionsText,
                    voiceProfile: VoiceProfile(style: selectedStyle, tone: selectedTone, speed: selectedSpeed)
                )
            }
            .hidden()
        }
    }

    private func label(for style: VoiceStyle) -> String {
        switch style {
        case .calm:      return NSLocalizedString("VoiceStyleCalm", comment: "落ち着いた")
        case .energetic: return NSLocalizedString("VoiceStyleEnergetic", comment: "元気")
        case .gentle:    return NSLocalizedString("VoiceStyleGentle", comment: "優しい")
        case .lively:    return NSLocalizedString("VoiceStyleLively", comment: "軽快")
        case .sexy:      return NSLocalizedString("VoiceStyleSexy", comment: "セクシー")
        }
    }

    private func label(for tone: VoiceTone) -> String {
        switch tone {
        case .neutral: return NSLocalizedString("VoiceToneNeutral", comment: "ノーマル")
        case .husky:   return NSLocalizedString("VoiceToneHusky", comment: "ハスキー")
        case .bright:  return NSLocalizedString("VoiceToneBright", comment: "高め")
        case .deep:    return NSLocalizedString("VoiceToneDeep", comment: "低め")
        }
    }

    private func label(for speed: VoiceSpeed) -> String {
        switch speed {
        case .slow:   return NSLocalizedString("VoiceSpeedSlow", comment: "ゆっくり")
        case .normal: return NSLocalizedString("VoiceSpeedNormal", comment: "普通")
        case .fast:   return NSLocalizedString("VoiceSpeedFast", comment: "速い")
        }
    }
}
