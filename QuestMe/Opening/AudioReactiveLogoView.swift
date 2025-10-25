//
//  AudioReactiveLogoView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Opening/AudioReactiveLogoView.swift
//
//  🎯 ファイルの目的:
//      フルート音の波形にリアルタイム連動したロゴ演出ビュー。
//      - AVAudioEngine により音声波形を取得し、ロゴの拡大・発光に反映。
//      - QuestMe の世界観を「音と光」で象徴的に表現。
//      - ConsentView から遷移し、冒険の扉として機能。
//      - 母国語に応じた挨拶文をTTSで再生し、終了後 onFinished を呼ぶ。
//
//  🔗 依存:
//      - OpeningConstants.swift（音声ファイル名）
//      - AVFoundation（音声処理）
//      - Combine（波形監視）
//
//  👤 製作者: 津村 淳一
//  📅 修正版: 2025年10月15日
//

import SwiftUI
import AVFoundation
import Combine

final class AudioVisualizer: ObservableObject {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?

    @Published var amplitude: CGFloat = 0.0

    init() {
        setupAudio()
    }

    private func setupAudio() {
        guard let url = Bundle.main.url(forResource: OpeningConstants.openingSoundFileName,
                                        withExtension: OpeningConstants.openingSoundExtension) else { return }
        do {
            audioFile = try AVAudioFile(forReading: url)
            engine.attach(player)
            let format = audioFile!.processingFormat
            engine.connect(player, to: engine.mainMixerNode, format: format)

            // 波形取得
            engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                self.updateAmplitude(buffer: buffer)
            }

            try engine.start()
        } catch {
            print("Audio setup error: \(error)")
        }
    }

    func play() {
        guard let file = audioFile else { return }
        player.scheduleFile(file, at: nil, completionHandler: nil)
        player.play()
    }

    private func updateAmplitude(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        let rms = sqrt((0..<frameLength).reduce(0) { $0 + pow(channelData[$1], 2) } / Float(frameLength))
        DispatchQueue.main.async {
            self.amplitude = CGFloat(min(max(rms * 20, 0), 1)) // 正規化
        }
    }
}

struct AudioReactiveLogoView: View {
    let language: LanguageOption
    let onFinished: () -> Void

    @StateObject private var visualizer = AudioVisualizer()
    @State private var hasSpoken = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                Image("questme_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .scaleEffect(1.0 + visualizer.amplitude * 0.1)
                    .shadow(color: .orange.opacity(0.5 + visualizer.amplitude * 0.5),
                            radius: 10 + visualizer.amplitude * 30)

                Text("QuestMe")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .orange.opacity(visualizer.amplitude),
                            radius: 5 + visualizer.amplitude * 15)
            }
        }
        .onAppear {
            visualizer.play()
            if !hasSpoken {
                speakLogoIntro(for: language)
                hasSpoken = true
                DispatchQueue.main.asyncAfter(deadline: .now() + OpeningConstants.logoDisplayDuration) {
                    onFinished()
                }
            }
        }
    }

    // MARK: - 母国語対応の挨拶文
    private func speakLogoIntro(for lang: LanguageOption) {
        let text: String
        switch lang.code {
        case "ja":
            text = "個人の能力を最大限磨き上げられるようAIコンパニオンがお手伝いできるような場を提供していきます。"
        default:
            text = "We will provide a space where an AI companion supports you in honing your abilities to the fullest."
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: lang.speechCode)
        utterance.rate = 0.5
        AVSpeechSynthesizer().speak(utterance)
    }
}
