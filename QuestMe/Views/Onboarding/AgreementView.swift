//
//  AgreementView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Onboarding/AgreementView.swift
//
//  🎯 ファイルの目的:
//      利用規約・プライバシーポリシー・法的同意画面を提供するオンボーディングビュー。
//      - 音声・画像利用規定、国際法、日本法、免責事項を読み上げ・表示。
//      - 同意ログをローカル保存・サーバー送信可能。
//      - VoiceprintRegistrationView へ遷移可能。
//
//  🔗 依存:
//      - AVFoundation（音声合成）
//      - VoiceprintRegistrationView.swift（遷移先）
//      - URLSession（同意ログ送信）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月3日

import SwiftUI
import AVFoundation

struct AgreementView: View {
    // MARK: - 状態管理
    @State private var currentSection = 1
    @State private var highlightedIndex: Int? = nil
    @State private var speechRate: Float = 0.5
    @State private var consentInternational = false
    @State private var consentJapan = false
    @State private var consentLiability = false
    @State private var showNextScreen = false

    // MARK: - 音声合成エンジン
    let synthesizer = AVSpeechSynthesizer()

    // MARK: - セクション本文
    let sectionTexts: [Int: [String]] = [
    
            1: [
                "第1部：音声・画像データ利用規定 + 費用負担条項",
                "アップロードされた音声は、AI解析に使用されます。",
                "画像は2MB以内で加工に使用されます。",
                "画像と同等な音声への変換費用はユーザー負担です。"
            ],
            2: [
                "第2部：国際法に基づく著作権保護",
                "ベルヌ条約、TRIPS協定、WIPO条約に準拠します。"
            ],
            3: [
                "第3部：日本国の著作権法は、著作権侵害に対して以下の刑事罰を定めています。",
                "著作権・著作隣接権の侵害：10年以下の懲役、または1000万円以下の罰金、またはその両方。",
                "著作者人格権・実演家人格権の侵害：5年以下の懲役、または500万円以下の罰金、またはその両方。",
                "違法ダウンロード：2年以下の懲役、または200万円以下の罰金、またはその両方。",
                "技術的保護手段の回避装置の提供：3年以下の懲役、または300万円以下の罰金、またはその両方。"
            ],
            4: [
                "本アプリは、ユーザーが持ち込んだ画像および生成された音声に関して、一切の法的責任を負いません。",
                "ユーザーは、画像が著作権・肖像権・商標権などを侵害していないことを十分に確認し、自己責任で利用するものとします。",
                "当アプリは、画像に対して『同等な音声』の再現を目指しています。",
                "この再現には、高度な処理を行う外部エンジンを必要とする場合があります。",
                "これらの処理にかかる費用は、すべてユーザーの負担となります。",
                "本アプリは、処理の実行前に費用の明示と同意取得を行いますが、最終的な費用負担はユーザーに帰属します。"
            ]
        ]

        // MARK: - UI本体
        var body: some View {
            NavigationStack {
                VStack {
                    // 規約リンク
                    HStack {
                        Link("利用規約", destination: URL(string: "https://example.com/terms")!)
                        Link("プライバシーポリシー", destination: URL(string: "https://privacy.microsoft.com/en-us/privacystatement")!)
                    }
                    .padding()

                    // 再生コントロール
                    HStack {
                        Button("▶️") { startSpeaking(rate: 0.5) }
                        Button("⏩") { startSpeaking(rate: 1.0) }
                        Button("⏸") { synthesizer.pauseSpeaking(at: .immediate) }
                        Button("⏮") { synthesizer.stopSpeaking(at: .immediate); startSpeaking(rate: speechRate) }
                        Button("📜") { synthesizer.stopSpeaking(at: .immediate) }
                    }
                    .padding()

                    // 本文表示
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            if let texts = sectionTexts[currentSection] {
                                ForEach(Array(texts.enumerated()), id: \.offset) { idx, line in
                                    Text(line)
                                        .font(.system(size: highlightedIndex == idx ? 22 : 16))
                                        .foregroundColor(highlightedIndex == idx ? .blue : .primary)
                                        .animation(.easeInOut, value: highlightedIndex)
                                }
                            }
                        }
                        .padding()
                    }

                    // 理解確認
                    HStack {
                        Button("理解できました") {
                            if currentSection < 4 {
                                currentSection += 1
                            } else if consentInternational && consentJapan && consentLiability {
                                showNextScreen = true
                            }
                        }
                        Button("もう一度聞き直す") {
                            startSpeaking(rate: speechRate)
                        }
                    }
                    .padding()

                    // 承諾ボタン
                    if currentSection == 2 {
                        Button("国際法に基づく著作権保護について承諾する") {
                            consentInternational = true
                            saveConsentLog(section: "International")
                        }
                    }
                    if currentSection == 3 {
                        Button("日本国の著作権法に基づく刑事罰について承諾する") {
                            consentJapan = true
                            saveConsentLog(section: "Japan")
                        }
                    }
                    if currentSection == 4 {
                        Button("免責事項と費用負担について承諾する") {
                            consentLiability = true
                            saveConsentLog(section: "Liability")
                            if consentInternational && consentJapan && consentLiability {
                                showNextScreen = true
                            }
                        }
                    }
                }
                .navigationTitle("利用規約と同意")
                .navigationDestination(isPresented: $showNextScreen) {
                    VoiceprintRegistrationView(onRegistered: {
                        // Voiceprint登録完了後の処理（例：ホーム画面へ遷移）
                        print("Voiceprint registration completed")
                    })
                }
                .onAppear {
                    SpeechDelegate.shared.onHighlight = { idx in
                        DispatchQueue.main.async {
                            self.highlightedIndex = idx
                        }
                    }
                    synthesizer.delegate = SpeechDelegate.shared
                }
            }
        }
                
    // MARK: - 読み上げ処理
        func startSpeaking(rate: Float) {
            synthesizer.stopSpeaking(at: .immediate)
            speechRate = rate
            highlightedIndex = nil

            guard let texts = sectionTexts[currentSection] else { return }

            for (idx, text) in texts.enumerated() {
                let utterance = AVSpeechUtterance(string: text)
                utterance.rate = rate
                utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
                utterance.accessibilityHint = "\(idx)"
                synthesizer.speak(utterance)
            }
        }

        // MARK: - 同意ログ保存
        func saveConsentLog(section: String, note: String? = nil) {
            let userID = "sampleUserID" // Voiceprint登録後に置き換え
            let timestamp = ISO8601DateFormatter().string(from: Date())
            print("承諾ログ: \(section) + \(userID) + \(timestamp) + 備考: \(note ?? "")")
            sendConsentLogToServer(userID: userID, section: section, timestamp: timestamp, note: note)
        }

        func sendConsentLogToServer(userID: String, section: String, timestamp: String, note: String?) {
            guard let url = URL(string: "https://yourserver.com/api/consent-log") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let payload: [String: Any] = [
                "userID": userID,
                "section": section,
                "timestamp": timestamp,
                "note": note ?? ""
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("サーバー送信エラー: \(error)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    print("サーバー送信成功: \(section) (status: \(httpResponse.statusCode))")
                }
            }.resume()
        }
    }

    // MARK: - 音声読み上げデリゲート
    class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
        static let shared = SpeechDelegate()
        var onHighlight: ((Int?) -> Void)?

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                               willSpeakRangeOfSpeechString characterRange: NSRange,
                               utterance: AVSpeechUtterance) {
            if let idxString = utterance.accessibilityHint,
               let idx = Int(idxString) {
                DispatchQueue.main.async {
                    self.onHighlight?(idx)
                }
            }
        }

        func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                               didFinish utterance: AVSpeechUtterance) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.onHighlight?(nil)
            }
        }
    }
