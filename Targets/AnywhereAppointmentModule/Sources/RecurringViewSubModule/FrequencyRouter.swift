//
//  FrequencyRouter.swift
//  Anytime
//
//  Created by Artem Grebinik on 24.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

protocol Router {
    associatedtype AppRoute

    func route(to destination: AppRoute, from source: UIViewController, info: Any?)
}

enum FrequencyRoute {
    case endFrequency
    case back
    case backToRoot
    case customFrequency
}

public class FrequencyRouter: Router {
    typealias AppRoute = FrequencyRoute

    public init() {}

    public static var initialViewController: FrequencyViewController {
        let frequencyViewController = FrequencyViewController()
        frequencyViewController.router = FrequencyRouter()
        return frequencyViewController
    }

    func route(to destination: FrequencyRoute, from source: UIViewController, info: Any?) {
        switch destination {
        case .back:
            source.navigationController?.popViewController(animated: true)

        case .backToRoot:
            source.navigationController?.popToRootViewController(animated: true)

        case .customFrequency:

            let fryquencyVC = CustomFryquencyViewController()
            fryquencyVC.originalRule = info as? RecurrenceRule ?? RecurrenceRule(frequency: .daily)

            fryquencyVC.router = self
            let rootVC = source.navigationController?.viewControllers.first as? FrequencyVCDelegate
            fryquencyVC.delegate = rootVC
            source.navigationController?.pushViewController(
                fryquencyVC, animated: true
            )

        case .endFrequency:

            let endReccurringViewController = EndReccurringViewController()
            endReccurringViewController.router = self
            let rootVC = source.navigationController?.viewControllers.first as? FrequencyVCDelegate
            endReccurringViewController.delegate = rootVC

            if let rule = info as? RecurrenceRule {
                endReccurringViewController.originalRule = rule
            }

            source.navigationController?.pushViewController(
                endReccurringViewController, animated: true
            )
        }
    }
}
