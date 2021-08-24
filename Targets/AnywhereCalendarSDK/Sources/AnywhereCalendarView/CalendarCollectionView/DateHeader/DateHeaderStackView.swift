//
//  DateHeaderView.swift
//  Anytime
//
//  Created by Vignesh on 25/04/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

class DateHeaderStackView: CalendarHeaderStackView {
    private func getHeaderView(forDate date: Date) -> UIView {
        let stackView = getAllDayView(forDate: date, shouldShowAllDayEvent: !config.shouldHaveFloatingAllDayEvent, shouldShowDayOff: !config.shouldHaveFloatingDayOff)
        if stackView.subviews.isNotEmpty {
            stackView.setupHeightAnchor(withConstant: customizationProvider?.getDateHeaderHeight(forDate: date) ?? 0)
        }
        alignment = .top
        if config.shouldShowDateHeader {
            stackView.insertArrangedSubview(getDateHeaderView(forDate: date), at: 0)
        }
        stackView.setupWidthAnchor(withConstant: contentWidth, priority: .required)
        return stackView
    }

    private func getDateHeaderView(forDate date: Date) -> ConfigurableDateHeader {
        let headerView: ConfigurableDateHeader
        if let customHeader = customizationProvider?.getHeaderView(forDate: date) {
            headerView = customHeader
        } else {
            headerView = CalendarNibs.dateHeaderView
        }

        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.setupHeightAnchor(withConstant: calendarDimensions.dateHeaderHeight)
        let section: Int = dates.firstIndex(of: date) ?? 0
        headerView.section = section
        headerView.actionDelegate = actionDelegate
        headerView.configure(date, at: section)
        return headerView
    }

    override func updateView() {
        if !subviews.isEmpty {
            for subview in subviews {
                subview.removeFromSuperview()
            }
        }

        distribution = .fill
        for date in dates {
            let dateHeader = getHeaderView(forDate: date)
            addArrangedSubview(dateHeader)
        }

        if config.shouldShowDateHeaderSeparator {
            addVerticalSeparators(color: AnywhereCalendarView.mainSDK.theme.daySeparatorColor)
        }
    }
}
