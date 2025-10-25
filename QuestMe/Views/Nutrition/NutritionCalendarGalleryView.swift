//
//  NutritionCalendarGalleryView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Nutrition/NutritionCalendarGalleryView.swift
//
//  🎯 目的:
//      Calendar/年/月/食事_栄養 の写真一覧を表示し、タップで詳細へ遷移
//
//  🔗 関連/連動:
//      - NutritionDetailView.swift（詳細表示先）
//      - NutritionLocalSaveManager.swift（保存形式に準拠）
//      - NutrientDetail.swift（栄養素モデル）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月19日
//

import SwiftUI

struct NutritionCalendarGalleryView: View {
    let year: Int
    let month: Int

    @State private var entries: [URL] = []
    @State private var selectedImage: UIImage?
    @State private var selectedPayload: NutritionSnapshotPayload?
    @State private var showDetail = false

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(entries, id: \.self) { imgURL in
                    Button {
                        openDetail(imgURL: imgURL)
                    } label: {
                        if let uiimg = UIImage(contentsOfFile: imgURL.path) {
                            Image(uiImage: uiimg)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 140)
                                .clipped()
                                .cornerRadius(8)
                        } else {
                            Color.gray.frame(height: 140).cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("\(year)年 \(month)月の食事記録")
        .onAppear { loadMonth() }
        .sheet(isPresented: $showDetail) {
            if let img = selectedImage, let p = selectedPayload {
                NavigationStack {
                    NutritionDetailView(image: img, payload: p)
                }
            }
        }
    }

    private func loadMonth() {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = docs.appendingPathComponent("Calendar/\(year)年/\(month)月/食事_栄養")
        let files = (try? fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
        entries = files.filter { $0.pathExtension.lowercased() == "jpg" }
    }

    private func openDetail(imgURL: URL) {
        let jsonURL = imgURL.deletingPathExtension().appendingPathExtension("json")
        guard let img = UIImage(contentsOfFile: imgURL.path),
              let data = try? Data(contentsOf: jsonURL),
              let payload = try? JSONDecoder().decode(NutritionSnapshotPayload.self, from: data) else {
            return
        }
        selectedImage = img
        selectedPayload = payload
        showDetail = true
    }
}
