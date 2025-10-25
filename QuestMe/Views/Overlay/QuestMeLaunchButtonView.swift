//
//  QuestMeLaunchButtonView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Overlay/QuestMeLaunchButtonView.swift
//
//  🎯 目的:
//      QuestMe の起動状態を管理する常駐ボタンビュー。
//      - 起動中は緑ライン付きで表示（右下からフェードイン）
//      - 非起動時は赤ライン付きで縮小表示（タップで起動）
//      - 長押しで終了確認ダイアログ
//      - 2回タップで CompanionExpandedView に遷移
//      - 放置5分で自動終了（非起動状態に戻る）
//      - 「常駐（5分）」ボタンで明示的に待機モードに入り、呼びかけで復帰可能
//
//  🔗 連動:
//      - CompanionExpandedView.swift（2回タップ遷移先）
//      - FloatingCompanionOverlayView.swift（.overlayで組み込み）
//      - CompanionWelcomeView.swift（初回操作説明）
//
//  👤 作成者: 津村 淳一
//  📅 改変日: 2025年10月23（常駐モードと呼びかけ復帰を追加）
//

import SwiftUI

struct QuestMeLaunchButtonView: View {
    @State private var isCompanionActive: Bool = false
    @State private var isPersistentMode: Bool = false
    @State private var showExitConfirmation: Bool = false
    @State private var showHelp: Bool = false
    @State private var tapCount: Int = 0
    @State private var lastTapTime: Date = .now
    @State private var inactivityTimer: Timer? = nil
    @State private var navigateExpanded: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationLink(destination: CompanionExpandedView(isCompanionActive: $isCompanionActive), isActive: $navigateExpanded) {
                EmptyView()
            }

            VStack(spacing: 8) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(isCompanionActive ? .green : .red)
                        .frame(width: 4)

                    Button(action: {
                        if !isCompanionActive {
                            isCompanionActive = true
                            isPersistentMode = false
                            startInactivityTimer()
                        }
                    }) {
                        Text("QuestMe")
                            .font(.headline)
                            .padding(.horizontal, isCompanionActive ? 16 : 8)
                            .padding(.vertical, isCompanionActive ? 12 : 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                }
                .scaleEffect(isCompanionActive ? 1.0 : 0.8)
                .opacity(isCompanionActive ? 1.0 : 0.6)
                .offset(x: isCompanionActive ? 0 : 40, y: isCompanionActive ? 0 : 40)
                .animation(.easeOut(duration: 0.5), value: isCompanionActive)
                .onLongPressGesture {
                    showExitConfirmation = true
                }
                .onTapGesture {
                    handleTap()
                }

                // ✅ 常駐（5分）ボタン
                Button("常駐（5分）") {
                    isCompanionActive = true
                    isPersistentMode = true
                    startInactivityTimer()
                }
                .buttonStyle(.bordered)

                // ✅ ヘルプボタン
                Button("ヘルプ") {
                    showHelp = true
                }
                .buttonStyle(.bordered)
            }
            .padding(16)
            .alert("終了しますか？", isPresented: $showExitConfirmation) {
                Button("はい", role: .destructive) {
                    isCompanionActive = false
                    stopInactivityTimer()
                }
                Button("いいえ", role: .cancel) {}
            }
            .alert("ヘルプ", isPresented: $showHelp) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("""
                QuestMeボタンは、あなた専属のAIコンパニオンを起動・最小化・拡大表示するための窓口です。

                - 赤い状態：未起動。タップで起動。
                - 緑の状態：起動中。長押しで終了確認。2回タップで拡大表示。
                - 「常駐（5分）」ボタン：最小化状態でも5分間待機。呼びかけで復帰可能。
                - 呼びかけ例：「ねぇ」「○○さん」「コンパニオン」など。
                """)
            }
            .onAppear {
                if isCompanionActive {
                    startInactivityTimer()
                }
            }
        }
    }

    // MARK: - 2回タップ判定
    private func handleTap() {
        let now = Date()
        if now.timeIntervalSince(lastTapTime) < 0.5 {
            tapCount += 1
            if tapCount >= 2 && isCompanionActive {
                navigateExpanded = true
                tapCount = 0
            }
        } else {
            tapCount = 1
        }
        lastTapTime = now
    }

    // MARK: - 放置タイマー（5分）
    private func startInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: false) { _ in
            if !isPersistentMode {
                isCompanionActive = false
            }
        }
    }

    private func stopInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }
}
