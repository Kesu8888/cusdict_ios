//
//  PageViewController.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/16.
//

import Foundation
import UIKit
import SwiftUI

// <Page: View> means this struct is about View types just like List<String>
struct PageViewController<Page: View>: UIViewControllerRepresentable {
    var pages:[Page]
    @Binding var currentPage: Int
    
    // You can use this coordinator to implement common Cocoa patterns, such as delegates, data sources, and responding to user events via target-action.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let pageViewController = UIPageViewController (
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        
        return pageViewController
    }
    
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers(
            // context refers to the context that is generated in makeUIViewController
            [context.coordinator.controllers[currentPage]], direction: .forward, animated: true)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewController
        var controllers = [UIViewController]()
        
        init(_ pageViewController: PageViewController) {
            parent = pageViewController
            // map is the way to transforma an array to another type of array through transformer function
            controllers = parent.pages.map {
                UIHostingController(rootView: $0)
            }
        }
        // These two methods establish the relationships between view controllers, so that you can swipe back and forth between them.
        func pageViewController (
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if (index == 0) {
                return controllers.last
            }
            return controllers[index - 1]
        }
        
        func pageViewController (
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index + 1 == controllers.count {
                return controllers.first
            }
            return controllers[index+1]
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            if completed,
               let visibleViewController = pageViewController.viewControllers?.first,
               let index = controllers.firstIndex(of: visibleViewController) {
                parent.currentPage = index
            }
        }
    }
}
