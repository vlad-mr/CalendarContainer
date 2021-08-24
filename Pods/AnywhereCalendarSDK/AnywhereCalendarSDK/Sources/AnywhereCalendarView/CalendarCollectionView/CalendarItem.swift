//
//  CalendarItem.swift
//  AnywhereCalendarView
//
//  Created by Vignesh on 03/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit.UIColor


public protocol CalendarItem {
    var id: String { get set }
    var title: String? { get set }
    var startDate: Date { get set }
    var endDate: Date { get set }
    var color: UIColor? { get set }
    var shouldAllowEditing: Bool { get set }
    var isAllDay: Bool { get set }
    var source: EventSource { get set }
}

public struct AnywhereCalendarItem: CalendarItem {
    public var id: String
    public var title: String?
    public var startDate: Date
    public var endDate: Date
    //    var timezone: TimeZone // Can be obtained at initialization
    public var color: UIColor?
    public var shouldAllowEditing: Bool = false
    public var isAllDay: Bool = false
    public var source: EventSource = .local
    
    public init(
        withId id: String,
        title: String?,
        startDate: Date,
        endDate: Date,
        color: UIColor?,
        source: EventSource
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
        self.source = source
    }
}

public enum EventSource {
    case google
    case setmore
    case microsoft
    case local
}

//public protocol FullCalendarCell {
//    
//    var id: String { get set }
//    var titleLabel: UILabel { get set }
//    var iconView: UIImageView? { get set }
//    var descriptionLabel: UILabel { get set }
//}
//
//public protocol CalendarCustomizationProvider {
//    func cell(forItem item: CalendarItem) -> FullCalendarCell
//}

protocol CalendarDelegate {
    
    func didTapCalendar(at date: Date) // Date will be computed based on the timezone with which the SDK was initialized
    func didTapEvent(_ event: CalendarItem)
}

