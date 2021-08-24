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
        self.actionIdentifier = "NoActionProvided"
        super.init(frame: frame)
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview is ConfigurableView {
            self.addTarget(self, action: #selector(executeActionForButton), for: .touchUpInside)
        }
    }
    
    @objc func executeActionForButton() {
        guard let superView = self.superview as? ConfigurableView else {
            return
        }
        superView.actionDelegate?.executeAction(withIdentifier: self.actionIdentifier, at: superView.section)
    }
}
