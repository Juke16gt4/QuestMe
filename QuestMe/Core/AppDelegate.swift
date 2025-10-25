//
//  AppDelegate.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/AppDelegate.swift
//
//  🎯 ファイルの目的:
//      アプリ起動時の初期化処理（Google Maps API Key の登録）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月23日
//

import UIKit
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Google Maps API Key をここで設定
        GMSServices.provideAPIKey("AIzaSyAQy7xVQF45LCOchGwahH7Ls-TZY17t9Q8")
        return true
    }
}
