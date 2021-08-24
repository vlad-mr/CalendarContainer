//
//  CalendarHeaderButton.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 03/08/20.
//
import UIKit
public class CalendarHeaderButton: UIButton {
    @IBInspectable var actionIdentifier: String = "NoActionProvided"

    public init(withFrame frame: CGRect, actionIdentifier: String) {
        self.actionIdentifier = actionIdentifier
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        actionIdentifier = "NoActionProvided"
        super.init(frame: frame)
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview is ConfigurableView {
            addTarget(self, action: #selector(executeActionForButton), for: .touchUpInside)
        }
    }

    @objc func executeActionForButton() {
        guard let superView = superview as? ConfigurableView else {
            return
        }
        superView.actionDelegate?.executeAction(withIdentifier: actionIdentifier, at: superView.section)
    }
}
