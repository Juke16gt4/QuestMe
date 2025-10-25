//
//  CertificationBlessingService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/CertificationBlessingService.swift
//
//  🎯 ファイルの目的:
//      合格祈願メッセージ生成。
//      - 達成率と残日数に応じて応援文言を返す。
//
//  🔗 連動ファイル:
//      - CertificationView.swift
//
//  👤 作成者: 津村 淳一 (Junichi Tsumura)
//  📅 作成日: 2025年10月16日
//

import Foundation

final class CertificationBlessingService {
    func blessing(for name: String, percent: Double, daysLeft: Int) -> String {
        if percent >= 80.0 {
            return "「\(name)」は達成率\(Int(percent))%。仕上げの精度を高めていこう。残り\(daysLeft)日、良い流れです。"
        } else if percent >= 50.0 {
            return "「\(name)」は達成率\(Int(percent))%。ここからが伸びしろ。残り\(daysLeft)日、毎日の積み重ねが鍵です。"
        } else {
            return "「\(name)」は達成率\(Int(percent))%。始めたあなたは強い。残り\(daysLeft)日、一緒に地道に進めよう。"
        }
    }
}
