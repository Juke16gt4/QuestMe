//
//  RegionResolver.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/Region/RegionResolver.swift
//
//  🎯 目的:
//      - 地名・住所・郵便番号・国名などから座標を取得（ジオコーディング）
//      - 座標から都道府県・市区町村名を取得（逆ジオコーディング）
//      - 現在地を取得して地図表示に活用
//
//  🔗 関連:
//      - GoogleMapView.swift（地図表示）
//      - SpeechSync.swift（音声ガイド）
//      - LocationManager.swift（現在地取得）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import Foundation
import CoreLocation

final class RegionResolver: NSObject, ObservableObject {
    static let shared = RegionResolver()
    private override init() {
        super.init()
        locationManager.delegate = self
    }

    private let apiKey = "YOUR_GOOGLE_API_KEY"
    private let locationManager = CLLocationManager()
    private var locationCompletion: ((CLLocationCoordinate2D?) -> Void)?

    // MARK: - 地名・住所 → 座標（世界対応）
    func resolveCoordinates(from address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(encoded)&key=\(apiKey)"

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
                let result = try JSONDecoder().decode(GeocodeResponse.self, from: data)
                if let location = result.results.first?.geometry.location {
                    let coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
                    completion(coordinate)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }

    // MARK: - 座標 → 地名（都道府県・市区町村）
    func resolvePlaceName(from coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinate.latitude),\(coordinate.longitude)&key=\(apiKey)"

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
                let result = try JSONDecoder().decode(GeocodeResponse.self, from: data)
                let name = result.results.first?.formatted_address
                completion(name)
            } catch {
                completion(nil)
            }
        }.resume()
    }

    // MARK: - 現在地を取得
    func requestCurrentLocation(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        locationCompletion = completion
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension RegionResolver: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = locations.first?.coordinate
        locationCompletion?(coordinate)
        locationCompletion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCompletion?(nil)
        locationCompletion = nil
    }
}

// MARK: - Geocoding Response Structures
struct GeocodeResponse: Codable {
    let results: [GeocodeResult]
}

struct GeocodeResult: Codable {
    let formatted_address: String?
    let geometry: Geometry
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: CLLocationDegrees
    let lng: CLLocationDegrees
}
