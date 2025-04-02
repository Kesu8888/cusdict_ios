//
//  Untitled.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/2/23.
//

import SwiftUI
import PhotosUI

@MainActor
class ImagePicker: ObservableObject {
    @Published var image: UIImage?
    @Published var imageSelection: PhotosPickerItem? {
        didSet {
            if let imageSelection {
                Task {
                    try await loadTransferable(from: imageSelection)
                }
            }
        }
    }
    
    func loadTransferable(from imageSelections: PhotosPickerItem?) async throws {
        do {
            if let data = try await imageSelection?.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    self.image = uiImage
                }
            }
        } catch {
            print(error.localizedDescription)
            image = nil
        }
    }
}
