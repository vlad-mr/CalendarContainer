//
//  CalendarConstants.swift
//  AnywhereCalendarView
//
//  Created by Deepika on 19/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

public struct ScheduleViewDimensions {
    let cellHeight: CGFloat
    let dateHeaderWidth: CGFloat
    let dateHeaderHeight: CGFloat

    public init(cellHeight: CGFloat = 88, dateHeaderWidth: CGFloat = 70, dateHeaderHeight: CGFloat = 35) {
        self.cellHeight = cellHeight
        self.dateHeaderWidth = dateHeaderWidth
        self.dateHeaderHeight = dateHeaderHeight
    }
}

public struct CalendarDimensions {
    var timeHeaderWidth: CGFloat = 56
    var dateHeaderHeight: CGFloat = 80
    var dayOffViewHeight: CGFloat = 10
    var allDayEventHeight: CGFloat = 50
}

public extension CalendarDimensions {
    static var defaultDimensions: Self {
        return CalendarDimensions()
    }
}
