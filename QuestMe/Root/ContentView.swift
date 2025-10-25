//
//  ContentView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Root/ContentView.swift
//
//  🎯 ファイルの目的:
//      アプリ起動時のルートビュー。
//      - OnboardingStep に従って画面を切り替え、ユーザーを順に導く。
//        ① 言語選択 → ② 規約同意 → ③ 音声登録 → ④ コンパニオン利用。
//      - 各ステップ完了時に currentStep を更新し、次の儀式へ進行。
//      - 将来的には ViewModel に分離し、状態保存や復帰に対応予定。
//
//  🔗 依存:
//      - OnboardingStep.swift（状態管理）
//      - LanguageSetupView.swift（言語選択）
//      - AgreementView.swift（規約同意）
//      - VoiceprintRegistrationView.swift（声紋登録）
//      - CompanionView.swift（利用開始）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import SwiftUI

struct ContentView: View {
    @State private var currentStep: OnboardingStep = .languageSelection

    var body: some View {
        NavigationStack {
            switch currentStep {
            case .languageSelection:
                LanguageSetupView(onComplete: {
                    currentStep = .agreement
                })
            case .agreement:
                // AgreementView は引数を取らないため、直接呼び出す
                AgreementView()
                    .onDisappear {
                        // 同意完了後に次のステップへ進む
                        currentStep = .voiceprintRegistration
                    }
            case .voiceprintRegistration:
                VoiceprintRegistrationView(onRegistered: {
                    currentStep = .companionSession
                })
            case .companionSession:
                CompanionView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
