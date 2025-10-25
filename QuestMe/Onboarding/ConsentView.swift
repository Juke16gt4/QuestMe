//
//  ConsentView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Onboarding/ConsentView.swift
//
//  🎯 ファイルの目的:
//      利用規約・プライバシーポリシーへの同意を取得する「契約の儀式」画面。
//      - 同意後は AudioReactiveLogoView（冒険の扉）へ遷移。
//      - 同意状態は UserDefaults に保存され、次回起動時はスキップ可能。
//      - Companion の人格生成や声紋登録前の法的基盤を担う。
//
//  🔗 依存:
//      - AudioReactiveLogoView.swift（遷移先）
//      - UserDefaults（同意状態保存）
//      - ConsentManager.swift（同意状態管理）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月27日

import SwiftUI
import Combine

struct ConsentView: View {
    @State private var navigateToLogo = false

    var body: some View {
        VStack(spacing: 24) {
            Text("利用規約とプライバシーポリシー")
                .font(.title2)
                .bold()

            ScrollView {
                Text("ここに利用規約やプライバシーポリシーの要約、または全文へのリンクを表示...")
                    .padding()
            }
            .frame(height: 200)

            Button(action: {
                UserDefaults.standard.set(true, forKey: "UserAgreedToTerms")
                navigateToLogo = true
            }) {
                Text("同意する")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
        .navigationDestination(isPresented: $navigateToLogo) {
            AudioReactiveLogoView()
        }
    }
}
