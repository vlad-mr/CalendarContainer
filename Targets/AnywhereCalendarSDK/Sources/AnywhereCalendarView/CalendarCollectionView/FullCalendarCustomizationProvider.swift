//
//  FullCalendarCustomizationProvider.swift
//  AnywhereCalendarView
//
//  Created by Vignesh on 19/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

// need to rename this as calendarCustomizationProviderCustomizationDelegate
public protocol CalendarCustomizationProviderDelegate: class {
    func reuseIdentifier(forItemAt indexPath: IndexPath) -> String
    func reuseIdentifier(forHeaderAt section: Int) -> String?
    func reuseIdentifier(forFooterAt section: Int) -> String?
    func height(forRowAt indexPath: IndexPath) -> CGFloat?
    func dayOffTitle(forSection section: Int) -> String?
}

public extension CalendarCustomizationProviderDelegate {
    func height(forRowAt _: IndexPath) -> CGFloat? {
        return nil
    }

    func dayOffTitle(forSection _: Int) -> String? {
        return nil
    }
}

public protocol CalendarSwipeActionDelegate: class {
    func leadingSwipeActionsConfiguration(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    func trailingSwipeActionsConfiguration(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
}

public extension CalendarCustomizationProviderDelegate {
    func reuseIdentifier(forHeaderAt _: Int) -> String? {
        return nil
    }

    func reuseIdentifier(forFooterAt _: Int) -> String? {
        return nil
    }
}

public class FullCalendarCustomizationProvider {
    var calendarView: FullCalendarView
    var calendarCells: [ConfigurableCell.Type]
    var calendarNibs: [CalendarCellNib.Type]
    var headerFooterNibs: [CalendarHeaderFooterNib.Type]
    var headerFooterViews: [ConfigurableView.Type]
    /// the placeholder for the no event day is part of the the tableView footer, so need to make sure that the custom view created for the placeholder is subclassed from UITableViewHeaderFooterView
    var placeholderNib: CalendarHeaderFooterNib.Type?
    var placeholderView: ConfigurableView.Type?
    var allDayEventView: TappableAllDayEventView.Type?
    var allDayEventNib: TappableAllDayEventNib.Type?
    var dayOffView: ConfigurableAllDayEventView.Type?
    var dayOffNib: ConfigurableAllDayEventNib.Type?

    weak var delegate: CalendarCustomizationProviderDelegate?
    public weak var swipeActionDelegate: CalendarSwipeActionDelegate?

    private var registeredCells: [ConfigurableCell.Type] = []
    private var registeredHeaderFooterViews: [ConfigurableView.Type] = []
    private var placeholderIdentifier: String?

    internal required init(withCalendarView calendarView: FullCalendarView,
                           calendarCells: [ConfigurableCell.Type],
                           nibs: [CalendarCellNib.Type],
                           headerFooterViews: [ConfigurableView.Type],
                           headerFooterNibs: [CalendarHeaderFooterNib.Type],
                           placeholderView: ConfigurableView.Type?,
                           placeholderNib: CalendarHeaderFooterNib.Type?,
                           allDayEventView: TappableAllDayEventView.Type?,
                           allDayEventNib: TappableAllDayEventNib.Type?,
                           dayOffView: ConfigurableAllDayEventView.Type? = nil,
                           dayOffNib: ConfigurableAllDayEventNib.Type? = nil)
    {
        self.calendarView = calendarView
        self.calendarCells = calendarCells
        calendarNibs = nibs
        self.headerFooterViews = headerFooterViews
        self.headerFooterNibs = headerFooterNibs

        self.placeholderNib = placeholderNib
        self.placeholderView = placeholderView

        self.allDayEventView = allDayEventView
        self.allDayEventNib = allDayEventNib

        self.dayOffView = dayOffView
        self.dayOffNib = dayOffNib
    }

    func registerCalendarViews() {
        calendarCells.forEach {
            self.calendarView.register($0.self, forCellWithReuseIdentifier: $0.reuseIdentifier)
            self.registeredCells.append($0)
        }

        calendarNibs.forEach {
            calendarView.register($0.getNib(), forCellWithReuseIdentifier: $0.reuseIdentifier)
            self.registeredCells.append($0)
        }

        headerFooterViews.forEach {
            calendarView.register($0, forHeaderFooterViewReuseIdentifier: $0.reuseIdentifier)
            self.registeredHeaderFooterViews.append($0)
        }

        headerFooterNibs.forEach {
            calendarView.register($0, forHeaderFooterViewReuseIdentifier: $0.reuseIdentifier)
            self.registeredHeaderFooterViews.append($0)
        }

        registerPlaceHolder()
    }

    private func registerPlaceHolder() {
        if let placeholderView = self.placeholderView {
            calendarView.register(placeholderView.self, forHeaderFooterViewReuseIdentifier: placeholderView.reuseIdentifier)
            placeholderIdentifier = placeholderView.reuseIdentifier
        } else if let placeholderNib = self.placeholderNib {
            calendarView.register(placeholderNib, forHeaderFooterViewReuseIdentifier: placeholderNib.reuseIdentifier)
            placeholderIdentifier = placeholderNib.reuseIdentifier
        }
    }

    public func dequeueCalendarCell(forIndexPath indexPath: IndexPath) -> ConfigurableCell? {
        guard registeredCells.isNotEmpty, let calendarCell = registeredCells.first else {
            return nil
        }
        var reuseIdentifier = calendarCell.reuseIdentifier
        if let identifer = delegate?.reuseIdentifier(forItemAt: indexPath), identifer.isNotEmpty {
            reuseIdentifier = identifer
        }
        return calendarView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }

    func dequeueCalendarCell(for item: CalendarItem, at indexPath: IndexPath) -> ConfigurableCell? {
        guard registeredCells.isNotEmpty, let calendarCell = registeredCells.first else {
            return nil
        }
        var reuseIdentifier = calendarCell.reuseIdentifier
        if let identifer = delegate?.reuseIdentifier(forItemAt: indexPath), identifer.isNotEmpty {
            // Handle unregistered identifiers and issue warning to the application
            reuseIdentifier = identifer
        }
        let cell = calendarView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell?.configure(item, at: indexPath)
        return cell
    }

    func dequeueCalendarHeader(at section: Int) -> ConfigurableView? {
        guard registeredHeaderFooterViews.isNotEmpty, let calendarHeader = registeredHeaderFooterViews.first else {
            return nil
        }
        // Handle unregistered identifiers and issue warning to the application
        let reuseIdentifer = delegate?.reuseIdentifier(forHeaderAt: section) ?? calendarHeader.reuseIdentifier
        return calendarView.dequeueReusableHeaderFooterView(withReuseIdentifier: reuseIdentifer, for: section)
    }

    func dequeueCalendarPlaceholder(at section: Int) -> ConfigurableView? {
        guard let identifier = placeholderIdentifier else {
            return nil
        }
        return calendarView.dequeueReusableHeaderFooterView(withReuseIdentifier: identifier, for: section)
    }

    func getViewForDayOff(at section: Int) -> ConfigurableAllDayEventView {
        let title = delegate?.dayOffTitle(forSection: section) ?? "Day Off"

        var dayOffView: ConfigurableAllDayEventView
        if let view = self.dayOffView?.init() {
            dayOffView = view
        } else if let view = dayOffNib?.getNib() as? ConfigurableAllDayEventView {
            dayOffView = view
        } else {
            // Mention that you are falling back to the default implementation
            dayOffView = DayOffView()
        }

        dayOffView.configure(withTitle: title)
        return dayOffView
    }

    func getViewForAllDayEvent(at _: Int) -> ConfigurableAllDayEventView {
        var allDayEventView: ConfigurableAllDayEventView
        if let view = self.allDayEventView?.init() {
            allDayEventView = view
        } else if let view = allDayEventNib?.getNib() as? ConfigurableAllDayEventView {
            allDayEventView = view
        } else {
            // Mention that you are falling back to the default implementation
            allDayEventView = AllDayEventView()
        }
        return allDayEventView
    }
}

public extension FullCalendarCustomizationProvider {
    static func custom(forCalendarView calendarView: FullCalendarView,
                       withCustomCalendarCells calendarCells: [ConfigurableCell.Type],
                       calendarNibs: [CalendarCellNib.Type],
                       headerFooterViews: [ConfigurableView.Type] = [],
                       andHeaderFooterNibs headerFooterNibs: [CalendarHeaderFooterNib.Type] = [],
                       delegate: CalendarCustomizationProviderDelegate,
                       placeholderView: ConfigurableView.Type? = nil,
                       placeholderNib: CalendarHeaderFooterNib.Type? = nil,
                       allDayEventView: TappableAllDayEventView.Type? = nil,
                       allDayEventNib: TappableAllDayEventNib.Type? = nil,
                       dayOffView: ConfigurableAllDayEventView.Type? = nil,
                       dayOffNib: ConfigurableAllDayEventNib.Type? = nil) -> FullCalendarCustomizationProvider
    {
        let customizationProvider = self.init(withCalendarView: calendarView,
                                              calendarCells: calendarCells,
                                              nibs: calendarNibs,
                                              headerFooterViews: headerFooterViews,
                                              headerFooterNibs: headerFooterNibs,
                                              placeholderView: placeholderView,
                                              placeholderNib: placeholderNib,
                                              allDayEventView: allDayEventView,
                                              allDayEventNib: allDayEventNib,
                                              dayOffView: dayOffView,
                                              dayOffNib: dayOffNib)
        customizationProvider.delegate = delegate
        return customizationProvider
    }
}
