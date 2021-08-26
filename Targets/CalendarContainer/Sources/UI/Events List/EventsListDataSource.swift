//
//  ScheduleViewDataSource.swift
//  CalendarContainer
//
//  Created by Volodymyr Kravchenko on 26.08.2021.
//  Copyright © 2021 Anywhere. All rights reserved.
//

import Foundation
import CalendarSDK

public final class EventsListDataSource: FullCalendarDataSource {
  private var events: [EventModel] = []

  public func update(_ events: [EventModel]) {
    self.events = events
  }

  private lazy var calendarItems: [Date: [CalendarItem]] = [
    Date().dateAt(.startOfDay): self.getCalendarItems(forDate: Date())
  ]

  public var activeCalendarView: FullCalendarView?
  public var activeDates: [Date] {
    let date = Date().dateAt(.startOfDay)
    var newDates = [Date]()
    for day in 0..<7 {
      newDates.append(date.dateByAdding(day, .day).date)
    }
    return newDates
  }

  public func numberOfItems(inSection section: Int) -> Int {
    return getCalendarItems(forSection: section).count
  }

  public func getCalendarItems(forSection section: Int) -> [CalendarItem] {
    guard section < activeDates.count else {
      return []
    }
    let date = activeDates[section]
    guard let items = calendarItems[date] else {
      return []
    }
    return items
  }

  var noOfItemsForActiveDates: Int {
    return calendarItems.count
  }

  func insert(calendarItem: CalendarItem) {
    let date = calendarItem.startDate.dateAt(.startOfDay)
    insert(date: date)
    calendarItems[date]?.append(calendarItem)
    activeCalendarView?.insertItems(at: [IndexPath(row: 0, section: 0)])
  }

  func insert(date: Date) {
    let date = date.dateAt(.startOfDay)
    guard calendarItems[date] == nil else {
      return
    }
    calendarItems[date] = []
  }

  func deleteItem(at indexPath: IndexPath) {
    let date = activeDates[indexPath.section]
    calendarItems[date]?.removeFirst()
    activeCalendarView?.deleteItems(at: [IndexPath(row: 0, section: indexPath.section)])
  }

  private func getCalendarItems(forDate date: Date) -> [CalendarItem] {
    return [
      AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: date.dateRoundedAt(at: .toCeil10Mins), endDate: date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .google),
      AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: date.dateRoundedAt(at: .toCeil10Mins), endDate: date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .setmore),
      AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: date.dateRoundedAt(at: .toCeil10Mins), endDate: date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .microsoft),
      AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: date.dateRoundedAt(at: .toCeil10Mins), endDate: date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .google),
      AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: date.dateRoundedAt(at: .toCeil10Mins), endDate: date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .setmore),
      AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: date.dateRoundedAt(at: .toCeil10Mins), endDate: date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .microsoft),
      AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: date.dateRoundedAt(at: .toCeil10Mins), endDate: date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .google),
      AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: date.dateRoundedAt(at: .toCeil10Mins), endDate: date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .setmore),
      AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: date.dateRoundedAt(at: .toCeil10Mins), endDate: date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .microsoft),
      AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: date.dateRoundedAt(at: .toCeil10Mins), endDate: date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .google),
      AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: date.dateRoundedAt(at: .toCeil10Mins), endDate: date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .setmore),
      AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: date.dateRoundedAt(at: .toCeil10Mins), endDate: date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .microsoft),
    ]
  }

}
