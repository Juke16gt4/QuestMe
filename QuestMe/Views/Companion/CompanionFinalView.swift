//
//  CompanionFinalView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionFinalView.swift
//
//  🎯 目的:
//      生成済みコンパニオン（1〜3体）＋選択した声プロファイルを合成して表示。
//      - 保存ボタンで端末内へ保存（高解像度維持）。
//      - 一覧ボタンで保存済みコンパニオンを表示・管理（交代/削除）。
//      - 12言語対応のボタン群（決定・次へ・戻る・メイン画面・ヘルプ・保存・一覧）。
//
//  🔗 依存:
//      - SwiftUI
//      - VoiceProfile.swift
//      - CompanionProfileRepository.swift（保存）
//      - EmotionType.swift（案内）
//
//  🔗 関連/連動ファイル:
//      - CompanionListView.swift（一覧管理）
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-21

import SwiftUI

struct CompanionFinalView: View {
    @Environment(\.dismiss) private var dismiss

    let selectedCompanionIDs: [UUID]
    let generatedCompanions: [GeneratedCompanion]
    let givenName: String
    let conditionsText: String
    let voiceProfile: VoiceProfile

    @State private var showList = false
    @State private var savedCount = 0

    private var chosen: [GeneratedCompanion] {
        generatedCompanions.filter { selectedCompanionIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(NSLocalizedString("CompanionFinalTitle", comment: "合成プレビュー"))
                    .font(.title2).bold()

                if chosen.isEmpty {
                    Text(NSLocalizedString("NoChosenCompanions", comment: "選択されたコンパニオンがありません"))
                } else {
                    ForEach(chosen) { comp in
                        VStack(spacing: 8) {
                            // 高解像度表示（写真品質維持）
                            Image(uiImage: comp.image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(comp.style.toEmotion().color, lineWidth: 2))

                            Text(String(format: NSLocalizedString("CompIntroFormat", comment: "%@ です。これからよろしくお願いします。"), givenName))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }

                Text(voiceLabel(voiceProfile))
                    .font(.footnote)
                    .foregroundColor(.blue)

                HStack {
                    Button(NSLocalizedString("Help", comment: "ヘルプ")) {
                        CompanionOverlay.shared.speak(NSLocalizedString("FinalScreenHelp", comment: "合成されたコンパニオンの確認・保存・一覧管理ができます。"), emotion: .neutral)
                    }
                    Spacer()
                    Button(NSLocalizedString("Save", comment: "保存")) {
                        savedCount = saveCompanions()
                        CompanionOverlay.shared.speak(String(format: NSLocalizedString("SavedCountFormat", comment: "%d 体保存しました。"), savedCount), emotion: .happy)
                    }
                    Button(NSLocalizedString("List", comment: "一覧")) {
                        showList = true
                    }
                }
                .padding(.horizontal)

                NavigationLink("", isActive: $showList) {
                    CompanionListView()
                }
                .hidden()
            }
            .padding(.vertical)
            .navigationTitle(NSLocalizedString("CompanionFinalTitle", comment: "合成プレビュー"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("MainScreen", comment: "メイン画面へ")) { dismiss() }
                    Button(NSLocalizedString("Back", comment: "もどる")) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Help", comment: "ヘルプ")) {
                        CompanionOverlay.shared.speak(NSLocalizedString("FinalScreenHelp", comment: "合成されたコンパニオンの確認・保存・一覧管理ができます。"), emotion: .neutral)
                    }
                }
            }
        }
    }

    private func saveCompanions() -> Int {
        let chosen = chosen // local snapshot
        var count = 0
        for comp in chosen {
            let profile = CompanionProfile(
                id: comp.id,
                name: givenName,
                personality: comp.personality,
                style: comp.style,
                imageData: comp.image.pngData() ?? Data(),
                voice: voiceProfile,
                conditions: conditionsText
            )
            CompanionProfileRepository.shared.save(profile: profile)
            count += 1
        }
        return count
    }

    private func voiceLabel(_ v: VoiceProfile) -> String {
        String(format: NSLocalizedString("VoiceSummaryFormat", comment: "声: %@ / %@ / %@"),
               label(for: v.style), label(for: v.tone), label(for: v.speed))
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
