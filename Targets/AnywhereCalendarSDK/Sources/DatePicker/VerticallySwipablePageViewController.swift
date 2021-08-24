//
//  VerticallySwipablePageViewController.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 17/03/21.
//

import UIKit

enum SwipeDirection {
    case up,down
}

protocol SwipeActionDelegate {
    
    func didSwipe(_ direction: SwipeDirection)
}

class VerticalSwipablePageViewController: UIPageViewController {
    
    var swipeActionDelegate: SwipeActionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        let velocity = gestureRecognizer.velocity(in: self.view)
        if abs(velocity.x) < abs(velocity.y) {
            handleScroll(forGestureRecognizer: gestureRecognizer)
        }
    }
    
    func removeNonActivePages() {
        guard let activeViewController = self.viewControllers?.first else {
            return
        }
        self.setViewControllers([activeViewController], direction: .forward, animated: false)
    }
    
    private func handleScroll(forGestureRecognizer gestureRecognizer: UIPanGestureRecognizer) {
        
        let translation = gestureRecognizer.translation(in: scrollView)
        
        if translation.y > 0 {
            swipeActionDelegate?.didSwipe(.down)
        } else if translation.y < 0 {
            swipeActionDelegate?.didSwipe(.up)
        }
    }
}


extension UIPageViewController {
    var scrollView: UIScrollView? {
        return view.subviews.filter { $0 is UIScrollView }.first as? UIScrollView
    }
}

