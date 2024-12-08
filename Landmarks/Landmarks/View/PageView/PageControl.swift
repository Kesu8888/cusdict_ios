//
//  PageControl.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/18.
//

import SwiftUI
import UIKit

struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Each custom UIView must have make and update funcs
    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.addTarget(
            context.coordinator,
            //#selector is used to define the method as parameter at runtime, the method must have @objc propertty wrapper
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged
        )
        
        return control
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }
    
    class Coordinator: NSObject {
        var control: PageControl
        
        init(_ control: PageControl) {
            self.control = control
        }
        
        @objc
        func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}
//#Preview {
//    PageControl()
//}
