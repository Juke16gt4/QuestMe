//
//  SoundManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Sound/SoundManager.swift
//
//  🎯 ファイルの目的:
//      起動サウンド（フルート）再生と音量/有効設定の管理。
//      - OpeningConstants に定義された音声ファイルを再生。
//      - UserDefaults により音声再生の有効/無効を記録。
//      - AudioReactiveLogoView や LogoAnimatedView から呼び出される。
//
//  🔗 依存:
//      - AVFoundation（音声再生）
//      - OpeningConstants.swift（音声ファイル名・音量）
//      - UserDefaults（設定保存）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月27日

import Foundation
import AVFoundation

final class SoundManager: NSObject {
    static let shared = SoundManager()

    private var player: AVAudioPlayer?
    private let soundEnabledKey = "questme.sound.enabled"

    var isSoundEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: soundEnabledKey) == nil {
                UserDefaults.standard.set(true, forKey: soundEnabledKey)
            }
            return UserDefaults.standard.bool(forKey: soundEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: soundEnabledKey)
        }
    }

    func playOpeningFluteIfEnabled() {
        guard isSoundEnabled else { return }
        playOpeningFlute()
    }

    func playOpeningFlute() {
        guard let url = Bundle.main.url(forResource: OpeningConstants.openingSoundFileName,
                                        withExtension: OpeningConstants.openingSoundExtension) else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = OpeningConstants.openingSoundDefaultVolume
            player?.prepareToPlay()
            player?.setVolume(OpeningConstants.openingSoundDefaultVolume, fadeDuration: 0.5)
            player?.play()
        } catch {
            NSLog("Flute sound playback error: \(error.localizedDescription)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }
}
