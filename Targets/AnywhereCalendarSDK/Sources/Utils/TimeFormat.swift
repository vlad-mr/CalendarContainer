//
//  TimeFormat.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 01/07/21.
//

import Foundation

public enum TimeFormat {
    case twelveHours
    case twentyFourHours
    case deviceSetting

    var deviceTimeFormat: TimeFormat {
        return Date().uses12HourFormat() ? .twelveHours : .twentyFourHours
    }

    public var is12HourFormat: Bool {
        self == .twelveHours || (self == .deviceSetting && deviceTimeFormat == .twelveHours)
    }

    var formatString: String {
        switch self {
        case .twelveHours:
            return "h:mm aa"
        case .twentyFourHours:
            return "HH:mm"
        case .deviceSetting:
            return deviceTimeFormat.formatString
        }
    }
}
