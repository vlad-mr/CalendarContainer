//
//  MBProgressHUD+Extension.swift
//  EventViewSDK
//
//  Created by Artem Grebinik on 10.08.2021.
//

import UIKit
import MBProgressHUD

extension MBProgressHUD {
    
    // userInteraction false --> view can be interactable
    
    var tapGestureRecognizer: UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(hudTapped))
    }
    
    func setupHUD(delay: TimeInterval = 0) {
        self.removeFromSuperViewOnHide = false
        self.dimBackground = false
        self.detailsLabel.font = self.label.font
        
        self.accessibilityLabel = "progressHUD"
    }
    
    func setDelay(delay: TimeInterval, tapToClose: Bool) {
        
        self.removeGestureRecognizer(tapGestureRecognizer)
        
        // for alerts
        if delay > 0 {
            
            DispatchQueue.main.async {[weak self] in
                guard let `self` = self else { return }
                self.hide(animated: true, afterDelay: delay)
            }
            
            self.isUserInteractionEnabled = true
            
            self.addGestureRecognizer(tapGestureRecognizer)
            
        } else { // for Loaders
            
            if tapToClose {
                self.isUserInteractionEnabled = false // for bottom loader
            } else {
                self.isUserInteractionEnabled = true // Normal loader
            }
        }
    }
    
    func showLoader(msg: String, detailMsg: String = "", mode: MBProgressHUDMode = .indeterminate, delay: TimeInterval = 0) {
        
        setupHUD()
        
        setText(msg: msg, detailMsg: detailMsg)
        self.mode = mode
        
        self.show(animated: true)
        
        setDelay(delay: delay, tapToClose: false)
    }
    
    func setText(msg: String, detailMsg: String = "") {
        self.label.text = msg
        self.detailsLabel.text = detailMsg
    }
    
    func showText(msg: String, detailMsg: String = "", duration: TimeInterval = 0) {
        
        setupHUD()
        self.mode = .text
        
        setText(msg: msg, detailMsg: detailMsg)
        self.show(animated: true)
        
        setDelay(delay: duration, tapToClose: false)
    }
    
    func hideHud() {
        
        if !self.isHidden {
            self.hide(animated: true)
        }
    }
    
    @objc
    func hudTapped() {
        if !self.isHidden {
            self.hide(animated: true)
        }
    }
}

