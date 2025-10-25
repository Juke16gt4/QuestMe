//
//  ChartImageManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Utils/ChartImageManager.swift
//
//  🎯 ファイルの目的:
//      - グラフ画像の保存パスを返す。
//      - PDFレポート生成時に EmotionTrendChartView の画像を埋め込むために使用。
//      - 将来的に複数グラフ対応可能。
//

import Foundation

final class ChartImageManager {
    static let shared = ChartImageManager()

    /// 最新の感情傾向グラフ画像パスを返す
    func latestChartPath() -> String? {
        let path = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Charts/emotion_bar_chart.png")
        return path.path
    }
}
