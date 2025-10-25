//
//  LogoAnimatedView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Opening/LogoAnimatedView.swift
//
//  🎯 ファイルの目的:
//      フルート音とシンクロした縁取り発光＋拡大アニメーション演出。
//      - SoundManager による音再生と連動。
//      - QuestMe ロゴを神秘的に演出し、冒険の始まりを象徴。
//      - onComplete() により次の儀式へ遷移可能。
//
//  🔗 依存:
//      - SoundManager.swift（音再生）
//      - OpeningConstants.swift（タイミング）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月27日

import SwiftUI

struct LogoAnimatedView: View {
    let onComplete: () -> Void
    @State private var animateGlow = false
    @State private var animateScale = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                Image("questme_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .scaleEffect(animateScale ? 1.1 : 1.0)
                    .shadow(color: animateGlow ? .orange.opacity(0.9) : .orange.opacity(0.3),
                            radius: animateGlow ? 20 : 5)
                    .animation(.easeOut(duration: 1.5), value: animateGlow)
                    .animation(.easeOut(duration: 1.5), value: animateScale)

                Text("QuestMe")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: animateGlow ? .orange.opacity(0.8) : .clear,
                            radius: animateGlow ? 8 : 0)
            }
        }
        .onAppear {
            // フルート音再生
            SoundManager.shared.playOpeningFluteIfEnabled()
            
            // 音の余韻に合わせてアニメーション開始
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    animateGlow = true
                    animateScale = true
                }
            }
            // 元に戻す
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    animateGlow = false
                    animateScale = false
                }
            }
            // 次のステップへ
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                onComplete()
            }
        }
    }
}
