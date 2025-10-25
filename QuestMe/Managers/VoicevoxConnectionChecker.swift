//
//  VoicevoxConnectionChecker.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/VoicevoxConnectionChecker.swift
//
//  🎯 ファイルの目的:
//      VOICEVOX が起動しているかを確認するための接続チェッカー。
//      - CompanionSetupView や Voice作製画面で使用される。
//      - 接続確認後、音声生成処理に進行可能。
//      - 今後 VoicevoxManager に統合される可能性あり。
//
//  🔗 依存:
//      - URLSession（接続確認）
//      - VOICEVOX API（http://127.0.0.1:50021/speakers）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月3日

import Foundation
