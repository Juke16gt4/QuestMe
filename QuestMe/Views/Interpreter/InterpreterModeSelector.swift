//
//  InterpreterModeSelector.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/InterpreterModeSelector.swift
//
//  🎯 目的:
//      「通訳」ボタン押下後に3つのモードを選択する画面。
//      - 自分（iPods×_iPhoneQuestMe○） → 相手（iPods○）
//      - 自分（iPods○) → 相手（iPods×_iPhoneQuestMe○）
//      - 双方（iPods×_iPhoneQuestMe○）
//      選択時に声紋認証制御と翻訳機能を起動。
//      終了時は必ず声紋認証を再ロック。
//      会話ログは「会話」フォルダに保存し EmotionLogRepository にも連動。
//      12言語対応の「メイン画面」「ヘルプ」ボタンを配置。
//
//  🔗 連動:
//      - FloatingCompanionOverlayView.swift
//      - VoiceprintAuthManager.swift
//      - EmotionLogRepository.swift
//      - LogEntry.swift
//
//  👤 作成者: 津村 淳一
//  📅 改変日: 2025-10-23
//

import SwiftUI

struct InterpreterModeSelector: View {
    @Environment(\.dismiss) private var dismiss
    @State private var activeMode: Mode? = nil
    @State private var explainedOnce: Bool = UserDefaults.standard.bool(forKey: "interpreter_explained_once")

    // 親（FloatingCompanionOverlayView）から渡される発話ハンドラ
    var speakHandler: (_ text: String, _ emotion: EmotionType) -> Void

    enum Mode: String {
        case meOff_peerOn = "自分（iPods×_iPhoneQuestMe○） → 相手（iPods○)"
        case meOn_peerOff = "自分（iPods○) → 相手（iPods×_iPhoneQuestMe○）"
        case bothOff      = "双方（iPods×_iPhoneQuestMe○)"
    }

    var body: some View {
        VStack(spacing: 20) {
            // 戻るボタン
            HStack {
                Spacer()
                Button("← 戻る") {
                    speakHandler("戻ります。", .neutral)
                    dismiss()
                }
                .buttonStyle(.bordered)
            }

            Text("🎧 通訳モード選択")
                .font(.title2)
                .bold()

            // 初回のみ説明
            if !explainedOnce {
                Text("この画面では、接続状態に応じて3つの通訳モードを選べます。")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .onAppear {
                        speakHandler("この画面では、接続状態に応じて三つの通訳モードを選べます。初回のみご案内します。", .gentle)
                        UserDefaults.standard.set(true, forKey: "interpreter_explained_once")
                        explainedOnce = true
                    }
            }

            // 3モードボタン
            Button(Mode.meOff_peerOn.rawValue) {
                activeMode = .meOff_peerOn
                VoiceprintAuthManager.shared.temporarilyDisable(reason: "相手のみiPods所持")
                speakHandler("相手のiPodsを利用して通訳を開始します。複数人の場合はお一人ずつQuestMeのAIコンパニオンに話しかけてください。", .neutral)
            }
            .buttonStyle(.borderedProminent)

            Button(Mode.meOn_peerOff.rawValue) {
                activeMode = .meOn_peerOff
                VoiceprintAuthManager.shared.ensureEnabled()
                speakHandler("あなたのiPodsを利用して通訳を開始します。相手の方は「ありがとう！」と母国語で発話してください。", .neutral)
            }
            .buttonStyle(.borderedProminent)

            Button(Mode.bothOff.rawValue) {
                activeMode = .bothOff
                VoiceprintAuthManager.shared.temporarilyDisable(reason: "双方iPodsなし")
                speakHandler("お話しするお相手の母国語を音声で教えてください。", .gentle)
            }
            .buttonStyle(.borderedProminent)

            // 現在のモードごとのUI
            if let mode = activeMode {
                modeUI(for: mode)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - モードごとのUI
    @ViewBuilder
    private func modeUI(for mode: Mode) -> some View {
        switch mode {
        case .meOff_peerOn:
            VStack(spacing: 12) {
                Text("相手が複数言語を話す場合は聞き分けて翻訳します。ユーザー発話は相手の母国語に変換して音声＋テキストで返します。")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button("会話終了") { saveAndExit(mode: "meOff_peerOn") }
                    .buttonStyle(.borderedProminent)
            }

        case .meOn_peerOff:
            VStack(spacing: 12) {
                Text("相手に「ありがとう！」と母国語で発話してもらい、言語を推定します。")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button("○○語ですか？ → はい") {
                    speakHandler("○○語で会話を開始します。", .neutral)
                }
                Button("○○語ですか？ → いいえ") {
                    speakHandler("どちらのお言葉ですか❓", .neutral)
                }

                Button("会話終了") { saveAndExit(mode: "meOn_peerOff") }
                    .buttonStyle(.borderedProminent)
            }

        case .bothOff:
            VStack(spacing: 12) {
                Text("双方の端末でQuestMeを利用して通訳を行います。複数言語が混在する場合は順次案内します。")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button("会話終了") { saveAndExit(mode: "bothOff") }
                    .buttonStyle(.borderedProminent)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("メイン画面へ") {
                        VoiceprintAuthManager.shared.restoreIfNeeded()
                        speakHandler("メイン画面に戻ります。声紋認証を再ロックしました。", .neutral)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("ヘルプ") {
                        speakHandler("この画面では相手の母国語を設定して会話を行います。終了時は会話終了ボタンを押してください。", .neutral)
                    }
                }
            }
        }
    }

    // MARK: - 保存と終了処理
    private func saveAndExit(mode: String) {
        ConversationLogManager.shared.save(folder: "会話", entries: currentConversationEntries)
        EmotionLogRepository.shared.saveLog(
            text: "会話終了",
            emotion: .neutral,
            ritual: "InterpreterModeSelector",
            metadata: ["mode": mode]
        )
        VoiceprintAuthManager.shared.restoreIfNeeded()
        speakHandler("会話を終了しました。声紋認証を再ロックしました。", .gentle)
        activeMode = nil
    }
}
