//
//  VoiceGenerator.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/VoiceGenerator.swift
//
//  🎯 ファイルの目的:
//      Companion の声を AIで自動生成するためのユーティリティ。
//      - VoiceStyle・VoiceTone・VoiceSpeed に基づき、音声ファイルを生成。
//      - ファイル名に style_tone_speed を埋め込み、VoiceProfile.inferred(from:) による自動推定を可能にする。
//      - CompanionSetupView の「Voice作製」ボタンから呼び出され、generatorルートで使用される。
//      - 生成された音声は CompanionProfile に割り当て可能。
//
//  🔗 依存:
//      - AVFoundation（音声生成）
//      - VoiceStyle / VoiceTone / VoiceSpeed（音声構成）
//      - CompanionSetupView.swift（呼び出し元）
//      - CompanionStorageManager.swift（保存先）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import Foundation
import AVFoundation

final class VoiceGenerator {
    static let shared = VoiceGenerator()

    /// 音声を生成し、ファイル名に style_tone_speed を含めて保存
    func generate(style: VoiceStyle, tone: VoiceTone, speed: VoiceSpeed, completion: @escaping (URL?) -> Void) {
        let utterance = AVSpeechUtterance(string: "こんにちは、私はあなたのコンパニオンです。")
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = mapSpeedToRate(speed)

        let filename = "\(style.rawValue)_\(tone.rawValue)_\(speed.rawValue).m4a"
        let outputURL = getDocumentsDirectory().appendingPathComponent(filename)

        // ⚠️ 実際の音声ファイル生成には AVAudioEngine 等が必要（ここでは仮処理）
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // 仮に空ファイルを作成（実装者が AVAudioEngine に差し替え可能）
            try? Data().write(to: outputURL)
            DispatchQueue.main.async {
                completion(outputURL)
            }
        }
    }

    /// AVSpeechUtterance.rate に変換
    private func mapSpeedToRate(_ speed: VoiceSpeed) -> Float {
        switch speed {
        case .slow: return 0.4
        case .normal: return 0.5
        case .fast: return 0.6
        }
    }

    /// 保存先ディレクトリ
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
