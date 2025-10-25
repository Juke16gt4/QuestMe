//
//  VoiceprintRecognitionView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Authentication/Voice/VoiceprintRecognitionView.swift
//

import SwiftUI
import AVFoundation

struct VoiceprintRecognitionView: View {
    var onAuthenticated: () -> Void

    @EnvironmentObject var locale: LocalizationManager
    @State private var isRecording = false
    @State private var isPlaying = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var recordedURL: URL?

    var body: some View {
        VStack(spacing: 16) {
            Text(locale.localized("voice_auth_title"))
                .font(.headline)

            Button(isRecording ? locale.localized("voice_record_stop") : locale.localized("voice_record_start")) {
                isRecording ? stopRecording() : startRecording()
            }

            if recordedURL != nil {
                Button(isPlaying ? locale.localized("voice_record_stop") : locale.localized("voice_playback")) {
                    isPlaying ? stopPlayback() : playRecording()
                }

                Button(locale.localized("voice_verify_button")) {
                    verifyVoiceprint()
                }
            }
        }
        .padding()
    }

    private func startRecording() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            recordedURL = url
            isRecording = true
        } catch {
            print("録音失敗: \(error)")
        }
    }

    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }

    private func playRecording() {
        guard let url = recordedURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("再生失敗: \(error)")
        }
    }

    private func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
    }

    private func verifyVoiceprint() {
        guard let url = recordedURL,
              let audioData = try? Data(contentsOf: url),
              let storedHash = ProfileStorage.loadProfiles().first?.voiceprintHash else {
            return
        }

        if VoiceprintAuthenticator.verify(audioData, against: storedHash) {
            let success = locale.localized("voice_auth_success")
            print("✅ \(success)")
            speak(success)
            onAuthenticated()
        } else {
            let fail = locale.localized("voice_auth_fail")
            print("❌ \(fail)")
            speak(fail)
        }
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: locale.speechCode())
        utterance.rate = 0.5
        AVSpeechSynthesizer().speak(utterance)
    }
}
