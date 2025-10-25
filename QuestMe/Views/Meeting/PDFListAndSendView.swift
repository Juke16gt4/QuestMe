//
//  PDFListAndSendView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Meeting/PDFListAndSendView.swift
//
//  🎯 ファイルの目的:
//      録音後に生成されたPDF議事録を一覧表示・検索・選択・メール送信する儀式ビュー。
//      - 最大5件の送信先登録に対応。
//      - Companion による音声案内と感情ログ保存に対応。
//      - 12言語対応のヘルプボタンを右上に常設。
//      - 録音儀式・議事録保存・メール送信と完全連動。
//      - PDFは保存から72時間後に自動削除されるため、削除ボタンは不要。
//
//  🔗 連動ファイル:
//      - MeetingRecordingView.swift（録音儀式）
//      - PDFDeletionScheduler.swift（PDF自動削除）
//      - MailComposerView.swift（メール送信）
//      - SpeechSync.swift（言語判定）
//      - CompanionOverlay.swift（音声案内）
//      - EmotionLogManager.swift（感情ログ保存）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月19日
//

import SwiftUI

struct PDFListAndSendView: View {
    @State private var allPDFs: [URL] = []
    @State private var searchText = ""
    @State private var selectedPDFs: Set<URL> = []
    @State private var emailRecipients: [String] = []
    @State private var newEmail = ""
    @State private var showMailComposer = false
    
    var filteredPDFs: [URL] {
        if searchText.isEmpty { return allPDFs }
        return allPDFs.filter { $0.lastPathComponent.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // 🔍 一覧表示＋検索バー
                HStack {
                    Button(localized("listButton")) {
                        loadPDFs()
                        CompanionOverlay.shared.speak(localized("listSpoken"))
                        EmotionLogManager.shared.save(event: "PDF一覧表示", emotion: .neutral)
                    }
                    Spacer()
                    TextField(localized("searchPlaceholder"), text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: searchText) { _ in
                            CompanionOverlay.shared.speak(localized("searchSpoken"))
                            EmotionLogManager.shared.save(event: "PDF検索", emotion: .focused)
                        }
                }
                .padding(.horizontal)
                
                // ✅ PDF一覧（選択可能）
                List(filteredPDFs, id: \.self, selection: $selectedPDFs) { pdf in
                    Text(pdf.lastPathComponent)
                        .onTapGesture {
                            toggleSelection(for: pdf)
                            CompanionOverlay.shared.speak(localized("selectedSpoken") + pdf.lastPathComponent)
                            EmotionLogManager.shared.save(event: "PDF選択", emotion: .positive)
                        }
                }
                .environment(\.editMode, .constant(.active))
                
                // 📧 メール送信UI
                VStack(spacing: 8) {
                    TextField(localized("emailPlaceholder"), text: $newEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(localized("addEmailButton")) {
                        let trimmed = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard trimmed.contains("@"), emailRecipients.count < 5 else { return }
                        emailRecipients.append(trimmed)
                        newEmail = ""
                        CompanionOverlay.shared.speak(localized("emailAddedSpoken"))
                        EmotionLogManager.shared.save(event: "メールアドレス追加", emotion: .positive)
                    }
                    .disabled(emailRecipients.count >= 5)
                    
                    ForEach(emailRecipients, id: \.self) { email in
                        Text("📧 \(email)").font(.caption)
                    }
                    
                    Button(localized("sendButton")) {
                        showMailComposer = true
                        CompanionOverlay.shared.speak(localized("sendSpoken"))
                        EmotionLogManager.shared.save(event: "PDF送信開始", emotion: .focused)
                    }
                    .disabled(selectedPDFs.isEmpty || emailRecipients.isEmpty)
                }
                .padding(.horizontal)
                
                // 🏠 メイン画面へ
                Button("🏠 メイン画面へ") {
                    CompanionOverlay.shared.speak("メイン画面に戻ります。")
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .navigationTitle(localized("title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← 戻る") {
                        CompanionOverlay.shared.speak("前の画面に戻ります。")
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("❓") {
                        let lang = SpeechSync().currentLanguage
                        CompanionOverlay.shared.speak(helpText(for: lang))
                    }
                }
            }
            .sheet(isPresented: $showMailComposer) {
                MailComposerView(recipients: emailRecipients, attachments: Array(selectedPDFs))
            }
            .onAppear {
                // PDF自動削除スケジューラ起動
                PDFDeletionScheduler.shared.scheduleCleanup(expirationHours: 72)
                
                // 音声コマンドリスナー
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
    
    // MARK: - PDF読み込み
    private func loadPDFs() {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("会議_講義")
        let files = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
        allPDFs = files.filter { $0.pathExtension == "pdf" }
    }
    
    // MARK: - 選択切替
    private func toggleSelection(for pdf: URL) {
        if selectedPDFs.contains(pdf) {
            selectedPDFs.remove(pdf)
        } else {
            selectedPDFs.insert(pdf)
        }
    }
    
    // MARK: - 多言語対応ラベル
    private func localized(_ key: String) -> String {
        let lang = SpeechSync().currentLanguage
        switch (key, lang) {
        case ("title", "ja"): return "📄 PDF一覧と送信"
        case ("listButton", "ja"): return "一覧表示"
        case ("searchPlaceholder", "ja"): return "検索"
        case ("emailPlaceholder", "ja"): return "メールアドレスを追加"
        case ("addEmailButton", "ja"): return "追加"
        case ("sendButton", "ja"): return "📤 メール送信"
        case ("listSpoken", "ja"): return "PDF一覧を表示しました。"
        case ("searchSpoken", "ja"): return "検索を開始しました。"
        case ("selectedSpoken", "ja"): return "選択しました: "
        case ("emailAddedSpoken", "ja"): return "メールアドレスを追加しました。"
        case ("sendSpoken", "ja"): return "PDFをメール送信します。"
            // 他言語も同様に追加（en, fr, de, es, zh, ko, pt, it, hi, sv, no）
        default: return key
        }
    }
    
    // MARK: - 多言語対応ヘルプ
    private func helpText(for lang: String) -> String {
        switch lang {
        case "ja":
            return "この画面では保存されたPDFを一覧表示し、検索・選択・メール送信ができます。最大5件まで送信先を登録できます。保存されたPDFは72時間後に自動的に削除されます。"
        case "en":
            return "This screen lets you view saved PDFs, search, select, and send them via email. Up to 5 recipients. PDFs auto-delete after 72 hours."
        case "fr":
            return "Cette vue permet d'afficher les PDF enregistrés, de les rechercher, sélectionner et envoyer par email. Suppression automatique après 72 heures."
        case "de":
            return "In dieser Ansicht können gespeicherte PDFs angezeigt, durchsucht, ausgewählt und per E-Mail versendet werden. Gespeicherte PDFs werden nach 72 Stunden automatisch gelöscht."
        case "es":
            return "Esta pantalla permite ver, buscar, seleccionar y enviar por correo electrónico los PDFs guardados. Los PDFs se eliminan automáticamente después de 72 horas."
        case "zh":
            return "此界面可查看、搜索、选择并通过电子邮件发送已保存的PDF文件。保存的PDF将在72小时后自动删除。"
        case "ko":
            return "이 화면에서는 저장된 PDF를 보고, 검색하고, 선택하여 이메일로 보낼 수 있습니다. 저장된 PDF는 72시간 후 자동 삭제됩니다."
        case "pt":
            return "Esta tela permite visualizar, pesquisar, selecionar e enviar PDFs salvos por e-mail. Os PDFs são excluídos automaticamente após 72 horas."
        case "it":
            return "Questa schermata consente di visualizzare, cercare, selezionare e inviare i PDF salvati via email. I PDF vengono eliminati automaticamente dopo 72 ore."
        case "hi":
            return "यह स्क्रीन सहेजे गए PDF को देखने, खोजने, चुनने और ईमेल से भेजने की सुविधा देती है। सहेजे गए PDF 72 घंटे बाद स्वतः हट जाते हैं।"
        case "sv":
            return "Denna vy låter dig visa, söka, välja och e-posta sparade PDF-filer. Sparade PDF-filer tas bort automatiskt efter 72 timmar."
        case "no":
            return "Denne skjermen lar deg vise, søke, velge og sende lagrede PDF-filer via e-post. Lagrede PDF-er slettes automatisk etter 72 timer."
        default:
            return "This screen lets you manage saved PDFs: view, search, select, and email them. PDFs auto-delete after 72 hours."
        }
    }
}
