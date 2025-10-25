//
//  CompanionVoiceSynthesizer.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/Generator/CompanionVoiceSynthesizer.swift
//
//  🎯 ファイルの目的:
//      VoiceProfile に基づき TTS サンプル音声を生成し、データを返す。
//      - プリセット/自由入力どちらにも対応
//      - 実TTSは差し替え前提のダミー実装（将来拡張）
//
//  🔗 依存:
//      - VoiceProfile.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月11日
//

import Foundation

public enum CompanionVoiceSynthesizer {
    // 実際はTTSエンジンに差し替え。今は空データのwav相当を返すダミー。
    public static func generate(for profile: VoiceProfile) -> Data {
        // ダミーのPCM相当データ（空）
        return Data()
    }
}
