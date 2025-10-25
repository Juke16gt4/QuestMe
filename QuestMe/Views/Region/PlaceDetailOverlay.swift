//
//  PlaceDetailOverlay.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Region/PlaceDetailOverlay.swift
//
//  🎯 目的:
//      地図上の地点に対して、感想と写真を記録し EmotionLogRepository に保存。
//      - 感想 → text に保存
//      - 写真 → metadata["imageBase64"] に保存
//
//  🔗 関連:
//      - EmotionLogRepository.swift
//      - GoogleMapView.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import SwiftUI
import CoreLocation
import PhotosUI

struct PlaceDetailOverlay: View {
    let placeName: String
    let coordinate: CLLocationCoordinate2D

    @State private var comment: String = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?

    var body: some View {
        VStack(spacing: 12) {
            Text(placeName)
                .font(.title2)
                .bold()

            Text("緯度: \(coordinate.latitude), 経度: \(coordinate.longitude)")
                .font(.caption)

            TextField("この場所の感想を入力", text: $comment)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            PhotosPicker(selection: $selectedImage, matching: .images) {
                Text("写真を選択")
            }

            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(8)
            }

            Button("保存") {
                var metadata: [String: Any] = [
                    "type": "place",
                    "placeName": placeName,
                    "latitude": coordinate.latitude,
                    "longitude": coordinate.longitude
                ]

                if let imageData {
                    let base64 = imageData.base64EncodedString()
                    metadata["imageBase64"] = base64
                }

                EmotionLogRepository.shared.saveLog(
                    text: comment.isEmpty ? "地点「\(placeName)」を記録" : comment,
                    emotion: .neutral,
                    ritual: "place_record",
                    metadata: metadata
                )

                SpeechSync().speak("「\(placeName)」の記録を保存しました")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onChange(of: selectedImage) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }
}
