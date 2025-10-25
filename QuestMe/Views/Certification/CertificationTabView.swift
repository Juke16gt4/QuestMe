//
//  CertificationTabView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Certification/CertificationTabView.swift
//
//  🎯 ファイルの目的:
//      資格ごとの「ダッシュボード」「履歴」を切り替え表示する。
//      - TabViewで DashboardView と CertificationHistoryView を統合
//

import SwiftUI

struct CertificationTabView: View {
    let certificationName: String

    var body: some View {
        TabView {
            DashboardView(certificationName: certificationName)
                .tabItem {
                    Label("ダッシュボード", systemImage: "chart.bar.xaxis")
                }

            CertificationHistoryView(certificationName: certificationName)
                .tabItem {
                    Label("履歴", systemImage: "book.closed")
                }
        }
    }
}
