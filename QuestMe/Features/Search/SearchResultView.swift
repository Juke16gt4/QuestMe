//
//  SearchResultView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Features/Search/SearchResultView.swift
//
//  🎯 目的:
//      - 検索結果を表示し、「保存」「再検索」を手動/音声の両方で実行可能にする。
//      - 保存時に PDF を生成し、カレンダーホルダーへ AI コンパニオン命名で保存。
//      - 完了後は吹き出し＋音声で案内。「再検索」は戻し＋音声促し。
//      - 12言語コマンドは SpeechSyncManager 側で拡張可能。
//
//  🔗 依存:
//      - SwiftUI
//      - PDFKit（PDF 表示/検証）
//      - UIKit（UIGraphicsPDFRenderer で PDF 生成：iOS）
//      - SpeechSyncManager（音声認識/音声案内）
//
//  🔗 関連/連動ファイル:
//      - UnifiedTopicClassifier.swift（分類連動が必要な場合）
//      - VoiceIntentRouter+ML.swift（音声入力の別経路）
//      - SearchView.swift（検索画面本体に戻るハンドラ onRetry）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月17日
//

import SwiftUI
import PDFKit
import UIKit
import AVFoundation   // 音声合成
import NaturalLanguage // 言語判定

struct SearchResultView: View {
    @State private var showSavedMessage = false
    @State private var showRetryMessage = false
    @State private var folderName = ""
    @State private var fileName = ""
    @State private var latestSavedURL: URL?

    let searchContent: String
    let onRetry: () -> Void   // 検索画面に戻るためのクロージャ

    var body: some View {
        VStack(spacing: 16) {
            Text("検索結果")
                .font(.title3)
                .bold()

            ScrollView {
                Text(searchContent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
            }

            Spacer(minLength: 12)

            HStack(spacing: 12) {
                Button {
                    saveToCalendarFolder()
                } label: {
                    Label("保存", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    handleRetry()
                } label: {
                    Label("再検索", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
            }
            .padding(.bottom, 8)
        }
        .padding()
        .overlay(alignment: .bottom) {
            CompanionBubbleOverlay(
                showSavedMessage: showSavedMessage,
                savedText: "検索内容はPDFに変換され、カレンダーホルダー（\(folderName)）で保存いたしました。",
                showRetryMessage: showRetryMessage,
                retryText: "キーワードをいくつか増やして、再検索してみてください。"
            )
            .padding(.bottom, 8)
        }
        .onAppear {
            // 音声認識を開始（多言語対応は SpeechSyncManager 側で設定）
            SpeechSyncManager.shared.startRecognition { transcript in
                let lower = transcript.lowercased()
                if matchesSaveCommand(lower) {
                    saveToCalendarFolder()
                } else if matchesRetryCommand(lower) {
                    handleRetry()
                }
            }
        }
    }

    // MARK: - 保存処理本体

    private func saveToCalendarFolder() {
        // AI コンパニオンが命名（検索内容にちなんだフォルダ/ファイル名）
        folderName = AINaming.generateFolderName(from: searchContent)
        fileName = AINaming.generateFileName(from: searchContent)

        // カレンダーホルダーのパス（Documents/Calendar/YYYY-MM-DD/{folderName}）
        let holderURL = CalendarHolder.urlForTodayFolder(named: folderName)

        // フォルダ作成
        do {
            try FileManager.default.createDirectory(at: holderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            withAnimation { showSavedMessage = false }
            SpeechSyncManager.shared.speak("保存先フォルダの作成に失敗しました。もう一度お試しください。")
            return
        }

        // PDF 生成
        guard let pdfURL = PDFSaver.saveTextAsPDF(searchContent, toFolder: holderURL, fileName: fileName) else {
            withAnimation { showSavedMessage = false }
            SpeechSyncManager.shared.speak("PDF の生成に失敗しました。内容を調整して再度お試しください。")
            return
        }

        latestSavedURL = pdfURL

        // 完了メッセージ（吹き出し＋音声）
        withAnimation { showSavedMessage = true }
        SpeechSyncManager.shared.speak("検索内容はPDFに変換され、カレンダーホルダー、\(folderName)で保存いたしました。")
    }

    // MARK: - 再検索処理

    private func handleRetry() {
        onRetry()
        withAnimation { showRetryMessage = true }
        SpeechSyncManager.shared.speak("キーワードをいくつか増やして、再検索してみてください。")
    }

    // MARK: - 音声コマンド判定（多言語拡張可能）

    private func matchesSaveCommand(_ lower: String) -> Bool {
        // 主要言語の代表コマンドを網羅（必要に応じて SpeechSyncManager 側の辞書で拡張）
        return lower.contains("保存") || lower.contains("セーブ") || lower.contains("save") ||
               lower.contains("guardar") || lower.contains("speichern") || lower.contains("salvar") ||
               lower.contains("salva") || lower.contains("сохранить") ||
               lower.contains("حفظ") || lower.contains("저장") || lower.contains("保存して")
    }

    private func matchesRetryCommand(_ lower: String) -> Bool {
        return lower.contains("再検索") || lower.contains("やり直し") || lower.contains("retry") ||
               lower.contains("buscar de nuevo") || lower.contains("erneut suchen") ||
               lower.contains("rechercher à nouveau") || lower.contains("再次搜索") ||
               lower.contains("다시 검색") || lower.contains("повторный поиск") || lower.contains("ابحث مرة أخرى")
    }
}

// MARK: - コンパニオン吹き出し（既存宣言と衝突しないため別名にしています）

struct CompanionBubbleOverlay: View {
    let showSavedMessage: Bool
    let savedText: String
    let showRetryMessage: Bool
    let retryText: String

    var body: some View {
        VStack(spacing: 8) {
            if showSavedMessage {
                bubble(savedText, color: Color(.systemYellow))
            }
            if showRetryMessage {
                bubble(retryText, color: Color(.systemOrange))
            }
        }
        .transition(.opacity)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func bubble(_ message: String, color: Color) -> some View {
        Text(message)
            .font(.subheadline)
            .padding(12)
            .background(color.opacity(0.95))
            .cornerRadius(12)
            .shadow(radius: 4)
    }
}

// MARK: - 音声認識/音声案内（シングルトン）

final class SpeechSyncManager {
    static let shared = SpeechSyncManager()

    private init() {}

    // 音声認識開始（多言語対応は内部設定で拡張）
    func startRecognition(onTranscript: @escaping (String) -> Void) {
        // 実装例（実際は SFSpeechRecognizer を利用）
        // このダミーは即時に何もしません。実際の音声認識実装に差し替えてください。
        // SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
        // recognitionTask ... onTranscript(partialResult.bestTranscription.formattedString)
    }

    // 音声案内（AVSpeechSynthesizer を利用想定）
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
}

// MARK: - AI 命名ルール

enum AINaming {
    static func generateFolderName(from content: String) -> String {
        // 例: 主要語 + 日付（YYYY-MM-DD）
        let keyword = content
            .split(separator: " ")
            .first
            .map(String.init)?
            .prefix(12) ?? "検索内容"
        let date = ISO8601DateFormatter().string(from: Date()).prefix(10) // YYYY-MM-DD
        return "\(keyword)_\(date)"
    }

    static func generateFileName(from content: String) -> String {
        // 例: トピック風ファイル名 + .pdf
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = trimmed.isEmpty ? "検索結果" : trimmed.replacingOccurrences(of: " ", with: "_")
        return "\(base.prefix(64)).pdf"
    }
}

// MARK: - カレンダーホルダー（当日フォルダ）

enum CalendarHolder {
    static func urlForTodayFolder(named folderName: String) -> URL {
        // アプリの Documents/Calendar/YYYY-MM-DD/{folderName}
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let calendarRoot = docs.appendingPathComponent("Calendar", isDirectory: true)
        let today = ISO8601DateFormatter().string(from: Date()).prefix(10) // YYYY-MM-DD
        return calendarRoot
            .appendingPathComponent(String(today), isDirectory: true)
            .appendingPathComponent(folderName, isDirectory: true)
    }
}

// MARK: - PDF 保存ユーティリティ（PDFKit + UIGraphicsPDFRenderer）

enum PDFSaver {
    /// テキストを A4 相当の PDF に整形して保存（iOS 想定）
    static func saveTextAsPDF(_ text: String, toFolder folderURL: URL, fileName: String) -> URL? {
        let targetURL = folderURL.appendingPathComponent(fileName)

        // ページ設定（A4: 595x842 pt）
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .left

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .paragraphStyle: paragraph
        ]

        // 余白
        let margin: CGFloat = 36
        let contentRect = pageRect.insetBy(dx: margin, dy: margin)

        do {
            let data = renderer.pdfData { ctx in
                ctx.beginPage()
                // タイトル
                let title = "検索結果（\(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))）"
                let titleAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 16)
                ]
                let titleRect = CGRect(x: contentRect.minX, y: contentRect.minY, width: contentRect.width, height: 24)
                title.draw(in: titleRect, withAttributes: titleAttrs)

                // 本文
                let bodyRect = CGRect(x: contentRect.minX, y: titleRect.maxY + 12, width: contentRect.width, height: contentRect.height - 48)
                (text as NSString).draw(in: bodyRect, withAttributes: attrs)

                // フッタ
                let footer = "QuestMe • AIコンパニオン保存"
                let footerAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let footerSize = (footer as NSString).size(withAttributes: footerAttrs)
                let footerPoint = CGPoint(x: contentRect.maxX - footerSize.width, y: pageRect.maxY - margin + 8)
                (footer as NSString).draw(at: footerPoint, withAttributes: footerAttrs)
            }

            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            try data.write(to: targetURL, options: .atomic)

            // 生成物を PDFKit 経由で検証（任意）
            if PDFDocument(url: targetURL) == nil {
                return nil
            }

            return targetURL
        } catch {
            return nil
        }
    }
}
// MARK: - 音声コマンド判定
   private func matchesSaveCommand(_ lower: String) -> Bool {
       return lower.contains("保存") || lower.contains("save") || lower.contains("guardar")
   }
   private func matchesRetryCommand(_ lower: String) -> Bool {
       return lower.contains("再検索") || lower.contains("retry") || lower.contains("buscar")
   }
   private func matchesHelpCommand(_ lower: String) -> Bool {
       return lower.contains("ヘルプ") || lower.contains("help") || lower.contains("ayuda")
   }

