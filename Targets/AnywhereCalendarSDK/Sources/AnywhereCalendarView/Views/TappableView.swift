//
//  CalendarButton.swift
//  AnywhereCalendarSDK
//
//  Created by Deepika on 25/08/20.
//

import UIKit

open class TappableView: UIView, Tappable {
    open var action: (() -> Void)?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override public func awakeFromNib() {
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }

    @objc func didTap() {
        action?()
    }
}
