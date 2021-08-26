//
//  FullCalendarViewController.swift
//  CalendarContainer
//
//  Created by Volodymyr Kravchenko on 26.08.2021.
//  Copyright © 2021 Anywhere. All rights reserved.
//

import Foundation
import CalendarSDK

public final class FullCalendarViewController: UIViewController {
  public override func viewDidLoad() {
    super.viewDidLoad()
  }

  public var isDailyCalendar = true

  lazy var calendarView: CalendarView = isDailyCalendar ? dailyCalendarView : weeklyCalendarView
  var currentDataSource: EventsListDataSource?
  lazy var numberOfDays = isDailyCalendar ? dailyNumberOfDays : weeklyNumberOfDays
  let dailyNumberOfDays = 1
  let weeklyNumberOfDays = 7
  var currentDate = Date()

  lazy var dailyCalendarView: CalendarView = AnywhereCalendarView.getDailyCalendar(
    withConfiguration: .init(
      withSlotSize: .thirty,
      shouldShowSlotLines: false,
      calendarDimensions: .defaultDimensions
    ),
    dataProvider: self,
    actionDelegate: self
  )

  lazy var weeklyCalendarView: CalendarView = AnywhereCalendarView.getWeeklyCalendar(
    withConfiguration: .init(
      withSlotSize: .thirty,
      shouldShowSlotLines: false,
      calendarDimensions: .defaultDimensions
    ),
    dataProvider: self,
    actionDelegate: self
  )
}
