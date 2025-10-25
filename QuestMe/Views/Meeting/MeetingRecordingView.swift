//
//  MeetingRecordingView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Meeting/MeetingRecordingView.swift
//
//  🎯 目的:
//      会議・講義の録音儀式ビュー。
//      - 録音開始／一時停止／停止（最大3時間、高音質）
//      - 停止後に議事録生成・Slack投稿・PDF/Markdown保存・カレンダーホルダー保存
//      - 保存完了後に録音音源を削除
//      - 位置情報＋イベント情報で録音禁止判定
//      - Companion が12言語対応で音声ガイド＋音声コマンド操作
//
//  👤 製作者: 津村 淳一
//  📅 作成日: 2025年10月18日
//

import SwiftUI
import AVFoundation
import CoreLocation

struct MeetingRecordingView: View {
    @State private var isRecording = false
    @State private var isPaused = false
    @State private var isRecordingDisabled = false
    @State private var startTime: Date?
    @State private var timer: Timer?
    @State private var recorder: AVAudioRecorder?
    @State private var showHelp = false
    
    private let maxDuration: TimeInterval = 3 * 60 * 60 // 3時間
    private let locationManager = CLLocationManager()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("🎙 会議・講義 録音儀式")
                    .font(.title2)
                    .bold()
                
                if isRecording {
                    Text(isPaused ? "⏸ 一時停止中…" : "🔴 録音中…")
                        .foregroundColor(.red)
                } else if isRecordingDisabled {
                    Text("⚠️ 現在地では録音できません")
                        .foregroundColor(.orange)
                } else {
                    Text("録音を開始してください")
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 20) {
                    Button("▶️ 開始") {
                        startRecording()
                    }
                    .disabled(isRecording || isRecordingDisabled)
                    
                    Button("⏸ 一時停止") {
                        pauseRecording()
                    }
                    .disabled(!isRecording || isPaused)
                    
                    Button("⏹ 停止") {
                        stopRecording()
                    }
                    .disabled(!isRecording)
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationTitle("🎓 録音儀式")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("❓ヘルプ") {
                        showHelp = true
                        speak(helpText(for: SpeechSync().currentLanguage))
                    }
                }
            }
            .onAppear {
                requestLocation()
                VoiceCommandListener.shared.startListening { recognizedText in
                    handleVoiceCommand(recognizedText)
                }
            }
        }
    }
    
    // MARK: - 録音制御
    
    private func startRecording() {
        guard !isRecordingDisabled else {
            speak("現在地では録音が制限されています。")
            return
        }
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ]
        
        let filename = "recording_\(Int(Date().timeIntervalSince1970)).wav"
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("会議_講義")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let fileURL = folder.appendingPathComponent(filename)
        
        do {
            recorder = try AVAudioRecorder(url: fileURL, settings: settings)
            recorder?.record()
            isRecording = true
            isPaused = false
            startTime = Date()
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
                if let start = startTime, Date().timeIntervalSince(start) >= maxDuration {
                    stopRecording()
                    speak("録音時間が3時間に達したため、自動的に停止しました。")
                    t.invalidate()
                }
            }
            
            speak("録音を開始します。最大3時間まで録音できます。")
        } catch {
            speak("録音の開始に失敗しました。")
        }
    }
    
    private func pauseRecording() {
        recorder?.pause()
        isPaused = true
        speak("録音を一時停止しました。")
    }
    
    private func stopRecording() {
        recorder?.stop()
        timer?.invalidate()
        isRecording = false
        isPaused = false
        speak("録音を終了しました。議事録を生成します。")
        onStopRecording()
    }
    
    // MARK: - 停止後の自動処理
    
    private func onStopRecording() {
        let transcript = AudioTranscriber.shared.transcribe()
        let summary = MeetingManager.shared.generateSummary(from: transcript)
        
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("会議_講義")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        
        let pdfURL = folder.appendingPathComponent("minutes.pdf")
        PDFRenderer().render(text: transcript, to: pdfURL)
        
        let markdown = MeetingManager.shared.generateMarkdownMinutes(from: transcript)
        try? markdown.write(to: folder.appendingPathComponent("minutes.md"), atomically: true, encoding: .utf8)
        
        SlackManager.shared.postMinutes(markdown: summary, channel: "#general") { _ in }
        
        CalendarSyncService().saveCalendarLog(summary: summary, filePath: pdfURL)
        
        deleteRecordingFile()
        speak("会議の記録儀式が完了しました。")
    }
    
    private func deleteRecordingFile() {
        if let url = recorder?.url, FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
            speak("録音ファイルは保存後に削除されました。")
        }
    }
    
    // MARK: - 位置情報による録音制限
    
    private func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        if let loc = locationManager.location?.coordinate {
            checkRecordingPermission(at: loc)
        }
    }
    
    private func checkRecordingPermission(at location: CLLocationCoordinate2D) {
        NearbyPlaceService.shared.fetchPlaces(around: location) { places in
            let restrictedTypes = ["映画館", "劇場", "ライブハウス", "ホール"]
            let matched = places.contains { restrictedTypes.contains($0.category) }
            
            EventService.shared.fetchEvents(near: location) { events in
                let hasActiveEvent = events.contains { $0.isOngoing }
                if matched && hasActiveEvent {
                    isRecordingDisabled = true
                    speak("現在地は録音が制限されている場所です。録音機能は使用できません。")
                }
            }
        }
    }
    
    // MARK: - 音声コマンド対応
    
    private func handleVoiceCommand(_ command: String) {
        let normalized = command.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch normalized {
        case "録音開始", "start recording":
            if !isRecording { startRecording() }
        case "一時停止", "pause recording":
            if isRecording && !isPaused { pauseRecording() }
        case "録音停止", "stop recording":
            if isRecording { stopRecording() }
        case "ヘルプ", "help":
            speak(helpText(for: SpeechSync().currentLanguage))
        default:
            speak("音声コマンドが認識されませんでした。")
        }
    }
    
    // MARK: - 多言語対応ヘルプ
    
    private func helpText(for lang: String) -> String {
        switch lang {
        case "ja":
            return "この画面では録音を開始・一時停止・停止できます。録音は最大3時間までで、高音質で保存されます。停止すると議事録が自動生成され、Slack投稿とカレンダーホルダー保存が行われ、録音ファイルは削除されます。映画館や劇場などでイベント開催中は録音できません。"
        case "en":
            return "You can start, pause, and stop recording. Up to 3 hours in high quality. Upon stopping, minutes are auto-generated, posted to Slack, saved to the calendar folder, and the audio file is deleted. Recording is disabled in cinemas, theaters, or similar venues when an event is ongoing."
        case "fr":
            return "Vous pouvez démarrer, mettre en pause et arrêter l'enregistrement. Jusqu'à 3 heures en haute qualité. À l'arrêt, le compte rendu est généré automatiquement, publié sur Slack, enregistré dans le dossier calendrier et le fichier audio est supprimé. L'enregistrement est désactivé dans les cinémas, théâtres ou lieux similaires lorsqu'un événement est en cours."
        case "de":
            return "Sie können die Aufnahme starten, pausieren und stoppen. Bis zu 3 Stunden in hoher Qualität. Beim Stoppen werden Protokolle automatisch erstellt, auf Slack gepostet, im Kalenderordner gespeichert und die Audiodatei gelöscht. In Kinos, Theatern oder ähnlichen Veranstaltungsorten mit laufenden Events ist die Aufnahme deaktiviert."
        case "es":
            return "Puede iniciar, pausar y detener la grabación. Hasta 3 horas en alta calidad. Al detenerse, se generan las actas automáticamente, se publican en Slack, se guardan en la carpeta de calendario y se elimina el archivo de audio. La grabación está deshabilitada en cines, teatros u otros lugares similares cuando hay un evento en curso."
        default:
            return "You can start, pause, and stop recording. Minutes will be auto-generated, posted to Slack, saved to the calendar folder, and the audio file deleted. Recording is disabled in cinemas, theaters, or similar venues when an event is ongoing."
        }
    }
}
