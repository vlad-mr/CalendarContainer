//
//  ViewController+AnytimeNavBar.swift
//  Anytime
//
//  Created by Deepika on 19/05/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

@objc protocol NavBarActionDelegate: AnyObject {
    func didTapNavBarButton()
}

extension NavBarActionDelegate where Self: UIViewController {
    func addNavBarButton(title: String) {
        let button = genericButton
        button.setTitle(title, for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }

    func setNavBarButtonEnabled(_ enable: Bool) {
        if let button = navigationItem.rightBarButtonItem?.customView as? UIButton {
            button.isEnabled = enable
        }
    }

    func setupNavBar(title: String?) {
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.frame.size.height = 50
        navBar.setBackgroundImage(UIImage.getImage(forColor: .white), for: .default)
        navigationItem.titleView = configure(UILabel()) {
            $0.font = AppDecor.Fonts.medium.withSize(15)
            $0.textAlignment = .center
            $0.text = title
        }
        if navigationController!.viewControllers.count > 1 {
            setupBackButton()
        }
    }

    private var genericButton: UIButton {
        return configure(UIButton()) {
            $0.titleLabel?.font = AppDecor.Fonts.medium.withSize(15)
            $0.setTitleColor(AppDecor.MainColors.anytimeSolidBlue, for: .normal)
            $0.setTitleColor(AppDecor.MainColors.anytimeSolidBlue.withAlphaComponent(0.7), for: .highlighted)
            $0.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .disabled)
            $0.addTarget(self, action: #selector(didTapNavBarButton), for: .touchUpInside)
        }
    }

    private func setupBackButton() {
        navigationItem.setHidesBackButton(true, animated: true)
        let backButton = UIBarButtonItem(image: AppDecor.NavBarIcons.backArrow, style: .plain,
                                         target: self, action: #selector(didTapBackButton))
        backButton.tintColor = UIColor.black.withAlphaComponent(0.5)
        navigationItem.leftBarButtonItem = backButton
    }
}

extension UIViewController {
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}
