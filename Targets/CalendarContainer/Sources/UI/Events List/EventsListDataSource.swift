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
    self.events = events.sorted { $0.startTime < $1.startTime }
    calendarItems.removeAll()
    for event in self.events {
      if calendarItems[event.startTime.date.dateAt(.startOfDay)] == nil {
        calendarItems[event.startTime.date.dateAt(.startOfDay)] = Array<CalendarItem>()
      }
      let item = AnywhereCalendarItem(withId: event.id,
                                      title: event.title ?? event.label,
                                      startDate: event.startTime.date.dateRoundedAt(at: .toCeil10Mins),
                                      endDate: event.endTime.date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date,
                                      color: .blue,
                                      source: .google)
      calendarItems[event.startTime.date.dateAt(.startOfDay)]!.append(item)
    }
  }

  private lazy var calendarItems: [Date: [CalendarItem]] = [
    Date().dateAt(.startOfDay): self.getCalendarItems(forDate: Date())
  ]

  public var activeCalendarView: FullCalendarView?
  public var activeDates: [Date] {
//    let date = Date().dateAt(.startOfDay)
    var newDates = Set<Date>()
    for event in events {
      newDates.insert(event.startTime.date.dateAt(.startOfDay))
    }
    return Array(newDates).sorted(by: { $0 < $1 })
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
