//
//  CompanionRecordDashboard.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionRecordDashboard.swift
//
//  🎯 ファイルの目的:
//      録音から記録ファイル（議事録・Markdown）を生成し、保存・閲覧する儀式ビュー。
//      - Companion が音声で案内（12言語対応）
//      - 「← 戻る」「🏠 メイン画面へ」ボタンを常設
//      - 音声コマンド（戻る・メインへ・ヘルプ）に対応
//      - 音声ログは保存から72時間後に自動削除されるため、浄化ボタンは表示しない
//
//  🔗 連動ファイル:
//      - SQLManager.swift（保存ログ）
//      - SpeechLogManager.swift（保存＋72時間後削除）
//      - CompanionOverlay.swift（音声）
//      - VoiceCommandListener.swift（音声コマンド）
//      - SpeechSync.swift（言語判定）
//
//  👤 作成者: 津村 淳一
//  📅 改変日: 2025年10月20日
//

import SwiftUI

struct CompanionRecordDashboard: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("🗂 記録ダッシュボード")
                    .font(.title2)
                    .bold()

                Text("録音された議事録や記録を保存・閲覧できます。\n保存された音声は72時間後に自動的に削除されます。")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("記録を保存する") {
                    SpeechLogManager.shared.saveCurrentLog(expirationHours: 72)
                    CompanionOverlay.shared.speak("記録を保存しました。72時間後に自動的に削除されます。")
                    alertMessage = "記録を保存しました。72時間後に自動削除されます。"
                    showAlert = true
                }

                Button("🏠 メイン画面へ") {
                    CompanionOverlay.shared.speak("メイン画面に戻ります。")
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("📘 記録管理")
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
                Alert(title: Text("保存完了"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func helpText(for lang: String) -> String {
        switch lang {
        case "ja": return "この画面では記録の保存・閲覧ができます。音声でも操作できます。保存された音声は72時間後に自動的に削除されます。"
        case "en": return "You can save and view records. Voice commands are supported. Voice logs auto-delete after 72 hours."
        case "fr": return "Vous pouvez enregistrer et consulter les enregistrements. Commandes vocales disponibles. Les enregistrements vocaux sont supprimés après 72 heures."
        case "de": return "Sie können Aufzeichnungen speichern und anzeigen. Sprachbefehle verfügbar. Sprachaufzeichnungen werden nach 72 Stunden gelöscht."
        case "es": return "Puede guardar y ver registros. Se admiten comandos de voz. Los registros de voz se eliminan después de 72 horas."
        case "zh": return "您可以保存和查看记录。支持语音命令。语音记录将在72小时后自动删除。"
        case "ko": return "기록을 저장하고 볼 수 있습니다. 음성 명령을 지원합니다. 음성 기록은 72시간 후 자동 삭제됩니다."
        case "pt": return "Você pode salvar e visualizar registros. Comandos de voz disponíveis. Registros de voz são excluídos após 72 horas."
        case "it": return "Puoi salvare e visualizzare i record. Comandi vocali disponibili. I registri vocali vengono eliminati dopo 72 ore."
        case "hi": return "आप रिकॉर्ड को सेव और देख सकते हैं। वॉइस कमांड उपलब्ध हैं। वॉइस रिकॉर्ड 72 घंटे बाद हट जाते हैं।"
        case "sv": return "Du kan spara och visa poster. Röstkommandon stöds. Röstloggar tas bort efter 72 timmar."
        case "no": return "Du kan lagre og vise poster. Støtter stemmekommandoer. Talelogger slettes etter 72 timer."
        default: return "You can manage records. Voice commands are supported. Voice logs auto-delete after 72 hours."
        }
    }
}
