//
//  FullCalendarDataSource.swift
//  CalendarContainer
//
//  Created by Volodymyr Kravchenko on 26.08.2021.
//  Copyright © 2021 Anywhere. All rights reserved.
//

import Foundation
import CalendarSDK

class CalendarDataSource: FullCalendarDataSource {

  var activeCalendarView: FullCalendarView? {
    didSet {
      source.activeCalendarView = activeCalendarView
    }
  }
  var source: FullCalendarDataSource
  // for testing purpose
  var shouldAllDayEventPartOfHeader: Bool = true
  var activeDates: [Date] {
    return source.activeDates
  }

  init(withSource source: FullCalendarDataSource) {
    self.source = source
  }

  func getAllEvents() -> [CalendarItem] {

    var calendarItems = [CalendarItem]()
    for index in 0..<activeDates.count {
      calendarItems += source.getCalendarItems(forSection: index)
    }
    return calendarItems
  }

  func getCalendarItems(forSection section: Int) -> [CalendarItem] {
    guard let date = getDate(forSection: section) else {
      return []
    }
    guard let calendarItems = AnywhereCalendarView.getIntraEventsByDate(originalEvents: getAllEvents())[date.dateAt(.startOfDay)] else {
      return []
    }

    guard shouldAllDayEventPartOfHeader else {
      return calendarItems
    }

    return calendarItems.filter { !$0.isAllDay }
  }

  func getDate(forSection section: Int) -> Date? {

    guard section < activeDates.count else {
      return nil
    }
    return activeDates[section]
  }

  func numberOfItems(inSection section: Int) -> Int {

    return getCalendarItems(forSection: section).count
  }

  func getAllDayEvents(forSection section: Int) -> [CalendarItem] {
    guard shouldAllDayEventPartOfHeader else {
      return []
    }
    guard let date = getDate(forSection: section) else {
      return []
    }
    guard let calendarItems = AnywhereCalendarView.getIntraEventsByDate(originalEvents: getAllEvents())[date.dateAt(.startOfDay)] else {
      return []
    }

    return calendarItems.filter { $0.isAllDay }
  }

  func shouldShowDayOff(forSection section: Int) -> Bool {
    source.shouldShowDayOff(forSection: section)
  }
}

class DataSource: FullCalendarDataSource {

  var activeCalendarView: FullCalendarView?

  var activeDates: [Date] = [Date()]

  func getCalendarItems(forSection section: Int) -> [CalendarItem] {
    let activeDate = activeDates[section]
    guard activeDate.isToday else {
      return []
    }
    let item0 = AnywhereCalendarItem(withId: "A123", title: "Meeting with Team", startDate: activeDate, endDate: activeDate.dateByAdding(2, .hour).date, color: .systemBlue, source: .google)
    let item1 = AnywhereCalendarItem(withId: "A123", title: "Meeting with Team", startDate: activeDate, endDate: activeDate.dateByAdding(2, .hour).date, color: .systemBlue, source: .google)
    let item2 = AnywhereCalendarItem(withId: "B123", title: "Workshop", startDate: activeDate.dateAt(.tomorrow), endDate: activeDate.dateByAdding(4, .hour).date, color: .systemGreen, source: .local)
    let item3 = AnywhereCalendarItem(withId: "C123", title: "Discussion", startDate: activeDate.dateByAdding(3, .hour).date, endDate: activeDate.dateByAdding(4, .hour).date, color: .systemTeal, source: .setmore)
    return [
      getCalendarItem(forDate: activeDate.dateAt(.tomorrow), title: "Multi day event", color: .systemPurple),
      item0,
      item1,
      item2,
      item3
    ]
  }

  private func getCalendarItem(forDate date: Date, title: String?, color: UIColor? = .red) -> CalendarItem {
    return AnywhereCalendarItem(withId: "1234", title: title, startDate: date.add(component: .hour, value: 2), endDate: date.add(component: .day, value: 2), color: color, source: .microsoft)
  }

  func numberOfItems(inSection section: Int) -> Int {
    guard !activeDates.isEmpty else {
      return 0
    }
    return 1
  }

  func shouldShowDayOff(forSection section: Int) -> Bool {
    return false
  }
}
