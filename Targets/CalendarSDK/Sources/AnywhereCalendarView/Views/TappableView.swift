//
//  CalendarButton.swift
//  AnywhereCalendarSDK
//
//  Created by Deepika on 25/08/20.
//

import UIKit

open class TappableView: UIView, Tappable {
    
    
    open var action: (() -> Void)? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public override func awakeFromNib() {
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    @objc func didTap() {
        action?()
    }
}
