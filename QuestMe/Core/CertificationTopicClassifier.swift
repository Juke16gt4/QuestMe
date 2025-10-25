//
//  CertificationTopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/CertificationTopicClassifier.swift
//
//  🎯 ファイルの目的:
//      資格分野のキーワード分類。
//      - classify(text) が返り値を持たず、内部で classification を更新する。
//      - UI は @Published classification を監視して自動更新される。
//
//  🔗 連動ファイル:
//      - DashboardView.swift
//      - ConversationEntry.swift
//
//  👤 作成者: 津村 淳一
//  📅 修正日: 2025年10月16日
//

import Foundation
import Combine

/// 資格分野の分類カテゴリ
public enum CertificationTopic: String, Codable, CaseIterable {
    case domesticMedical = "国内-医療"
    case domesticLegal = "国内-法律"
    case domesticIT = "国内-IT"
    case domesticFinance = "国内-金融"
    case internationalLanguage = "国際-語学"
    case internationalTech = "国際-技術"
    case internationalBusiness = "国際-ビジネス"
    case other = "その他"
}

@MainActor
final class CertificationTopicClassifier: ObservableObject {
    @Published var classification: String = ""

    /// 入力テキストを分類し、Published classification を更新する
    func classify(_ text: String) {
        let l = text.lowercased()
        var result: CertificationTopic = .other

        // 国内資格
        if l.contains("薬剤師") || l.contains("看護師") || l.contains("医師国家試験") {
            result = .domesticMedical
        } else if l.contains("司法書士") || l.contains("行政書士") || l.contains("社労士") {
            result = .domesticLegal
        } else if l.contains("基本情報") || l.contains("応用情報") || l.contains("セキュリティ") {
            result = .domesticIT
        } else if l.contains("簿記") || l.contains("fp") || l.contains("税理士") {
            result = .domesticFinance
        }
        // 国際資格
        else if l.contains("toefl") || l.contains("ielts") || l.contains("toeic") {
            result = .internationalLanguage
        } else if l.contains("aws") || l.contains("azure") || l.contains("google cloud") || l.contains("microsoft learn") {
            result = .internationalTech
        } else if l.contains("us cpa") || l.contains("pmp") || l.contains("mba") || l.contains("cfa") {
            result = .internationalBusiness
        }

        // ✅ Published を更新
        classification = result.rawValue
    }
}
