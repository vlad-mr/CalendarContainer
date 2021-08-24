//
//  ScheduleDateCell.swift
//  Anytime
//
//  Created by Deepika on 28/02/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import os
import UIKit

class ScheduleDateCell: UITableViewHeaderFooterView {
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var weekdayLabel: UILabel!
    var section: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dayLabel.font = AnywhereCalendarView.mainSDK.font.header
        dayLabel.layer.cornerRadius = 15
        dayLabel.layer.masksToBounds = true
        contentView.backgroundColor = AnywhereCalendarView.mainSDK.theme.dateHeaderBackgroundColor
        weekdayLabel.font = AnywhereCalendarView.mainSDK.font.normal
        weekdayLabel.textColor = AnywhereCalendarView.mainSDK.theme.subHeading
        dayLabel.textColor = AnywhereCalendarView.mainSDK.theme.heading
    }

    func configureCell(forDate date: Date) {
        dayLabel.text = date.dayString
        weekdayLabel.text = calendarWeekDay(day: date.weekday)
        date.isToday ? highlightToday() : unhighlightDay()
    }

    func highlightToday() {
        dayLabel.backgroundColor = AnywhereCalendarView.mainSDK.theme.currentDateHighlightColor
        dayLabel.textColor = .white
    }

    func unhighlightDay() {
        dayLabel.backgroundColor = AnywhereCalendarView.mainSDK.theme.dateHeaderBackgroundColor
        dayLabel.textColor = AnywhereCalendarView.mainSDK.theme.heading
    }
}

extension ScheduleDateCell: CalendarHeaderFooterNib {
    func configure(_ date: Date, at section: Int) {
        self.section = section
        configureCell(forDate: date)
    }

    static func getNib() -> UINib? {
        #if SWIFT_PACKAGE
            return UINib(nibName: nibName, bundle: .module)
        #else
            return UINib(nibName: nibName, bundle: Bundle(for: self))
        #endif
    }
}
