//
//  MBProgressHUD+Extension.swift
//  EventViewSDK
//
//  Created by Artem Grebinik on 10.08.2021.
//

import MBProgressHUD
import UIKit

extension MBProgressHUD {
    // userInteraction false --> view can be interactable

    var tapGestureRecognizer: UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(hudTapped))
    }

    func setupHUD(delay _: TimeInterval = 0) {
        removeFromSuperViewOnHide = false
        dimBackground = false
        detailsLabel.font = label.font

        accessibilityLabel = "progressHUD"
    }

    func setDelay(delay: TimeInterval, tapToClose: Bool) {
        removeGestureRecognizer(tapGestureRecognizer)

        // for alerts
        if delay > 0 {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.hide(animated: true, afterDelay: delay)
            }

            isUserInteractionEnabled = true

            addGestureRecognizer(tapGestureRecognizer)

        } else { // for Loaders
            if tapToClose {
                isUserInteractionEnabled = false // for bottom loader
            } else {
                isUserInteractionEnabled = true // Normal loader
            }
        }
    }

    func showLoader(msg: String, detailMsg: String = "", mode: MBProgressHUDMode = .indeterminate, delay: TimeInterval = 0) {
        setupHUD()

        setText(msg: msg, detailMsg: detailMsg)
        self.mode = mode

        show(animated: true)

        setDelay(delay: delay, tapToClose: false)
    }

    func setText(msg: String, detailMsg: String = "") {
        label.text = msg
        detailsLabel.text = detailMsg
    }

    func showText(msg: String, detailMsg: String = "", duration: TimeInterval = 0) {
        setupHUD()
        mode = .text

        setText(msg: msg, detailMsg: detailMsg)
        show(animated: true)

        setDelay(delay: duration, tapToClose: false)
    }

    func hideHud() {
        if !isHidden {
            hide(animated: true)
        }
    }

    @objc
    func hudTapped() {
        if !isHidden {
            hide(animated: true)
        }
    }
}
