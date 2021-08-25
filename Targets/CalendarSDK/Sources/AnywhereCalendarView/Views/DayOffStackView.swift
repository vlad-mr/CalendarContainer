//
//  AllDayEventStackView.swift
//  AnywhereCalendarSDK
//
//  Created by Deepika on 12/08/20.
//

import UIKit

class AllDayEventStackView: CalendarHeaderStackView {
    
    override func updateView() {

        self.distribution = .fill
        if !subviews.isEmpty {
            for subview in self.subviews {
                subview.removeFromSuperview()
            }
        }
        self.alignment = .top
        for date in dates {
            let dayOffView = getAllDayView(forDate: date, shouldShowAllDayEvent: config.shouldHaveFloatingAllDayEvent, shouldShowDayOff: config.shouldHaveFloatingDayOff)
            dayOffView.setupWidthAnchor(withConstant: (contentWidth + 1))
            self.addArrangedSubview(dayOffView)
        }
    }
}
