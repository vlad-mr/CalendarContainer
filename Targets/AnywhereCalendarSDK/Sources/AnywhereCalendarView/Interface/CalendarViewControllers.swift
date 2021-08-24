//
//  CalendarViewControllers.swift
//  AnywhereCalendarView
//
//  Created by Vignesh on 08/07/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

struct CalendarViewControllers {
    static var calendarStoryboard: UIStoryboard {
        UIStoryboard(name: "Calendar", bundle: Bundle(for: FullCalendars.self))
    }

    static var calendarLayoutView: CalendarLayoutViewController {
        calendarStoryboard.instantiateViewController(withIdentifier: "CalendarLayoutViewController") as! CalendarLayoutViewController
    }

    public static var calendarView: CalendarViewController {
        calendarStoryboard.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
    }

    public static func getScheduleView(withConfiguration scheduleConfig: ScheduleViewConfiguration, placeholderView: ActionableView?, dimension: ScheduleViewDimensions) -> ScheduleBaseViewController {
        return ScheduleBaseViewController(withConfiguration: scheduleConfig, placeholderView: placeholderView, dimension: dimension)
    }

    static var calendarPageView: CalendarPageViewController {
        calendarStoryboard.instantiateViewController(withIdentifier: "CalendarPageViewController") as! CalendarPageViewController
    }
}

enum CalendarNibs {
    static var dateHeaderView: DateHeaderView {
        let bundle = Bundle(for: DateHeaderView.self)
        guard let headerView = bundle.loadNibNamed("CalendarDateHeaderView", owner: nil, options: nil)?[0] as? DateHeaderView else {
            preconditionFailure("Date Header cannot be initialized")
        }
        return headerView
    }
}
