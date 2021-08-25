//
//  MainViewController.swift
//  AnywhereCalendarSDK_Example
//
//  Created by Essence K on 19.08.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import CalendarSDK

class MainViewController: DrawerPresentableViewController {

    private lazy var scheduleViewContoller: SampleScheduleViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SampleScheduleViewController") as! SampleScheduleViewController
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton()
        button.setTitle("Menu", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 40),
            button.widthAnchor.constraint(equalToConstant: 60),
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
        ])
        button.addTarget(self, action: #selector(showDrawer), for: .touchUpInside)

        if #available(iOS 13.0, *) {
            configureHeader(image: UIImage(systemName: "house.fill"), title: "Anytime Calendar")
            setItems([
                SelectorItem(image: UIImage(named: "schedule"), title: "Schedule"),
                SelectorItem(image: UIImage(named: "day"), title: "Daily"),
                SelectorItem(image: UIImage(named: "week"), title: "Weekly"),
            ])
        }
        highlightCell(atRow: 0)
        showSchedule()
    }

    override func selectedCell(_ row: Int) {
        super.selectedCell(row)
        switch row {
        case 0:
            showSchedule()
        case 1:
            scheduleViewContoller.removeFromParent()
            scheduleViewContoller.view.removeFromSuperview()
        default:
            return
        }
    }

    override var drawerWidth: CGFloat {
        return UIScreen.main.bounds.width - 100
    }

    override var theme: DrawerTheme {
        return DefaultDrawerTheme()
    }

    private func showSchedule() {
        view.addSubview(scheduleViewContoller.view)

        addChild(scheduleViewContoller)
        scheduleViewContoller.didMove(toParent: self)
        scheduleViewContoller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scheduleViewContoller.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            scheduleViewContoller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scheduleViewContoller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scheduleViewContoller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
