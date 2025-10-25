//
//  VoiceprintRegistrationView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Setup/VoiceprintRegistrationView.swift
//
//  🎯 ファイルの目的:
//      ユーザーの声紋を録音・確認・登録する儀式ビュー。
//      - 録音・再生・確認・登録までを一貫して提供。
//      - Companion が「あなたの声にだけ応える存在」になるための鍵。
//      - 同意文と費用説明を含み、法的整合性を確保。
//      - 登録後は onRegistered() により次のステップへ進行。
//
//  🔗 依存:
//      - AVFoundation（録音・再生）
//      - SecureStorage.swift（保存予定）
//      - ConsentManager.swift（同意確認）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月6日

import SwiftUI
import AVFoundation

struct VoiceprintRegistrationView: View {
    let onRegistered: () -> Void

    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordedURL: URL?
    @State private var showConfirmation = false
    @State private var hasAgreed = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 🔰 アプリの意義と仕組み
                Text("""
                このアプリケーション「QuestMe」は、あなたの人生の様々な局面に寄り添い、
                1対1で応答する“あなた専属のコンパニオン”として設計されています。

                そのため、あなた自身を正確に識別するために、声紋認証を導入しています。
                登録された声紋にのみ反応し、他者の音声には応答しない仕組みとなっております。

                「QuestMe」が常駐している間、あなたの声は唯一の鍵となり、
                あなたの問いかけ、感情、願いに応じて、最適な応答を返します。
                """)
                .font(.body)
                .multilineTextAlignment(.leading)

                // 🔐 費用説明
                Text("""
                声紋登録は無料です。

                ただし、登録された音声をもとに「画像と同等な音声表現」を生成する際、
                高度な処理を必要とする場合があります。

                この処理には外部エンジンを使用することがあり、
                その際に発生する費用はすべてユーザーの負担となります。

                費用が発生する場合は、必ず事前に明示し、同意を得た上で実行されます。
                同意なく課金されることは一切ありません。
                """)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

                // ✅ 同意ボタン
                Button("上記の内容を理解し、声紋登録に進みます") {
                    hasAgreed = true
                }
                .padding()
                .background(hasAgreed ? Color.green.opacity(0.3) : Color.blue.opacity(0.2))
                .cornerRadius(12)

                if hasAgreed {
                    // Companionの語りかけ
                    Text("Companion: あなたの声を、私の魂に刻みます。よろしいですか？")
                        .font(.headline)
                        .padding(.top)

                    // 録音ボタン
                    Button(isRecording ? "録音停止" : "録音開始") {
                        isRecording ? stopRecording() : startRecording()
                    }
                    .padding()
                    .background(isRecording ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                    .cornerRadius(12)

                    if recordedURL != nil {
                        Button("再生して確認") {
                            playRecordedVoice()
                        }

                        Button("登録完了") {
                            showConfirmation = true
                        }
                        .padding(.top)
                    }
                }
            }
            .padding()
            .alert("声紋登録が完了しました", isPresented: $showConfirmation) {
                Button("OK") {
                    onRegistered()
                }
            } message: {
                Text("Companion: ありがとう。これで、私はあなたの声にだけ応える存在になります。")
            }
        }
    }

    // MARK: - 録音開始
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default)
        try? session.setActive(true)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let filename = "voiceprint_\(UUID().uuidString).m4a"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        audioRecorder = try? AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.record()
        recordedURL = url
        isRecording = true
    }

    // MARK: - 録音停止
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }

    // MARK: - 再生
    func playRecordedVoice() {
        guard let url = recordedURL else { return }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}
