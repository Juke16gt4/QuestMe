//
//  MeetingMinutesView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Meeting/MeetingMinutesView.swift
//
//  🎯 ファイルの目的:
//      会議終了後に生成された Markdown 議事録をプレビュー表示する儀式ビュー。
//      - Companion が「議事録をまとめました」と案内。
//      - Markdown保存（fileExporter）と Slack投稿（要約版/全文）に対応。
//      - CompanionOverlay による音声ガイドと連携。
//      - 12言語対応のヘルプボタンを右上に常設。
//      - 「← 戻る」「🏠 メイン画面へ」ボタンを常設。
//      - 音声コマンド（戻る・メインへ・ヘルプ）に対応。
//
//  🔗 連動ファイル:
//      - MeetingManager.swift（議事録生成）
//      - SlackManager.swift（投稿）
//      - CompanionOverlay.swift（音声）
//      - MarkdownFile.swift（保存形式）
//      - VoiceCommandListener.swift（音声コマンド）
//      - SpeechSync.swift（言語判定）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月20日
//

import SwiftUI
import UniformTypeIdentifiers

struct MeetingMinutesView: View {
    @ObservedObject var manager = MeetingManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var exportedMarkdown: String = ""
    @State private var showExporter = false
    @State private var showExportAlert = false
    @State private var showSlackAlert = false
    @State private var slackSuccess = false
    @State private var slackMessage = ""

    private let title = "会議/講義"
    private let dateString = "2025-10-05"
    private let attendees = ["津村淳一", "チームメンバー"]
    private let topics = ["新機能レビュー", "運動/食事統合", "議事録出力"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("議事録をまとめました。保存またはSlackに投稿できます。")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()

                ScrollView {
                    Text(manager.transcript.isEmpty ? "_（記録なし）_" : manager.transcript)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)

                Button("🏠 メイン画面へ") {
                    CompanionOverlay.shared.speak("メイン画面に戻ります。")
                    dismiss()
                }
                .buttonStyle(.bordered)

                VStack(spacing: 16) {
                    Button("Markdownファイルとして保存/共有") {
                        exportedMarkdown = manager.generateMarkdownMinutes(
                            title: title,
                            date: dateString,
                            attendees: attendees,
                            topics: topics
                        )
                        showExporter = true
                    }

                    Button("Slackに要約版を投稿") {
                        let fullMarkdown = manager.generateMarkdownMinutes(
                            title: title,
                            date: dateString,
                            attendees: attendees,
                            topics: topics
                        )
                        let summaryMarkdown = manager.generateSummary(from: fullMarkdown)
                        SlackManager.shared.postMinutes(markdown: summaryMarkdown) { success in
                            DispatchQueue.main.async {
                                slackSuccess = success
                                slackMessage = success ? "Slackに要約版を投稿しました。" : "Slackへの投稿に失敗しました。"
                                showSlackAlert = true
                                CompanionOverlay.shared.speak(slackMessage)
                            }
                        }
                    }

                    Button("Slackに全文を投稿") {
                        let fullMarkdown = manager.generateMarkdownMinutes(
                            title: title,
                            date: dateString,
                            attendees: attendees,
                            topics: topics
                        )
                        SlackManager.shared.postMinutes(markdown: fullMarkdown) { success in
                            DispatchQueue.main.async {
                                slackSuccess = success
                                slackMessage = success ? "Slackに全文議事録を投稿しました。" : "Slackへの投稿に失敗しました。"
                                showSlackAlert = true
                                CompanionOverlay.shared.speak(slackMessage)
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("📜 議事録プレビュー")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← 戻る") {
                        CompanionOverlay.shared.speak("前の画面に戻ります。")
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("❓") {
                        CompanionOverlay.shared.speak(helpText(for: SpeechSync().currentLanguage))
                    }
                }
            }
            .onAppear {
                VoiceCommandListener.shared.startListening { command in
                    let normalized = command.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    switch normalized {
                    case "戻る", "back":
                        CompanionOverlay.shared.speak("前の画面に戻ります。")
                        dismiss()
                    case "メインへ", "home":
                        CompanionOverlay.shared.speak("メイン画面に戻ります。")
                        dismiss()
                    case "ヘルプ", "help":
                        CompanionOverlay.shared.speak(helpText(for: SpeechSync().currentLanguage))
                    default:
                        CompanionOverlay.shared.speak("音声コマンドが認識されませんでした。")
                    }
                }
            }
            .fileExporter(
                isPresented: $showExporter,
                document: MarkdownFile(text: exportedMarkdown),
                contentType: .plainText,
                defaultFilename: "MeetingMinutes.md"
            ) { result in
                switch result {
                case .success:
                    showExportAlert = true
                    CompanionOverlay.shared.speak("Markdownファイルを保存しました。")
                case .failure(let error):
                    print("保存失敗: \(error.localizedDescription)")
                }
            }
            .alert(isPresented: $showExportAlert) {
                Alert(title: Text("保存完了"),
                      message: Text("Markdownファイルとして保存されました。"),
                      dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showSlackAlert) {
                Alert(title: Text(slackSuccess ? "Slack投稿成功" : "Slack投稿失敗"),
                      message: Text(slackMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: - 多言語対応ヘルプ
    private func helpText(for lang: String) -> String {
        switch lang {
        case "ja": return "この画面では議事録を保存したり、Slackに投稿できます。音声でも操作できます。"
        case "en": return "You can save or post meeting minutes to Slack. Voice commands are supported."
        case "fr": return "Vous pouvez enregistrer ou publier le compte rendu sur Slack. Commandes vocales disponibles."
        case "de": return "Sie können das Protokoll speichern oder auf Slack posten. Sprachbefehle sind verfügbar."
        case "es": return "Puede guardar o publicar el acta en Slack. Se admiten comandos de voz."
        case "zh": return "您可以保存或将会议记录发布到Slack。支持语音命令。"
        case "ko": return "회의록을 저장하거나 Slack에 게시할 수 있습니다. 음성 명령을 지원합니다."
        case "pt": return "Você pode salvar ou postar a ata no Slack. Comandos de voz são suportados."
        case "it": return "Puoi salvare o pubblicare il verbale su Slack. Comandi vocali disponibili."
        case "hi": return "आप मीटिंग मिनट्स को सेव या Slack पर पोस्ट कर सकते हैं। वॉइस कमांड उपलब्ध हैं।"
        case "sv": return "Du kan spara eller posta protokollet till Slack. Röstkommandon stöds."
        case "no": return "Du kan lagre eller poste møtereferatet til Slack. Støtter stemmekommandoer."
        default: return "You can save or post meeting minutes. Voice commands are supported."
        }
    }
}
