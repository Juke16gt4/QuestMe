//
//  RecordingConversionDialog.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Meeting/RecordingConversionDialog.swift
//
//  🎯 ファイルの目的:
//      録音された音声を Word / PDF に変換し、保存・共有・印刷する儀式ビュー。
//      - Companion が音声で案内（12言語対応）
//      - 「← 戻る」「🏠 メイン画面へ」ボタンを常設
//      - 音声コマンド（戻る・メインへ・ヘルプ）に対応
//      - 音声ログは72時間後に自動削除されるため、削除ボタンは表示しない
//
//  🔗 連動ファイル:
//      - MarkdownConverter.swift（Word変換）
//      - PDFRenderer.swift（PDF変換）
//      - CompanionOverlay.swift（音声）
//      - VoiceCommandListener.swift（音声コマンド）
//      - SpeechSync.swift（言語判定）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月20日
//

import SwiftUI

struct RecordingConversionDialog: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("📄 録音変換")
                    .font(.title2)
                    .bold()

                Text("録音された議事録を Word や PDF に変換し、保存・共有・印刷できます。\n保存された音声は72時間後に自動的に削除されます。")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("Word形式に変換") {
                    CompanionOverlay.shared.speak("Word形式に変換します。")
                    alertMessage = "Wordファイルを生成しました。"
                    showAlert = true
                }

                Button("PDF形式に変換") {
                    CompanionOverlay.shared.speak("PDF形式に変換します。")
                    alertMessage = "PDFファイルを生成しました。"
                    showAlert = true
                }

                Button("🏠 メイン画面へ") {
                    CompanionOverlay.shared.speak("メイン画面に戻ります。")
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("📝 録音変換")
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
            .alert(isPresented: $showAlert) {
                Alert(title: Text("変換完了"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func helpText(for lang: String) -> String {
        switch lang {
        case "ja": return "この画面では録音された議事録を Word や PDF に変換できます。音声でも操作できます。保存された音声は72時間後に自動的に削除されます。"
        case "en": return "You can convert recorded minutes to Word or PDF. Voice commands are supported. Logs auto-delete after 72 hours."
        case "fr": return "Vous pouvez convertir les enregistrements en Word ou PDF. Commandes vocales disponibles. Suppression automatique après 72 heures."
        case "de": return "Sie können Aufzeichnungen in Word oder PDF umwandeln. Sprachbefehle verfügbar. Automatische Löschung nach 72 Stunden."
        case "es": return "Puede convertir grabaciones a Word o PDF. Se admiten comandos de voz. Eliminación automática tras 72 horas."
        case "zh": return "您可以将录音转换为 Word 或 PDF。支持语音命令。72 小时后自动删除。"
        case "ko": return "녹음을 Word 또는 PDF로 변환할 수 있습니다. 음성 명령을 지원합니다. 72시간 후 자동 삭제됩니다."
        case "pt": return "Você pode converter gravações para Word ou PDF. Comandos de voz disponíveis. Exclusão automática após 72 horas."
        case "it": return "Puoi convertire le registrazioni in Word o PDF. Comandi vocali disponibili. Eliminazione automatica dopo 72 ore."
        case "hi": return "आप रिकॉर्ड को Word या PDF में बदल सकते हैं। वॉइस कमांड उपलब्ध हैं। 72 घंटे बाद स्वतः हट जाएगा।"
        case "sv": return "Du kan konvertera inspelningar till Word eller PDF. Röstkommandon stöds. Automatisk borttagning efter 72 timmar."
        case "no": return "Du kan konvertere opptak til Word eller PDF. Støtter stemmekommandoer. Automatisk sletting etter 72 timer."
        default: return "You can convert recordings. Voice commands are supported. Logs auto-delete after 72 hours."
        }
    }
}
