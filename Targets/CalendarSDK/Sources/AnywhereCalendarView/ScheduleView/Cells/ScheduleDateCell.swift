//
//  ScheduleDateCell.swift
//  Anytime
//
//  Created by Deepika on 28/02/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit
import os

public class ScheduleDateCell: UITableViewHeaderFooterView {

  @IBOutlet weak var dayLabel: UILabel!
  @IBOutlet weak var weekdayLabel: UILabel!
  public var section: Int = 0

  public override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    dayLabel.font = AnywhereCalendarView.mainSDK.font.header
    dayLabel.layer.cornerRadius = 15
    dayLabel.layer.masksToBounds = true
    self.contentView.backgroundColor = AnywhereCalendarView.mainSDK.theme.dateHeaderBackgroundColor
    weekdayLabel.font = AnywhereCalendarView.mainSDK.font.normal
    weekdayLabel.textColor = AnywhereCalendarView.mainSDK.theme.subHeading
    dayLabel.textColor = AnywhereCalendarView.mainSDK.theme.heading
  }

  public func configureCell(forDate date: Date) {
    dayLabel.text = date.dayString
    weekdayLabel.text = calendarWeekDay(day: date.weekday)
    date.isToday ? highlightToday() : unhighlightDay()
  }

  public func highlightToday() {
    dayLabel.backgroundColor = AnywhereCalendarView.mainSDK.theme.currentDateHighlightColor
    dayLabel.textColor = .white
  }

  public func unhighlightDay() {
    dayLabel.backgroundColor = AnywhereCalendarView.mainSDK.theme.dateHeaderBackgroundColor
    dayLabel.textColor = AnywhereCalendarView.mainSDK.theme.heading
  }

}

extension ScheduleDateCell: CalendarHeaderFooterNib {

  public func configure(_ date: Date, at section: Int) {
    self.section = section
    configureCell(forDate: date)
  }

  public static func getNib() -> UINib? {
#if SWIFT_PACKAGE
    return UINib(nibName: nibName, bundle: .module)
#else
    return UINib(nibName: nibName, bundle: Bundle(for: self))
#endif
  }
}
