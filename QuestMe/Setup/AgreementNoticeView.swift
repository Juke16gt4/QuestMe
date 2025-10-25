//
//  AgreementNoticeView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Setup/AgreementNoticeView.swift
//
//  🎯 ファイルの目的:
//      オリジナルAIコンパニオン生成時に表示される説明文と法的同意文を提供するビュー。
//      - 故人を偲ぶ目的で画像・音声を持ち込む際、著作権・肖像権・費用負担に関する同意を明示的に取得。
//      - 同意チェックが完了した場合のみ、生成処理を開始可能。
//      - 外部接続（VOICEVOX）や費用発生の可能性があるため、事前同意が必須。
//
//  🔗 依存:
//      - CompanionSetupView.swift（ルート②：持ち込み型）
//      - @Binding var agreed（同意状態）
//      - @Binding var proceed（進行状態）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月3日

import SwiftUI

struct AgreementNoticeView: View {
    @Binding var agreed: Bool
    @Binding var proceed: Bool
    @State private var showAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("オリジナルAIコンパニオンについて")
                    .font(.title2)
                    .bold()

                Text("""
このオリジナルAIコンパニオンは、故人を偲ぶための存在です。  
あなたの記憶と想いをもとに、いつまでも寄り添い続けることができるよう設計されています。  
声・表情・ふるまいを通じて、あなたの心に寄り添う存在として、静かに共に歩みます。  
その生成は、あなたの意志と記憶に基づく、深い対話の始まりです。
""")

                Divider()

                Text("⚠️ ご注意ください")
                    .font(.headline)

                Group {
                    Text("【第3部：日本国の著作権法に基づく刑事罰】")
                        .bold()
                    Text("""
- 著作権・著作隣接権の侵害：10年以下の懲役、または1000万円以下の罰金、またはその両方  
- 著作者人格権・実演家人格権の侵害：5年以下の懲役、または500万円以下の罰金、またはその両方  
- 違法ダウンロード：2年以下の懲役、または200万円以下の罰金、またはその両方  
- 技術的保護手段の回避装置の提供：3年以下の懲役、または300万円以下の罰金、またはその両方
""")
                }

                Group {
                    Text("【第4部：本アプリの法的立場と費用負担】")
                        .bold()
                    Text("""
- 本アプリは、ユーザーが持ち込んだ画像および生成された音声に関して、一切の法的責任を負いません  
- ユーザーは、画像が著作権・肖像権・商標権などを侵害していないことを十分に確認し、自己責任で利用するものとします  
- 当アプリは、画像に対して「同等な音声」の再現を目指しています  
- この再現には、高度な処理を行う外部エンジンを必要とする場合があります  
- これらの処理にかかる費用は、すべてユーザーの負担となります  
- 本アプリは、処理の実行前に費用の明示と同意取得を行いますが、最終的な費用負担はユーザーに帰属します
""")
                }

                Toggle("上記の内容に同意します", isOn: $agreed)
                    .padding(.top)

                Button("オリジナルAIコンパニオンを生成する") {
                    if agreed {
                        proceed = true
                    } else {
                        showAlert = true
                    }
                }
                .padding()
                .background(agreed ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                .cornerRadius(12)

                if showAlert {
                    Text("⚠️ 同意が必要です。生成を開始するには、上記の内容に同意してください。")
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            .padding()
        }
    }
}
