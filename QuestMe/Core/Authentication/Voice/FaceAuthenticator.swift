//
//  FaceAuthenticator.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Companion/FaceAuthenticator.swift
//
//  🎯 ファイルの目的:
//      顔画像から128次元ベクトルを抽出し、CompanionProfile.faceprintData に保存・照合する。
//      - CoreMLモデル（FaceRecognitionModel.mlpackage）を使用。
//      - CompanionSetupView で登録、認証時に照合。
//      - 類似度計算により本人確認を行う。
//
//  🔗 依存:
//      - CompanionProfile.swift（faceprintData: Data?）
//      - CoreML（FaceRecognitionModel）
//      - Vision（CVPixelBuffer処理）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月11日
//

import UIKit
import CoreML
import Vision

final class FaceAuthenticator {
    
    private let model: FaceRecognitionModel
    
    init?() {
        guard let model = try? FaceRecognitionModel(configuration: MLModelConfiguration()) else {
            print("❌ モデルのロードに失敗しました")
            return nil
        }
        self.model = model
    }
    
    /// 顔画像（CVPixelBuffer）から128次元ベクトルを抽出
    func extractFaceEmbedding(from pixelBuffer: CVPixelBuffer) -> [Float]? {
        guard let resizedBuffer = resizeAndNormalize(pixelBuffer: pixelBuffer, targetSize: CGSize(width: 160, height: 160)) else {
            print("❌ 入力画像の前処理に失敗しました")
            return nil
        }
        
        guard let output = try? model.prediction(x_1: resizedBuffer) else {
            print("❌ 推論に失敗しました")
            return nil
        }
        
        let embedding = output.var_2167
        return (0..<embedding.count).map { Float(truncating: embedding[$0]) }
    }
    
    /// CompanionProfile に顔ベクトルを保存（Data形式）
    func registerFace(from pixelBuffer: CVPixelBuffer, to profile: inout CompanionProfile) {
        guard let embedding = extractFaceEmbedding(from: pixelBuffer) else {
            print("❌ 顔ベクトルの抽出に失敗しました")
            return
        }
        profile.faceprintData = Data(buffer: UnsafeBufferPointer(start: embedding, count: embedding.count))
        print("✅ 顔ベクトルを CompanionProfile に保存しました")
    }
    
    /// CompanionProfile の顔ベクトルと照合（Cosine類似度）
    func authenticateFace(from pixelBuffer: CVPixelBuffer, with profile: CompanionProfile, threshold: Float = 0.5) -> Bool {
        guard let inputEmbedding = extractFaceEmbedding(from: pixelBuffer),
              let storedData = profile.faceprintData else {
            print("❌ 顔ベクトルの照合に失敗しました")
            return false
        }
        
        let storedEmbedding = storedData.withUnsafeBytes {
            Array(UnsafeBufferPointer<Float>(start: $0.baseAddress!.assumingMemoryBound(to: Float.self),
                                             count: storedData.count / MemoryLayout<Float>.size))
        }
        
        let similarity = cosineSimilarity(inputEmbedding, storedEmbedding)
        print("🔍 類似度: \(similarity)")
        return similarity >= threshold
    }
    
    /// Cosine類似度を計算
    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        let dot = zip(a, b).map(*).reduce(0, +)
        let normA = sqrt(a.map { $0 * $0 }.reduce(0, +))
        let normB = sqrt(b.map { $0 * $0 }.reduce(0, +))
        return dot / (normA * normB)
    }
    
    /// CoreMLモデルに合わせて画像を160x160にリサイズし、RGB正規化
    private func resizeAndNormalize(pixelBuffer: CVPixelBuffer, targetSize: CGSize) -> CVPixelBuffer? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let resizedImage = ciImage.transformed(by: CGAffineTransform(scaleX: targetSize.width / CGFloat(CVPixelBufferGetWidth(pixelBuffer)),
                                                                     y: targetSize.height / CGFloat(CVPixelBufferGetHeight(pixelBuffer))))
        
        let context = CIContext()
        var outputBuffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as CFDictionary
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(targetSize.width),
                                         Int(targetSize.height),
                                         kCVPixelFormatType_32BGRA,
                                         attrs,
                                         &outputBuffer)
        
        guard status == kCVReturnSuccess, let buffer = outputBuffer else {
            return nil
        }
        
        context.render(resizedImage, to: buffer)
        return buffer
    }
}
