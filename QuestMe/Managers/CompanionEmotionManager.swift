//
//  CompanionEmotionManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/CompanionEmotionManager.swift
//
//  🎯 目的:
//      ユーザーの感情ログを受け取り、AIコンパニオンの内的感情状態と成長レベルを更新・保存する。
//      - 喜び/悲しみ/怒り/驚き/信頼のスコアを蓄積
//      - 総合指標に応じて growthLevel を段階的に上げる
//      - 1日単位で JSON 保存（CompanionState/yyyyMMdd.json）
//      - UI（表情/吹き出し色/言葉遣い）から参照可能な単純APIを提供
//
//  🔗 連動ファイル:
//      - EmotionLogRepository.swift（ユーザー感情の保存元）
//      - EmotionType.swift（感情種別の標準定義）
//      - FloatingCompanionOverlayView.swift（speak() から更新呼び出し）
//      - CompanionAvatarView.swift（表情反映）
//      - CompanionSpeechBubbleView.swift（吹き出しトーン反映）
//
//  👤 作成者: 津村 淳一
//  📅 修正日: 2025年10月23日
//

import Foundation

public struct CompanionEmotionState: Codable {
    public var joy: Double
    public var sadness: Double
    public var anger: Double
    public var surprise: Double
    public var trust: Double
    public var growthLevel: Int

    public static let initial = CompanionEmotionState(
        joy: 0, sadness: 0, anger: 0, surprise: 0, trust: 0, growthLevel: 1
    )
}

public final class CompanionEmotionManager {
    public static let shared = CompanionEmotionManager()
    
    private(set) public var state: CompanionEmotionState = .initial
    private let calendar = Calendar.current
    private let encoder = JSONEncoder()
    
    private init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        loadStateForTodayIfExists()
    }
    
    // ユーザー感情を受け取り、コンパニオンの状態を更新（内部API）
    // Public にできない内部型 EmotionType を引数に取るため、アクセスレベルは internal にする
    func update(with userEmotion: EmotionType) {
        applyEmotion(userEmotion)
        checkGrowth()
        saveStateForToday()
    }
    
    // 互換用: 文字列から更新（Public API）
    public func update(from emotionString: String) {
        let type = mapEmotionStringToType(emotionString)
        applyEmotion(type)
        checkGrowth()
        saveStateForToday()
    }
    
    // UI向け: 現在のトーン（表情/吹き出し色などのヒント）
    public var currentToneHint: String {
        if state.anger > 1.5 { return "calm_down" }
        if state.sadness > 1.5 { return "soothe" }
        if state.joy > 1.5 { return "bright" }
        if state.surprise > 1.5 { return "curious" }
        return "neutral_caring"
    }
    
    // 成長判定（単純な総合指標）
    private func checkGrowth() {
        let total = state.joy + state.trust + state.surprise - (state.anger * 0.7)
        let threshold = Double(state.growthLevel) * 5.0
        if total > threshold {
            state.growthLevel += 1
            // 成長イベント: 必要なら通知/アンロック処理をここに
        }
    }
    
    // 本日ファイルへ保存
    private func saveStateForToday() {
        let url = fileURLForToday()
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true,
                attributes: nil
            )
            let data = try encoder.encode(state)
            try data.write(to: url, options: .atomic)
        } catch {
            // 失敗時は静かにスキップ（ログ基盤があれば送る）
        }
    }
    
    // 本日ファイルを読み込み（存在すれば）
    private func loadStateForTodayIfExists() {
        let url = fileURLForToday()
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(CompanionEmotionState.self, from: data)
            self.state = decoded
        } catch {
            self.state = .initial
        }
    }
    
    private func fileURLForToday() -> URL {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "yyyyMMdd"
        let filename = formatter.string(from: Date()) + ".json"
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return doc.appendingPathComponent("CompanionState", isDirectory: true)
            .appendingPathComponent(filename)
    }
    
    // EmotionType を反映する内部処理
    private func applyEmotion(_ userEmotion: EmotionType) {
        switch userEmotion {
        case .happy, .encouraging, .gentle:
            state.joy += 0.10
            state.trust += 0.03
        case .sad:
            state.sadness += 0.10
            state.trust += 0.05
        case .angry:
            state.anger += 0.10
        case .surprised, .thinking:
            state.surprise += 0.08
        case .neutral:
            state.trust += 0.01
        default:
            state.trust += 0.01
        }
    }
    
    // 文字列を EmotionType にマップ（存在しない場合は .neutral）
    private func mapEmotionStringToType(_ s: String) -> EmotionType {
        switch s.lowercased() {
        case "happy": return .happy
        case "encouraging": return .encouraging
        case "gentle": return .gentle
        case "sad": return .sad
        case "angry": return .angry
        case "surprised": return .surprised
        case "thinking": return .thinking
        case "neutral": return .neutral
        default: return .neutral
        }
    }
    public func mapToneHintToEmotion() -> EmotionType {
        switch currentToneHint {
        case "bright": return .happy
        case "soothe": return .gentle
        case "calm_down": return .angry
        case "curious": return .surprised
        case "neutral_caring": return .neutral
        default: return .neutral
                }
            }
        }

