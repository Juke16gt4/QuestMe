//
//  RadarChartView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Certification/RadarChartView.swift
//
//  🎯 ファイルの目的:
//      タグごとの正答率（TagStat.correctRate）をレーダーチャート風に可視化。
//      - SwiftUIのShape/Pathで多角形描画。
//      - 各軸にTagStat.nameを配置。
//
//  🔗 連動ファイル:
//      - Core/Model/TagStat.swift
//
//  👤 作成者: 津村 淳一 (Junichi Tsumura)
//  📅 作成日: 2025年10月16日
//

import SwiftUI

struct RadarChartView: View {
    let stats: [TagStat]

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = size / 2 * 0.8
            let count = stats.count

            ZStack {
                ForEach(1..<6) { step in
                    let r = radius * CGFloat(step) / 5
                    PolygonShape(sides: count, radius: r, center: center)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }

                PolygonPath(stats: stats, radius: radius, center: center)
                    .fill(Color.blue.opacity(0.3))
                PolygonPath(stats: stats, radius: radius, center: center)
                    .stroke(Color.blue, lineWidth: 2)

                ForEach(0..<count, id: \.self) { i in
                    let angle = Double(i) / Double(count) * 2 * Double.pi - Double.pi / 2
                    let labelRadius = radius * 1.1
                    let x = center.x + CGFloat(cos(angle)) * labelRadius
                    let y = center.y + CGFloat(sin(angle)) * labelRadius
                    Text(stats[i].name)
                        .font(.caption2)
                        .position(x: x, y: y)
                }
            }
        }
    }
}

struct PolygonShape: Shape {
    let sides: Int
    let radius: CGFloat
    let center: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard sides > 2 else { return path }
        for i in 0..<sides {
            let angle = Double(i) / Double(sides) * 2 * Double.pi - Double.pi / 2
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}

struct PolygonPath: Shape {
    let stats: [TagStat]
    let radius: CGFloat
    let center: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let count = stats.count
        guard count > 2 else { return path }
        for i in 0..<count {
            let rate = stats[i].correctRate / 100.0
            let r = radius * CGFloat(rate)
            let angle = Double(i) / Double(count) * 2 * Double.pi - Double.pi / 2
            let x = center.x + CGFloat(cos(angle)) * r
            let y = center.y + CGFloat(sin(angle)) * r
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}
