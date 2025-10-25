//
//  DirectionsManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/Navigation/DirectionsManager.swift
//
//  🎯 目的:
//      出発地・目的地・交通手段を指定して経路を取得し、地図に描画。
//      - 徒歩・車・公共交通機関に対応
//
//  🔗 関連:
//      - GoogleMapView.swift（経路描画）
//      - SpeechSync.swift（音声案内）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import Foundation
import CoreLocation

enum TravelMode: String {
    case walking, driving, transit
}

final class DirectionsManager {
    static let shared = DirectionsManager()
    private init() {}

    private let apiKey = "AIzaSyAQy7xVQF45LCOchGwahH7Ls-TZY17t9Q8"

    func fetchRoute(from origin: CLLocationCoordinate2D,
                    to destination: CLLocationCoordinate2D,
                    mode: TravelMode,
                    completion: @escaping ([CLLocationCoordinate2D]?) -> Void) {
        let originStr = "\(origin.latitude),\(origin.longitude)"
        let destStr = "\(destination.latitude),\(destination.longitude)"
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originStr)&destination=\(destStr)&mode=\(mode.rawValue)&key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(DirectionsResponse.self, from: data)
                let points = result.routes.first?.overview_polyline.points ?? ""
                let path = decodePolyline(points)
                completion(path)
            } catch {
                completion(nil)
            }
        }.resume()
    }

    // MARK: - Polyline Decoder
    private func decodePolyline(_ encoded: String) -> [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        var index = encoded.startIndex
        var lat = 0, lng = 0

        while index < encoded.endIndex {
            var b, shift = 0, result = 0
            repeat {
                b = Int(encoded[index].asciiValue! - 63)
                result |= (b & 0x1F) << shift
                shift += 5
                index = encoded.index(after: index)
            } while b >= 0x20
            let dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
            lat += dlat

            shift = 0
            result = 0
            repeat {
                b = Int(encoded[index].asciiValue! - 63)
                result |= (b & 0x1F) << shift
                shift += 5
                index = encoded.index(after: index)
            } while b >= 0x20
            let dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
            lng += dlng

            let coord = CLLocationCoordinate2D(latitude: Double(lat) / 1e5, longitude: Double(lng) / 1e5)
            coords.append(coord)
        }

        return coords
    }
}

// MARK: - Directions API Response
struct DirectionsResponse: Codable {
    let routes: [Route]
}

struct Route: Codable {
    let overview_polyline: Polyline
}

struct Polyline: Codable {
    let points: String
}
