//
//  EKWeekday+RRule.swift
//  Anytime
//
//  Created by Artem Grebinik on 11.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import EventKit
import Foundation

internal extension EKWeekday {
    func toTitle(_ prefix: Int?) -> String {
        var tempTitle = ""
        switch self {
        case .monday: tempTitle = "Monday"
        case .tuesday: tempTitle = "Tuesday"
        case .wednesday: tempTitle = "Wednesday"
        case .thursday: tempTitle = "Thursday"
        case .friday: tempTitle = "Friday"
        case .saturday: tempTitle = "Saturday"
        case .sunday: tempTitle = "Sunday"
        }
        guard let value = prefix else {
            return tempTitle
        }
        return String(tempTitle.prefix(value))
    }

    func toSymbol() -> String {
        switch self {
        case .monday: return "MO"
        case .tuesday: return "TU"
        case .wednesday: return "WE"
        case .thursday: return "TH"
        case .friday: return "FR"
        case .saturday: return "SA"
        case .sunday: return "SU"
        }
    }

    func toNumberSymbol() -> Int {
        switch self {
        case .monday: return 0
        case .tuesday: return 1
        case .wednesday: return 2
        case .thursday: return 3
        case .friday: return 4
        case .saturday: return 5
        case .sunday: return 6
        }
    }

    static func weekdayFromSymbol(_ symbol: String) -> EKWeekday? {
        switch symbol {
        case "MO", "0": return EKWeekday.monday
        case "TU", "1": return EKWeekday.tuesday
        case "WE", "2": return EKWeekday.wednesday
        case "TH", "3": return EKWeekday.thursday
        case "FR", "4": return EKWeekday.friday
        case "SA", "5": return EKWeekday.saturday
        case "SU", "6": return EKWeekday.sunday
        default: return nil
        }
    }
}

extension EKWeekday: Comparable {}

public func < (lhs: EKWeekday, rhs: EKWeekday) -> Bool {
    return lhs.toNumberSymbol() < rhs.toNumberSymbol()
}

public func == (lhs: EKWeekday, rhs: EKWeekday) -> Bool {
    return lhs.toNumberSymbol() == rhs.toNumberSymbol()
}
