//
//  BeautyAdviceEngine.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Beauty/BeautyAdviceEngine.swift
//
//  🎯 目的:
//      顔画像＋生活習慣ログ（睡眠・食事・運動）から美容アドバイス（ポジティブ提案）を生成。
//      ・誹謗中傷を避け、改善提案型のみ。
//      ・初回/最新比較時は「良くなった点」を優先提示。
//      ・明度/乾燥/赤みを暫定スコア化（0-100）。
//
//  🔗 依存:
//      - UIKit（画像処理の土台）
//      - LifestyleLinkInput（生活習慣入力構造体）
//
//  🔗 関連/連動ファイル:
//      - BeautyCaptureView.swift（撮影→解析→保存）
//      - BeautyStorageManager.swift（保存/読み込み）
//      - BeautyCompareView.swift（比較表示）
//      - BeautyHistoryView.swift（履歴表示）
//      - SleepTimerView.swift（睡眠ログ保存）
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-21

import UIKit

struct BeautyAnalysisResult: Codable {
    var brightnessScore: Double   // 明度（0-100）
    var drynessScore: Double      // 乾燥（0-100）
    var rednessScore: Double      // 赤み（0-100）
    var summary: String           // ポジティブ提案メッセージ
    var improvements: [String]    // 良くなった点
    var suggestions: [String]     // 改善提案
}

struct LifestyleLinkInput {
    var sleepHours: Double?           // 睡眠時間（時間）
    var balancedMealsRatio: Double?   // バランス良い食事比率（0-1）
    var exerciseDaysPerWeek: Int?     // 運動日数/週
}

enum BeautyAdviceCategory: String, Codable {
    case capture, compare, sleep, history
}

final class BeautyAdviceEngine {
    static let shared = BeautyAdviceEngine()

    func analyze(image: UIImage, lifestyle: LifestyleLinkInput?) -> BeautyAnalysisResult {
        let brightness = estimateBrightness(image: image)
        let dryness = estimateDryness(image: image, lifestyle: lifestyle)
        let redness = estimateRedness(image: image, lifestyle: lifestyle)

        let improvements = generateImprovements(brightness: brightness, dryness: dryness, redness: redness)
        let suggestions = generateSuggestions(brightness: brightness, dryness: dryness, redness: redness, lifestyle: lifestyle)
        let summary = composeSummary(improvements: improvements, suggestions: suggestions)

        return BeautyAnalysisResult(
            brightnessScore: brightness,
            drynessScore: dryness,
            rednessScore: redness,
            summary: summary,
            improvements: improvements,
            suggestions: suggestions
        )
    }

    private func estimateBrightness(image: UIImage) -> Double {
        return Double.random(in: 40...70) // 暫定: 画像平均輝度
    }

    private func estimateDryness(image: UIImage, lifestyle: LifestyleLinkInput?) -> Double {
        var base = Double.random(in: 30...60)
        if let sleep = lifestyle?.sleepHours, sleep < 6 { base += 10 }
        if let meals = lifestyle?.balancedMealsRatio, meals < 0.4 { base += 10 }
        return min(100, base)
    }

    private func estimateRedness(image: UIImage, lifestyle: LifestyleLinkInput?) -> Double {
        var base = Double.random(in: 20...50)
        if let exercise = lifestyle?.exerciseDaysPerWeek, exercise == 0 { base += 10 }
        return min(100, base)
    }

    private func generateImprovements(brightness: Double, dryness: Double, redness: Double) -> [String] {
        var points: [String] = []
        if brightness >= 60 { points.append("肌の明るさが増しています") }
        if dryness <= 40 { points.append("乾燥傾向が落ち着いています") }
        if redness <= 35 { points.append("赤みが控えめで落ち着いた印象です") }
        if points.isEmpty { points.append("表情が柔らかく、優しい印象です") }
        return points
    }

    private func generateSuggestions(brightness: Double, dryness: Double, redness: Double, lifestyle: LifestyleLinkInput?) -> [String] {
        var tips: [String] = []
        if dryness >= 60 { tips.append("保湿を意識しましょう。就寝前の軽い保湿ケアがおすすめです") }
        if redness >= 60 { tips.append("刺激の少ないケアに切り替え、ゆったり過ごせる時間を作りましょう") }
        if brightness < 50 { tips.append("ビタミンCを意識した食事を取り入れ、睡眠リズムを整えましょう") }

        if let sleep = lifestyle?.sleepHours, sleep < 6 {
            tips.append("昨夜の睡眠が少し短めでした。今夜は15分早めの就寝を目指しましょう")
        }
        if let meals = lifestyle?.balancedMealsRatio, meals < 0.5 {
            tips.append("今週は野菜中心のメニューを1日1回取り入れてみましょう")
        }
        if let ex = lifestyle?.exerciseDaysPerWeek, ex < 2 {
            tips.append("軽いストレッチや散歩を週2回から始めてみましょう")
        }

        if tips.isEmpty {
            tips.append("今のケアを続けていきましょう。継続が成果につながっています")
        }
        return tips
    }

    private func composeSummary(improvements: [String], suggestions: [String]) -> String {
        let pos = "良い点: " + improvements.joined(separator: "／")
        let sug = "提案: " + suggestions.joined(separator: "／")
        return pos + "。" + sug
    }
}
