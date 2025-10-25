//
//  VoicePickerView.swift
//  QuestMe
//
//  作成者: 津村淳一
//  作成日: 2025年10月3日
//
//  📂 格納場所:
//      QuestMe/Companion/Setup/VoicePickerView.swift
//
//  🎯 ファイルの目的:
//      ユーザーが持ち込んだ音声ファイル（m4a, wav など）を選択するためのビュー。
//      UIDocumentPickerViewController を SwiftUI でラップし、
//      コンパニオン登録ルート②（持ち込み型）専用の音声選択機能を提供する。
//
//  🛡️ 使用場面:
//      CompanionSetupView にて、ユーザーが「持ち込み型」を選択した場合のみ表示される。
//      初回登録（AI生成型）では使用されない。
//      選択された音声はローカル保存され、外部送信は一切行われない。
//
//  ⚠️ 法的注意:
//      ユーザーが音声ファイルを選択した時点で、コンパニオンの声として使用することに同意したものとみなす。
//      本ビューは、ユーザーの明示的な操作によってのみ起動される。
//
import SwiftUI
import UniformTypeIdentifiers

/// ユーザーが持ち込んだ音声ファイルを選択するためのビュー。
/// UIDocumentPickerViewController を SwiftUI でラップし、ルート②専用の音声選択機能を提供する。
struct VoicePickerView: UIViewControllerRepresentable {
    @Binding var selectedVoiceURL: URL?
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: VoicePickerView

        init(_ parent: VoicePickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.selectedVoiceURL = url
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let types = [UTType.audio]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // 動的更新は不要
    }
}
