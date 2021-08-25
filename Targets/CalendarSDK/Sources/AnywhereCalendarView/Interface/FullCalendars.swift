//
//  FullCalendars.swift
//  AnywhereCalendarView
//
//  Created by Vignesh on 03/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate
#if canImport(CalendarUtils)
import CalendarUtils
#endif

public protocol CalendarView: UIViewController {
  var actionDelegate: CalendarActionDelegate? { get set }
  var dataProvider: CalendarDataProvider? { get set }

  func setActiveDate(_ date: Date)
  func reloadCalendar()
}

class FullCalendars {

  var calConfig: CalendarConfiguration
  var theme: CalendarTheme
  var font: AnyCalFont
  private(set) var currentTimeFormat: TimeFormat {
    didSet {
      DateUtilities.timeFormat = self.currentTimeFormat
    }
  }
  init(withConfiguration configuration: CalendarConfiguration, theme: CalendarTheme, font: UIFont) {
    self.calConfig = configuration
    self.theme = theme
    self.font = AnyCalFont(font: font)
    self.currentTimeFormat =  configuration.timeFormat.is12HourFormat ? .twelveHours : .twentyFourHours
  }

  var calendarLayoutView: CalendarLayoutViewController {
    return CalendarViewControllers.calendarLayoutView
  }

  func getCalendarView(forLayoutType layoutType: CalendarLayoutType, withConfiguration config: CalendarViewConfiguration, dataProvider: CalendarDataProvider, actionDelegate: CalendarActionDelegate?) -> CalendarViewController {
    let calendarView = CalendarViewControllers.calendarView
    calendarView.viewConfig = config
    calendarView.layoutType = layoutType
    calendarView.dataProvider = dataProvider
    calendarView.actionDelegate = actionDelegate
    return calendarView
  }

  func getScheduleView(withConfiguration scheduleConfig: ScheduleViewConfiguration, placeholderView: ActionableView?, dimension: ScheduleViewDimensions) -> ScheduleBaseViewController {
    return CalendarViewControllers.getScheduleView(withConfiguration: scheduleConfig, placeholderView: placeholderView, dimension: dimension)
  }

  private func configureCalendar(withUserAvailability userAvailability: UserAvailability?) {
    calConfig.userAvailability = userAvailability
  }

  public func configureCalendar(withConfiguration configuration: CalendarConfiguration) {

    configureCalendar(withUserAvailability: configuration.userAvailability)
  }
}


//MARK: Configurations
public struct CalendarConfiguration {

  var userAvailability: UserAvailability?
  var userRegion: Region
  var timeFormat: TimeFormat

  public init(withUserAvailability userAvailability: UserAvailability? = nil, userRegion: Region = .current, timeFormat: TimeFormat = .deviceSetting) {
    self.userAvailability = userAvailability
    self.userRegion = userRegion
    self.timeFormat = timeFormat
  }
}

public struct CalendarViewConfiguration {

  public enum ExcessAllDayEventsTitleConfiguration {
    case count
    case more
    case custom(text: String)
  }
  var slotSize: CalendarSlotSize
  var shouldShowSlotLines: Bool
  var calendarDimensions: CalendarDimensions
  var shouldHaveFloatingDayOff: Bool
  var shouldShowDateHeader: Bool
  var shouldShowDateHeaderSeparator: Bool
  var shouldHaveFloatingAllDayEvent: Bool
  var shouldHaveStripedOffHours: Bool
  var numberOfAllDayEventInCollapsedMode: Int
  var currentTimeIndicator: CurrentTimeIndicator

  var moreAllDayEventConfiguration: ExcessAllDayEventsTitleConfiguration
  public init(withSlotSize slotSize: CalendarSlotSize = .thirty,
              shouldShowSlotLines: Bool = false, shouldShowDateHeader: Bool = true,
              calendarDimensions: CalendarDimensions = .defaultDimensions,
              shouldHaveFloatingDayOff: Bool = true,
              shouldShowDateHeaderSeparator: Bool = true,
              shouldHaveFloatingAllDayEvent: Bool = false,
              shouldHaveStripedOffHours: Bool = false,
              numberOfAllDayEventInCollapsedMode: Int = 2,
              moreAllDayEventConfiguration: ExcessAllDayEventsTitleConfiguration = .count,
              currentTimeIndicator: CurrentTimeIndicator = .triangle
  ) {
    self.slotSize = slotSize
    self.shouldShowDateHeader = shouldShowDateHeader
    self.shouldShowSlotLines = shouldShowSlotLines
    self.calendarDimensions = calendarDimensions
    self.shouldHaveFloatingDayOff = shouldHaveFloatingDayOff
    self.shouldShowDateHeaderSeparator = shouldShowDateHeaderSeparator
    self.shouldHaveFloatingAllDayEvent = shouldHaveFloatingAllDayEvent
    self.shouldHaveStripedOffHours = shouldHaveStripedOffHours
    self.numberOfAllDayEventInCollapsedMode = numberOfAllDayEventInCollapsedMode
    self.moreAllDayEventConfiguration = moreAllDayEventConfiguration
    self.currentTimeIndicator = currentTimeIndicator
  }
}

public struct ScheduleViewConfiguration {

  public enum PlaceholderConfig {
    case daily
    case weekly
    case allCases
  }

  let placeholderConfig: PlaceholderConfig
  let shouldHaveStickyDate: Bool
  let textForNoEventDay: String
  var shouldShowEventView: Bool
  var shouldShowHeader: Bool
  let shouldAllowFreeScrollToBottom: Bool

  public init(shouldHaveStickyDate: Bool = true,
              placeholderConfig: PlaceholderConfig = .allCases,
              textForNoEventDay: String = "No appointments booked",
              shouldShowHeader: Bool = true,
              shouldShowEventView: Bool = true,
              shouldAllowFreeScrollToBottom: Bool = false) {
    self.shouldHaveStickyDate = shouldHaveStickyDate
    self.textForNoEventDay = textForNoEventDay
    self.placeholderConfig = placeholderConfig
    self.shouldAllowFreeScrollToBottom = shouldAllowFreeScrollToBottom
    self.shouldShowHeader = shouldShowHeader
    self.shouldShowEventView = shouldShowEventView
  }
}
