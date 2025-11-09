// Views/SignUp/Components/ImagePicker.swift
import SwiftUI
import PhotosUI

struct ImagePicker: View {
    @Binding var image: UIImage?
    @State private var item: PhotosPickerItem? = nil

    var body: some View {
        PhotosPicker("Choose Image", selection: $item, matching: .images)
            .onChange(of: item) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let ui = UIImage(data: data) {
                        image = ui
                    }
                }
            }
    }
}
