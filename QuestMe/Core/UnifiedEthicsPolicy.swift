//
//  UnifiedEthicsPolicy.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/UnifiedEthicsPolicy.swift
//
//  🎯 ファイルの目的:
//      全分野の免責文と表現安全化（資格取得含む）。
//      - トピックに応じて免責文とトーンガードを適用。
//      - 資格関連は CertificationToneGuard を使用。
//
//  🔗 依存:
//      - Foundation
//      - CertificationEthicsPolicy.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

final class UnifiedEthicsPolicy: ObservableObject {
    func disclaimer(for topic: ConversationTopic) -> String {
        switch topic {
        case .growth:
            return CertificationDisclaimerProvider.disclaimerJP()
        case .health:
            return "以下は健康に関する一般情報であり、診断や治療の代替ではありません。"
        default:
            return "以下は一般的な情報提供であり、専門的判断の代替ではありません。"
        }
    }

    func empatheticPrefix(for topic: ConversationTopic) -> String {
        switch topic {
        case .growth: return "前向きな挑戦として"
        case .anxiety: return "不安に寄り添いながら"
        case .health: return "健康を支える視点から"
        default: return "参考情報として"
        }
    }

    func soften(_ text: String) -> String {
        return CertificationToneGuard.soften(text)
    }

    func enforceSourcePrefix(_ source: String?) -> String {
        return CertificationToneGuard.enforceSourcePrefix(source)
    }

    func score(_ text: String) -> Int {
        return CertificationToneGuard.score(text)
    }

    func shouldBlock(_ score: Int) -> Bool {
        return CertificationToneGuard.shouldBlock(score)
    }

    func shouldCaution(_ score: Int) -> Bool {
        return CertificationToneGuard.shouldCaution(score)
    }

    func blockedReply() -> String {
        return CertificationToneGuard.blockedReply()
    }

    func safeReply(from original: String) -> String {
        return CertificationToneGuard.safeReply(from: original)
    }

    func sanitizeUserInput(_ text: String) -> String {
        return soften(text)
    }
}
