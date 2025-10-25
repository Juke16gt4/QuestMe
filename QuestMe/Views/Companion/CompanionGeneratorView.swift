//
//  CompanionGeneratorView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionGeneratorView.swift
//
//  🎯 目的:
//      コンパニオンの条件入力（手動/音声）→3体同時作製→1〜3体選択→名前付け→声選択画面へ遷移。
//      - 12言語対応のボタン群（次へ・決定・戻る・メイン画面・ヘルプ・保存）を標準化。
//      - 画像は必ず正面・写真に近い品質（将来AI生成差し替えを想定）。
//      - 再作製は何度でも可能。
//      - 選択・命名後に VoiceProfileSelectionView へ進む。
//
//  🔗 依存:
//      - SwiftUI, AVFoundation
//      - CompanionGenerator.swift（3体生成）
//      - CompanionStyle.swift（スタイル）
//      - EmotionType.swift（発話感情）
//      - VoiceProfile.swift（次画面で利用）
//
//  🔗 関連/連動ファイル:
//      - VoiceProfileSelectionView.swift（次のステップ）
//      - CompanionFinalView.swift（合成・保存）
//      - CompanionProfileRepository.swift（保存）
//      - CompanionListView.swift（一覧管理）
//      - FloatingCompanionOverlayView.swift（起点）
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-21

import SwiftUI
import AVFoundation

struct CompanionGeneratorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var inputText: String = ""
    @State private var generated: [GeneratedCompanion] = []
    @State private var selected: Set<UUID> = []
    @State private var nameInput: String = ""
    @State private var showHelp = false
    @State private var navigateVoiceSelection = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(NSLocalizedString("CompanionGeneratorTitle", comment: "コンパニオン作製"))
                    .font(.title2).bold()

                // 条件入力（手動）
                TextField(NSLocalizedString("EnterConditions", comment: "条件を入力してください"), text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                HStack {
                    Button(NSLocalizedString("VoiceInput", comment: "🎤 音声入力")) {
                        CompanionOverlay.shared.speak(NSLocalizedString("VoiceInputPrompt", comment: "条件を話してください"), emotion: .neutral)
                        // TODO: 音声認識処理を統合（Speech framework）
                    }
                    Button(NSLocalizedString("Save", comment: "保存")) {
                        // 条件テンプレ保存（必要ならユーザー端末に保存）
                        CompanionOverlay.shared.speak(NSLocalizedString("CondSaved", comment: "条件を保存しました。"), emotion: .gentle)
                    }
                }
                .buttonStyle(.bordered)

                // 作製ボタン（3体同時）
                Button(NSLocalizedString("GenerateThree", comment: "作製（3体同時）")) {
                    generated = CompanionGenerator.generateCandidates(from: inputText, language: Locale.current.language.languageCode?.identifier ?? "ja")
                    selected.removeAll()
                }
                .buttonStyle(.borderedProminent)

                // 生成結果表示（正面・写真に近い品質を想定）
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(generated) { comp in
                            VStack(spacing: 8) {
                                Image(uiImage: comp.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 140, height: 180)
                                    .border(selected.contains(comp.id) ? Color.blue : Color.clear, width: 3)
                                    .onTapGesture {
                                        if selected.contains(comp.id) {
                                            selected.remove(comp.id)
                                        } else {
                                            selected.insert(comp.id)
                                        }
                                    }
                                Text(comp.name)
                                    .font(.subheadline)
                            }
                            .padding(8)
                            .background(comp.style.toEmotion().color.opacity(0.15))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }

                if !selected.isEmpty {
                    VStack(spacing: 8) {
                        Text(NSLocalizedString("NamePrompt", comment: "名前を付けてください。"))
                        TextField(NSLocalizedString("EnterName", comment: "名前を入力"), text: $nameInput)
                            .textFieldStyle(.roundedBorder)
                        Button(NSLocalizedString("VoiceNameInput", comment: "🎤 音声で入力")) {
                            CompanionOverlay.shared.speak(NSLocalizedString("SayNamePrompt", comment: "名前を話してください"), emotion: .neutral)
                            // TODO: 音声認識で nameInput を更新
                        }
                    }
                    .padding(.horizontal)
                }

                HStack {
                    Button(NSLocalizedString("Help", comment: "ヘルプ")) {
                        CompanionOverlay.shared.speak(NSLocalizedString("CompanionGeneratorHelp", comment: "条件を入力し作製ボタンで3体生成。選んで名前を付け、次へで声のタイプを選びます。"), emotion: .neutral)
                    }
                    Spacer()
                    Button(NSLocalizedString("Next", comment: "次へ")) {
                        navigateVoiceSelection = true
                    }
                    .disabled(selected.isEmpty || nameInput.isEmpty)
                }
                .padding(.horizontal)

                NavigationLink("", isActive: $navigateVoiceSelection) {
                    VoiceProfileSelectionView(
                        selectedCompanionIDs: Array(selected),
                        generatedCompanions: generated,
                        givenName: nameInput,
                        conditionsText: inputText
                    )
                }
                .hidden()
            }
            .padding(.vertical)
            .navigationTitle(NSLocalizedString("CompanionGeneratorTitle", comment: "コンパニオン作製"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("MainScreen", comment: "メイン画面へ")) { dismiss() }
                    Button(NSLocalizedString("Back", comment: "もどる")) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Help", comment: "ヘルプ")) {
                        CompanionOverlay.shared.speak(NSLocalizedString("CompanionGeneratorScreenHelp", comment: "この画面では条件入力、3体作製、選択、命名ができます。"), emotion: .neutral)
                    }
                }
            }
        }
    }
}
