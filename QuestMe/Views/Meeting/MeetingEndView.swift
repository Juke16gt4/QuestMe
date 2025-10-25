//
//  MeetingEndView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Meeting/MeetingEndView.swift
//
//  🎯 ファイルの目的:
//      録音停止後の保存形式選択（PDF/Pages/Both）と Slack 投稿（要約版/全文/投稿しない）
//      - Companion が音声で案内（12言語対応）
//      - 「← 戻る」「🏠 メイン画面へ」ボタンを常設
//      - 音声コマンド（戻る・メインへ・ヘルプ）に対応
//
//  🔗 連動ファイル:
//      - MeetingManager.swift（要約生成）
//      - SlackManager.swift（投稿）
//      - CompanionOverlay.swift（音声）
//      - PDFRenderer.swift（PDF生成）
//      - VoiceCommandListener.swift（音声コマンド）
//      - SpeechSync.swift（言語判定）
//
//  👤 作成者: 津村 淳一
//  📅 改変日: 2025年10月20日
//

import SwiftUI

struct MeetingEndView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showFormatDialog = false
    @State private var showSlackDialog = false
    @State private var showChannelDialog = false
    @State private var slackMessage = ""
    @State private var selectedChannels: Set<String> = []

    let availableChannels = ["#general", "#project", "#random"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("議事録・講義プレビュー")
                    .font(.headline)

                ScrollView {
                    Text("ここに議事録・講義が表示されます。")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button("🏠 メイン画面へ") {
                    CompanionOverlay.shared.speak("メイン画面に戻ります。")
                    dismiss()
                }
                .buttonStyle(.bordered)

                Button("⏹ 保存する") {
                    CompanionOverlay.shared.speak("保存形式を選んでください。PDF、Pages、または両方です。")
                    showFormatDialog = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("🎓 録音終了")
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
                    case "戻る", "back": dismiss()
                    case "メインへ", "home": dismiss()
                    case "ヘルプ", "help":
                        CompanionOverlay.shared.speak(helpText(for: SpeechSync().currentLanguage))
                    default:
                        CompanionOverlay.shared.speak("音声コマンドが認識されませんでした。")
                    }
                }
            }
        }
    }

    private func helpText(for lang: String) -> String {
        switch lang {
        case "ja": return "この画面では議事録の保存形式を選び、Slackに投稿できます。音声でも操作できます。"
        case "en": return "You can choose save format and post to Slack. Voice commands are supported."
        case "fr": return "Vous pouvez choisir le format et publier sur Slack. Commandes vocales disponibles."
        case "de": return "Sie können das Format wählen und auf Slack posten. Sprachbefehle verfügbar."
        case "es": return "Puede elegir el formato y publicar en Slack. Comandos de voz disponibles."
        case "zh": return "您可以选择保存格式并发布到Slack。支持语音命令。"
        case "ko": return "저장 형식을 선택하고 Slack에 게시할 수 있습니다. 음성 명령을 지원합니다."
        case "pt": return "Você pode escolher o formato e postar no Slack. Comandos de voz disponíveis."
        case "it": return "Puoi scegliere il formato e pubblicare su Slack. Comandi vocali disponibili."
        case "hi": return "आप फ़ॉर्मेट चुन सकते हैं और Slack पर पोस्ट कर सकते हैं। वॉइस कमांड उपलब्ध हैं।"
        case "sv": return "Du kan välja format och posta till Slack. Röstkommandon stöds."
        case "no": return "Du kan velge format og poste til Slack. Støtter stemmekommandoer."
        default: return "You can choose format and post to Slack. Voice commands are supported."
        }
    }
}
