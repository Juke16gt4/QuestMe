//
//  GoogleMapView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Region/GoogleMapView.swift
//
//  🎯 ファイルの目的:
//      Google Maps（GMSMapView）をSwiftUIに統合し、検索地点表示・現在地表示・ピンタップで選択地点名を共有する。
//      - 検索文字列（住所/施設名）から座標を推定してマーカー表示。
//      - 現在地マーカーと「現在地へ移動」ボタンを有効化。
//      - マーカータップで選択地点名を親ビューへ連携。
//      - 将来の経路描画や交通手段選択に拡張可能。
//
//  🔗 関連/連動ファイル:
//      - LocationInfoView.swift（親ビュー、本ビューを埋め込む）
//      - SpeechSync.swift（検索結果の音声案内に利用可能）
//      - LocationManager.swift（現在地許可に連動）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月20日
//

import SwiftUI
import GoogleMaps

struct GoogleMapView: UIViewRepresentable {
    @Binding var searchQuery: String
    @Binding var selectedPlaceName: String?

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition(latitude: 35.0, longitude: 135.0, zoom: 12)
        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        geocode(query: q, on: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapView
        init(_ parent: GoogleMapView) { self.parent = parent }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            parent.selectedPlaceName = marker.title
            SpeechSync().speak((parent.selectedPlaceName ?? "") + " を選択しました。")
            return false
        }
    }

    // MARK: - 住所/施設名の簡易ジオコーディング
    private func geocode(query: String, on mapView: GMSMapView) {
        let geocoder = GMSGeocoder()
        geocoder.geocodeAddressString(query) { response, error in
            if let error = error {
                SpeechSync().speak("検索に失敗しました。もう一度お試しください。")
                print("Geocode error: \(error.localizedDescription)")
                return
            }
            guard let result = response?.firstResult(), let coordinate = result.coordinate else {
                SpeechSync().speak("該当する場所が見つかりませんでした。")
                return
            }
            // 既存のマーカーをクリア（簡易処理）
            mapView.clear()

            let marker = GMSMarker(position: coordinate)
            marker.title = query
            marker.map = mapView

            let cameraUpdate = GMSCameraUpdate.setTarget(coordinate, zoom: 14)
            mapView.animate(with: cameraUpdate)

            parent.selectedPlaceName = query
            SpeechSync().speak("「\(query)」を地図に表示しました。")
        }
    }
}
