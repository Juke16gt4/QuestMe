import SwiftUI
import Combine
import AVFoundation

@MainActor
class CompanionOverlay: ObservableObject {
    static let shared = CompanionOverlay()

    @Published var currentEmotion: EmotionType = .neutral
    @Published var currentMood: CompanionSpeechBubbleView.Mood = .neutral
    @Published var bubbleText: String? = nil
    @Published var profile: CompanionProfile

    private let synthesizer = AVSpeechSynthesizer()

    private init() {
        // ✅ 起動時に最後のプロフィールをロード
        self.profile = ProfileStorage.loadProfiles().first ?? CompanionProfile.defaultProfile()
    }

    // プロフィール更新
    func updateProfile(_ newProfile: CompanionProfile) {
        self.profile = newProfile
    }

    // MARK: - 発話
    func speak(_ text: String, emotion: EmotionType? = nil, delay: TimeInterval = 0) {
        if let emotion = emotion {
            self.currentEmotion = emotion
            self.currentMood = mapEmotionToMood(emotion)
        }
        self.bubbleText = text

        let utterance = AVSpeechUtterance(string: text)

        // ✅ プロフィールの音声設定を反映
        utterance.rate = {
            switch profile.voice.speed {
            case .slow: return 0.4
            case .fast: return 0.65
            default: return 0.5
            }
        }()

        utterance.pitchMultiplier = {
            switch profile.voice.tone {
            case .bright: return 1.2
            case .deep: return 0.8
            case .husky: return 0.9
            default: return 1.0
            }
        }()

        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.preUtteranceDelay = delay
        synthesizer.speak(utterance)
    }

    func showBubble(_ text: String, emotion: EmotionType? = nil) {
        if let emotion = emotion {
            self.currentEmotion = emotion
            self.currentMood = mapEmotionToMood(emotion)
        }
        self.bubbleText = text
    }

    func clearBubble() {
        self.bubbleText = nil
    }

    private func mapEmotionToMood(_ emotion: EmotionType) -> CompanionSpeechBubbleView.Mood {
        switch emotion {
        case .happy: return .happy
        case .sad: return .sad
        case .angry: return .angry
        case .neutral: return .neutral
        case .thinking: return .neutral
        case .sexy: return .happy
        case .encouraging: return .happy
        }
    }

    // MARK: - シナリオトリガー
    func greetOnLogin() {
        speak("今日も一緒にがんばろう！", emotion: .happy)
    }

    func closingAfterReview() {
        speak("レビューお疲れさま！次も一緒に振り返ろうね。", emotion: .encouraging)
    }

    func checkSpecialAchievements(logs: [EmotionLog]) {
        let recent = logs.prefix(7)
        if recent.count == 7 && recent.allSatisfy({ $0.emotion == .happy }) {
            speak("🎉 ラッキーセブン！7日連続でポジティブ記録達成！", emotion: .happy)
        }
    }
}
