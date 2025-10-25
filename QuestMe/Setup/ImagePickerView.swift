//
//  ImagePickerView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Setup/ImagePickerView.swift
//
//  🎯 ファイルの目的:
//      ユーザーが持ち込んだ画像を選択するためのビュー。
//      - UIKit の UIImagePickerController を SwiftUI でラップ。
//      - コンパニオン登録ルート②（持ち込み型）専用の画像選択機能。
//      - 選択された画像はローカル保存され、外部送信は一切行われない。
//      - 画像選択時点で、外見として使用することへの同意が成立する設計。
//
//  🔗 依存:
//      - UIKit（UIImagePickerController）
//      - SwiftUI（UIViewControllerRepresentable）
//      - CompanionSetupView.swift（持ち込み型ルート）
//      - @Binding var selectedImage（選択画像）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月3日

import SwiftUI
import UIKit

/// ユーザーが持ち込んだ画像を選択するためのビュー。
/// UIImagePickerController を SwiftUI でラップし、ルート②専用の画像選択機能を提供する。
struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    // UIKitのデリゲート処理を担当するCoordinator
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // 動的更新は不要
    }
}
