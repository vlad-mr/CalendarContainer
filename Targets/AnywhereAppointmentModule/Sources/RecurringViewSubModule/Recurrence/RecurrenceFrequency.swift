//
//  RecurrenceFrequency.swift
//  Anytime
//
//  Created by Artem Grebinik on 11.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation

public enum RecurrenceFrequency {
    case yearly
    case monthly
    case weekly
    case daily
    case hourly
    case minutely
    case secondly

    func toString() -> String {
        switch self {
        case .secondly: return "SECONDLY"
        case .minutely: return "MINUTELY"
        case .hourly: return "HOURLY"
        case .daily: return "DAILY"
        case .weekly: return "WEEKLY"
        case .monthly: return "MONTHLY"
        case .yearly: return "YEARLY"
        }
    }

    func toPickerTitleStyleString() -> String {
        switch self {
        case .secondly: return "Secs"
        case .minutely: return "Mins"
        case .hourly: return "Hours"
        case .daily: return "Days"
        case .weekly: return "Weeks"
        case .monthly: return "Months"
        case .yearly: return "Years"
        }
    }

    static func frequencyFromPickerTitle(from string: String) -> RecurrenceFrequency? {
        switch string {
        case "Secs": return .secondly
        case "Mins": return .minutely
        case "Hours": return .hourly
        case "Days": return .daily
        case "Weeks": return .weekly
        case "Months": return .monthly
        case "Years": return .yearly
        default: return nil
        }
    }

    static func frequency(from string: String) -> RecurrenceFrequency? {
        switch string {
        case "SECONDLY": return .secondly
        case "MINUTELY": return .minutely
        case "HOURLY": return .hourly
        case "DAILY": return .daily
        case "WEEKLY": return .weekly
        case "MONTHLY": return .monthly
        case "YEARLY": return .yearly
        default: return nil
        }
    }
}

enum EKReccurrenceMonth: Int {
    case january = 1, february, march, april, may, june, july, august, september, october, november, december

    func toSymbol(_ prefix: Int = 3) -> String {
        var tempSymbol: String = ""

        switch self {
        case .january: tempSymbol = "January"
        case .february: tempSymbol = "February"
        case .march: tempSymbol = "March"
        case .april: tempSymbol = "April"
        case .may: tempSymbol = "May"
        case .june: tempSymbol = "June"
        case .july: tempSymbol = "July"
        case .august: tempSymbol = "August"
        case .september: tempSymbol = "September"
        case .october: tempSymbol = "October"
        case .november: tempSymbol = "November"
        case .december: tempSymbol = "December"
        }
        return String(tempSymbol.prefix(prefix))
    }

    static var wholeYear: [EKReccurrenceMonth] {
        [.january, .february, .march, .april, .may, .june, .july, .august, .september, .october, .november, .december]
    }
}
