//
//  ConsentManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Consent/ConsentManager.swift
//
//  🎯 ファイルの目的:
//      ユーザーが提供するセンシティブなデータ（画像・音声・感情・健康情報）に対する同意状態を一元管理する。
//      - ConsentType ごとに同意の有無を記録。
//      - UserDefaults に保存・復元可能な ConsentState を保持。
//      - SwiftUI から ConsentManager.shared を通じて同意状態を参照・更新可能。
//      - 「No Thanks」選択時には limitedMode を有効化し、機能制限モードに移行。
//      - Companion の振る舞いや機能制限は、この ConsentState に基づいて動的に切り替えられる。
//
//  🔗 依存:
//      - UserDefaults（保存）
//      - Codable（JSON形式）
//      - CompanionSetupView.swift / VoiceEmotionAnalyzer.swift / HealthKit連携モジュール（使用箇所）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月27日

import Foundation

enum ConsentType: String, CaseIterable, Codable {
    case photoAnalysis       // 写真解析
    case voiceAnalysis       // 音声解析
    case emotionInference    // 感情推定
    case healthData          // HealthKit等
}

struct ConsentState: Codable {
    var granted: [ConsentType: Bool] = [:]
    var limitedMode: Bool = false // 「No Thanks」選択時の制限モード
}

final class ConsentManager {
    static let shared = ConsentManager()
    private let key = "questme.consent.state"
    private(set) var state: ConsentState = ConsentState()

    private init() {
        load()
    }

    func setConsent(for type: ConsentType, granted: Bool) {
        state.granted[type] = granted
        save()
    }

    func hasConsent(_ type: ConsentType) -> Bool {
        state.granted[type] ?? false
    }

    func setLimitedMode(_ enabled: Bool) {
        state.limitedMode = enabled
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(state)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            NSLog("Consent save error: \(error)")
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            state = try JSONDecoder().decode(ConsentState.self, from: data)
        } catch {
            NSLog("Consent load error: \(error)")
        }
    }
}
