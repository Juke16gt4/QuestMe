//
//  CertificationDashboardTabView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Certification/CertificationDashboardTabView.swift
//
//  🎯 ファイルの目的:
//      複数資格の「ダッシュボード＋履歴」を切り替え表示する。
//      - TabViewで CertificationTabView(certificationName:) を資格ごとに表示
//

import SwiftUI

struct CertificationDashboardTabView: View {
    @State private var certificationNames: [String] = []
    @State private var selectedTab: String? = nil

    var body: some View {
        VStack {
            if certificationNames.isEmpty {
                Text("資格データが見つかりませんでした。")
                    .foregroundColor(.gray)
            } else {
                TabView(selection: $selectedTab) {
                    ForEach(certificationNames, id: \.self) { name in
                        CertificationTabView(certificationName: name)
                            .tag(name)
                            .tabItem {
                                Text(name)
                            }
                    }
                }
            }
        }
        .onAppear {
            loadCertificationFolders()
        }
    }

    private func loadCertificationFolders() {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        do {
            let folders = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
                .filter { $0.hasDirectoryPath }
            certificationNames = folders.map { $0.lastPathComponent }.sorted()
            selectedTab = certificationNames.first
        } catch {
            certificationNames = []
        }
    }
}
