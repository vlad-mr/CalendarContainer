//
//  UIViewController+Extension.swift
//  EventViewSDK
//
//  Created by Artem Grebinik on 10.08.2021.
//

import UIKit
import MBProgressHUD

extension UIViewController {
    
    public func getAlertHud(srcView: UIView) -> MBProgressHUD {
        
        let hud = MBProgressHUD(view: srcView)
        //Force Unwrapping - assuming hud will not be nil
        srcView.addSubview(hud)
        hud.bezelView.color = UIColor(red: 53, green: 63, blue: 77, alpha: 1)
        hud.bezelView.backgroundColor = .black
        hud.contentColor = .white
        hud.label.textColor = .white
        return hud
    }
}

extension UIViewController {
    func embedViewController(_ viewController: UIViewController, toContainerView containerView: UIView) {
        
        self.addChild(viewController)
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    func getKeyboardHeight(fromNotification notification: Notification) -> CGFloat {
        
        guard let userInfo = notification.userInfo, let rect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return 0
        }
        
        return self.view.convert(rect, from: nil).height
    }
    
    func getKeyboardTransitionDuration(fromNotification notification: Notification) -> TimeInterval {
        
        guard let userInfo = notification.userInfo, let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return 0
        }
        
        return duration
    }
}

extension UIAlertController {
    convenience init(inputData: UIAlertControllerCommonInputData) {
        self.init(title: inputData.title, message: inputData.message, preferredStyle: .actionSheet)
        inputData.buttons
            .map { $0.getAlertAction() }
            .forEach { self.addAction($0) }
    }
}

struct UIAlertControllerCommonInputData {
    let title: String
    let message: String
    let buttons: [Button]
    
    struct Button {
        let title: String
        let action: (() -> Void)?
       
        func getAlertAction() -> UIAlertAction {
            return UIAlertAction(title: self.title, style: .default, handler: { _ in self.action?() })
        }
    }
}

extension UIViewController {
    
    func showDeletionAlert(with inputData: UIAlertControllerCommonInputData) {
        let alert = UIAlertController(inputData: inputData)
        self.present(alert, animated: true, completion: nil)
    }

    func showDeletionAlert(forItem item: String, deletionAction: @escaping () -> Void) {
        let deleteActionController: UIAlertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let message = NSMutableAttributedString(string: "Are you sure you want to delete this \(item)?", attributes: [ .font: AppDecor.Fonts.medium.withSize(15)])
        deleteActionController.setValue(message, forKey: "attributedMessage")
        
        deleteActionController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            deletionAction()
        }))
        
        deleteActionController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(deleteActionController, animated: true, completion: nil)
    }
    
    func showDiscardChangesAlert(discardChanges: @escaping () -> Void) {
        
        let discardAlertController: UIAlertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let message = NSMutableAttributedString(string: "Your changes will be discarded. Would you like to continue?", attributes: [ .font: AppDecor.Fonts.medium.withSize(15)])
        discardAlertController.setValue(message, forKey: "attributedMessage")
        
        discardAlertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            discardChanges()
        }))
        discardAlertController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(discardAlertController, animated: true, completion: nil)
    }
}
