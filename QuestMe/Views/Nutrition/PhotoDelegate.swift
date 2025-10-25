//
//  PhotoDelegate.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Nutrition/PhotoDelegate.swift
//
//  🎯 ファイルの目的:
//      AVCapturePhotoOutput の撮影完了イベントを UIImage に変換してハンドラに渡す
//
//  🔗 連動:
//      - NutritionCameraRecordView.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-23 13:20 JST
//

import Foundation
import AVFoundation
import UIKit

final class PhotoDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let handler: (UIImage) -> Void
    init(handler: @escaping (UIImage) -> Void) { self.handler = handler }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil else { return }
        if let data = photo.fileDataRepresentation(),
           let image = UIImage(data: data) {
            handler(image)
        }
    }
}
