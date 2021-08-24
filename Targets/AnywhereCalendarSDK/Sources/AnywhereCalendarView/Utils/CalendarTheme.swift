//
//  Theme.swift
//  AnywhereCalendarView
//
//  Created by Vignesh on 10/07/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

protocol Theme {
    // CalendarBackgroundTheme
    var offHoursBackgroundColor: UIColor { get }
    var offHoursStripeColor: UIColor { get }
    var workingHoursBackgroundColor: UIColor { get }
    var workingHoursDivLineColor: UIColor { get }

    // Separators
    var hourSeparatorColor: UIColor { get }
    var daySeparatorColor: UIColor { get }

    // Time Header Theme
    var timeHeaderBackgroundColor: UIColor { get }
    var timeheaderTextColor: UIColor { get }

    // Date Header Theme
    var dateHeaderBackgroundColor: UIColor { get }
    var currentDateHighlightColor: UIColor { get }
    var currentDateText: UIColor { get }
    var defaultDateText: UIColor { get }
    var weekdayShortName: UIColor { get }

    // Current Timeline
    var currentTimelineColor: UIColor { get }

    // Creation Selector Theme
    var selectorColor: UIColor { get }

    var dayOffColor: UIColor { get }
    var dayOffTextColor: UIColor { get }

    var backgroundColor: UIColor { get }
    var heading: UIColor { get }
    var subHeading: UIColor { get }
}

public struct CalendarTheme: Theme {
    public var backgroundColor = UIColor.black

    public var offHoursBackgroundColor = UIColor(red: 239 / 255, green: 239 / 255, blue: 239 / 255, alpha: 1)
    public var offHoursStripeColor: UIColor = .gray
    public var workingHoursBackgroundColor: UIColor = .black
    public var workingHoursDivLineColor = UIColor(red: 239 / 255, green: 239 / 255, blue: 239 / 255, alpha: 1)

    public var hourSeparatorColor: UIColor = .gray
    public var daySeparatorColor: UIColor = .gray

    public var timeHeaderBackgroundColor: UIColor = .black
    public var timeheaderTextColor: UIColor = .gray

    public var dateHeaderBackgroundColor: UIColor = .black
    public var currentDateHighlightColor: UIColor = .green
    var currentDateText: UIColor = .white
    var defaultDateText: UIColor = .white
    var weekdayShortName = UIColor.white.withAlphaComponent(0.7)

    public var currentTimelineColor: UIColor = .green

    public var selectorColor: UIColor = .blue

    public var heading = UIColor.white
    public var subHeading = UIColor.white.withAlphaComponent(0.75)

    public var dayOffColor = UIColor.lightGray
    var dayOffTextColor: UIColor = .black
}

public extension CalendarTheme {
    static var Dark: Self {
        .init()
    }

    static var Light: Self {
        .init(backgroundColor: .white,
              offHoursBackgroundColor: .grey200,
              offHoursStripeColor: .gray,
              workingHoursBackgroundColor: .white,
              workingHoursDivLineColor: UIColor.grey300.withAlphaComponent(0.5),
              hourSeparatorColor: .grey300,
              daySeparatorColor: .grey300,
              timeHeaderBackgroundColor: .white,
              timeheaderTextColor: .grey400,
              dateHeaderBackgroundColor: .white,
              currentDateHighlightColor: UIColor.blue700,
              currentDateText: .white,
              defaultDateText: .black,
              weekdayShortName: UIColor.grey400,
              currentTimelineColor: .red200,
              selectorColor: .blue,
              heading: .grey700,
              subHeading: UIColor.grey700.withAlphaComponent(0.5),
              dayOffColor: .grey300)
    }

    @available(iOS 13.0, *)
    static var SystemTheme: Self {
        .init(backgroundColor: .themedBackground,
              offHoursBackgroundColor: .systemGray4,
              offHoursStripeColor: .systemGray2,
              workingHoursBackgroundColor: .themedBackground,
              workingHoursDivLineColor: .systemGray6,
              hourSeparatorColor: .systemGray5,
              daySeparatorColor: .systemGray3,
              timeHeaderBackgroundColor: .themedBackground,
              timeheaderTextColor: .label,
              dateHeaderBackgroundColor: .themedBackground,
              currentDateHighlightColor: .systemBlue,
              currentTimelineColor: .systemTeal,
              selectorColor: .systemIndigo,
              heading: .label,
              subHeading: .secondaryLabel,
              dayOffColor: .systemGray)
    }
}

extension UIColor {
    @available(iOS 13.0, *)
    static var themedBackground: UIColor {
        UIColor(dynamicProvider: { (traitCollection: UITraitCollection) -> UIColor in
            switch traitCollection.userInterfaceStyle {
            case
                .unspecified, .light: return .white
            case .dark: return .black
            @unknown default:
                print("UNHANDLED STATE")
                return .white
            }
        })
    }
}
