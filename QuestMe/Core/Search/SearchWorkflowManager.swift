//
//  SearchWorkflowManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/SearchWorkflowManager.swift
//
//  🎯 ファイルの目的:
//      母国語入力の検索 → 地域判定 → グローバル検索 → 翻訳（Google Cloud Translation）
//      → PDF保存（カレンダーホルダー） → EventKitでカレンダー登録、までを一気通貫で実行。
//      再利用可能なワークフロー・ファサード。
//      - FolderName: 検索キーワード（母国語）
//      - FileName: タイムスタンプ（YYYYMMDD-HHMMSS）
//      - PDF本文に検索結果とメタ情報（地域、国コード、タイムスタンプなど）を含める
//
//  🔗 連動ファイル:
//      - GoogleTranslator.swift（Google Cloud Translation API 呼び出し）
//      - GlobalSearchAPI.swift（検索結果取得：実装差し替えポイント）
//      - PDFSaver.swift（PDF作成・保存）
//      - CalendarManager.swift（EventKit連携）
//      - UserProfile.swift（postalCode / countryCode / region）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月17日
//

import Foundation
import Combine

final class SearchWorkflowManager {

    private let calendarManager = CalendarManager()

    /// 検索ワークフローを実行
    /// - Parameters:
    ///   - query: 母国語での検索キーワード
    ///   - userProfile: 郵便番号・国コード・地域などを保持するプロファイル
    ///   - completion: 成否と保存先情報（PDFパス）を返す
    func runSearch(
        query: String,
        userProfile: UserProfile,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        // 1. 地域判定（postalCode + countryCode）
        let region = RegionResolver.resolveRegion(
            postalCode: userProfile.postalCode,
            countryCode: userProfile.countryCode
        )

        // 2. グローバル検索（地域をヒントに）
        GlobalSearchAPI.search(query: query, region: region) { rawResults in
            // 3. 翻訳（母国語へ）
            let targetLang = LanguageDetector.detectUserLanguageCode(for: query) // 例: "JA"
            GoogleTranslator.translate(text: rawResults, targetLang: targetLang) { translated in
                guard let translated = translated else {
                    completion(.failure(SearchWorkflowError.translationFailed))
                    return
                }

                // 4. PDF 保存（カレンダーホルダー）
                let folderName = Self.makeFolderName(from: query)
                let fileName = Self.makeTimestampFileName()
                let meta = PDFMeta(
                    keyword: query,
                    region: region,
                    countryCode: userProfile.countryCode,
                    timestamp: Date()
                )

                do {
                    let savedURL = try PDFSaver.saveTextAsPDF(
                        translated,
                        folderName: folderName,
                        fileName: fileName,
                        meta: meta
                    )

                    // 5. カレンダー登録（EventKit）
                    calendarManager.addSearchResultToCalendar(
                        keyword: query,
                        translatedResult: translated
                    )

                    completion(.success(savedURL))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Helpers

    private static func makeFolderName(from keyword: String) -> String {
        // フォルダ名: 検索キーワード（スペース→_）
        keyword
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
    }

    private static func makeTimestampFileName() -> String {
        // ファイル名: YYYYMMDD-HHMMSS.pdf
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyyMMdd-HHmmss"
        return "\(df.string(from: Date())).pdf"
    }
}

// MARK: - Errors

enum SearchWorkflowError: Error {
    case translationFailed
}
