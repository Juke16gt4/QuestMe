//
//  NearbyPlaceService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Location/NearbyPlaceService.swift
//
//  🎯 目的:
//      現在地周辺の施設カテゴリ（映画館・劇場など）を取得し、録音制限判定に使用。
//      - CoreLocation を使用して座標を取得
//      - MapKit または外部APIで施設カテゴリを取得（ここではモック）
//
//  👤 製作者: 津村 淳一
//  📅 作成日: 2025年10月18日
//

import Foundation
import CoreLocation

struct NearbyPlace {
    let name: String
    let category: String
}

final class NearbyPlaceService {
    static let shared = NearbyPlaceService()

    func fetchPlaces(around location: CLLocationCoordinate2D, completion: @escaping ([NearbyPlace]) -> Void) {
        // ✅ モック実装（実運用では MapKit / Google Places API などと連携）
        let mockPlaces = [
            NearbyPlace(name: "益田シネマ", category: "映画館"),
            NearbyPlace(name: "島根劇場", category: "劇場"),
            NearbyPlace(name: "益田市役所", category: "公共施設")
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(mockPlaces)
        }
    }
}
