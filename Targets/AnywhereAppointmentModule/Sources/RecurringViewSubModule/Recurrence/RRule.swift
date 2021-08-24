//
//  RRule.swift
//  Anytime
//
//  Created by Artem Grebinik on 11.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import EventKit
import Foundation

public enum RRule {
    public static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return dateFormatter
    }()

    public static let ymdDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter
    }()

    internal static let ISO8601DateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter
    }()

    public static func ruleFromString(_ string: String) -> RecurrenceRule? {
        let ruleString = string.trimmingCharacters(in: .whitespaces)
        let rules = ruleString.components(separatedBy: ";").compactMap { rule -> String? in
            if rule.isEmpty {
                return nil
            }
            return rule
        }

        var recurrenceRule = RecurrenceRule(frequency: .daily)
        var ruleFrequency: RecurrenceFrequency?
        for rule in rules {
            let ruleComponents = rule.components(separatedBy: "=")
            guard ruleComponents.count == 2 else {
                continue
            }
            let ruleName = ruleComponents[0]
            let ruleValue = ruleComponents[1]
            guard !ruleValue.isEmpty else {
                continue
            }

            if ruleName == "FREQ" {
                ruleFrequency = RecurrenceFrequency.frequency(from: ruleValue)
                recurrenceRule.isCustomRule = false
            }

            if ruleName == "INTERVAL" {
                if let interval = Int(ruleValue) {
                    recurrenceRule.interval = max(1, interval)
                    recurrenceRule.isCustomRule = interval > 1
                }
            }

            if ruleName == "WKST" {
                if let firstDayOfWeek = EKWeekday.weekdayFromSymbol(ruleValue) {
                    recurrenceRule.firstDayOfWeek = firstDayOfWeek
                }
            }

            if ruleName == "UNTIL" {
                if let endDate = dateFormatter.date(from: ruleValue) {
                    recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: endDate)
                    recurrenceRule.isCustomRule = true
                } else if let endDate = realDate(ruleValue) {
                    recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: endDate)
                    recurrenceRule.isCustomRule = true
                }
            } else if ruleName == "COUNT" {
                if let count = Int(ruleValue) {
                    recurrenceRule.recurrenceEnd = EKRecurrenceEnd(occurrenceCount: count)
                    recurrenceRule.isCustomRule = true
                }
            }

            if ruleName == "BYSETPOS" {
                let bysetpos = ruleValue.components(separatedBy: ",").compactMap { string -> Int? in
                    guard let setpo = Int(string), -366 ... 366 ~= setpo, setpo != 0 else {
                        return nil
                    }
                    return setpo
                }
                recurrenceRule.isCustomRule = true
                recurrenceRule.bysetpos = bysetpos.sorted(by: <)
            }

            if ruleName == "BYYEARDAY" {
                let byyearday = ruleValue.components(separatedBy: ",").compactMap { string -> Int? in
                    guard let yearday = Int(string), -366 ... 366 ~= yearday, yearday != 0 else {
                        return nil
                    }
                    return yearday
                }
                recurrenceRule.isCustomRule = true
                recurrenceRule.byyearday = byyearday.sorted(by: <)
            }

            if ruleName == "BYMONTH" {
                let bymonth = ruleValue.components(separatedBy: ",").compactMap { string -> Int? in
                    guard let month = Int(string), 1 ... 12 ~= month else {
                        return nil
                    }
                    return month
                }
                recurrenceRule.isCustomRule = true
                recurrenceRule.bymonth = bymonth.sorted(by: <)
            }

            if ruleName == "BYWEEKNO" {
                let byweekno = ruleValue.components(separatedBy: ",").compactMap { string -> Int? in
                    guard let weekno = Int(string), -53 ... 53 ~= weekno, weekno != 0 else {
                        return nil
                    }
                    return weekno
                }
                recurrenceRule.isCustomRule = true
                recurrenceRule.byweekno = byweekno.sorted(by: <)
            }

            if ruleName == "BYMONTHDAY" {
                let bymonthday = ruleValue.components(separatedBy: ",").compactMap { string -> Int? in
                    guard let monthday = Int(string), -31 ... 31 ~= monthday, monthday != 0 else {
                        return nil
                    }
                    return monthday
                }
                recurrenceRule.isCustomRule = true
                recurrenceRule.bymonthday = bymonthday.sorted(by: <)
            }

            if ruleName == "BYDAY" {
                let byweekday = ruleValue.components(separatedBy: ",").compactMap { string -> EKWeekday? in
                    EKWeekday.weekdayFromSymbol(string)
                }
                recurrenceRule.isCustomRule = true
                recurrenceRule.byweekday = byweekday.sorted(by: <)
            }

            if ruleName == "BYHOUR" {
                let byhour = ruleValue.components(separatedBy: ",").compactMap { string -> Int? in
                    Int(string)
                }
                recurrenceRule.isCustomRule = true
                recurrenceRule.byhour = byhour.sorted(by: <)
            }

            if ruleName == "BYMINUTE" {
                let byminute = ruleValue.components(separatedBy: ",").compactMap { string -> Int? in
                    Int(string)
                }
                recurrenceRule.isCustomRule = true
                recurrenceRule.byminute = byminute.sorted(by: <)
            }

            if ruleName == "BYSECOND" {
                let bysecond = ruleValue.components(separatedBy: ",").compactMap { string -> Int? in
                    Int(string)
                }
                recurrenceRule.isCustomRule = true
                recurrenceRule.bysecond = bysecond.sorted(by: <)
            }
        }

        guard let frequency = ruleFrequency else {
            print("error: invalid frequency")
            return nil
        }
        recurrenceRule.frequency = frequency

        return recurrenceRule
    }

    public static func stringFromRule(_ rule: RecurrenceRule) -> String {
        var rruleString = ""

        rruleString += "FREQ=\(rule.frequency.toString());"

        let interval = max(1, rule.interval)
        rruleString += "INTERVAL=\(interval);"

        if let endDate = rule.recurrenceEnd?.endDate {
            rruleString += "UNTIL=\(dateFormatter.string(from: endDate));"
        } else if let count = rule.recurrenceEnd?.occurrenceCount {
            rruleString += "COUNT=\(count);"
        }

        let bysetposStrings = rule.bysetpos.compactMap { setpo -> String? in
            guard -366 ... 366 ~= setpo, setpo != 0 else {
                return nil
            }
            return String(setpo)
        }
        if bysetposStrings.isNotEmpty {
            rruleString += "BYSETPOS=\(bysetposStrings.joined(separator: ","));"
        }

        let byyeardayStrings = rule.byyearday.compactMap { yearday -> String? in
            guard -366 ... 366 ~= yearday, yearday != 0 else {
                return nil
            }
            return String(yearday)
        }
        if byyeardayStrings.isNotEmpty {
            rruleString += "BYYEARDAY=\(byyeardayStrings.joined(separator: ","));"
        }

        let bymonthStrings = rule.bymonth.compactMap { month -> String? in
            guard 1 ... 12 ~= month else {
                return nil
            }
            return String(month)
        }
        if bymonthStrings.isNotEmpty {
            rruleString += "BYMONTH=\(bymonthStrings.joined(separator: ","));"
        }

        let byweeknoStrings = rule.byweekno.compactMap { weekno -> String? in
            guard -53 ... 53 ~= weekno, weekno != 0 else {
                return nil
            }
            return String(weekno)
        }
        if byweeknoStrings.isNotEmpty {
            rruleString += "BYWEEKNO=\(byweeknoStrings.joined(separator: ","));"
        }

        let bymonthdayStrings = rule.bymonthday.compactMap { monthday -> String? in
            guard -31 ... 31 ~= monthday, monthday != 0 else {
                return nil
            }
            return String(monthday)
        }
        if bymonthdayStrings.isNotEmpty {
            rruleString += "BYMONTHDAY=\(bymonthdayStrings.joined(separator: ","));"
        }

        let byweekdaySymbols = rule.byweekday.map { weekday -> String in
            weekday.toSymbol()
        }
        if byweekdaySymbols.isNotEmpty {
            rruleString += "BYDAY=\(byweekdaySymbols.joined(separator: ","));"
        }

        let byhourStrings = rule.byhour.map { hour -> String in
            String(hour)
        }
        if byhourStrings.isNotEmpty {
            rruleString += "BYHOUR=\(byhourStrings.joined(separator: ","));"
        }

        let byminuteStrings = rule.byminute.map { minute -> String in
            String(minute)
        }
        if byminuteStrings.isNotEmpty {
            rruleString += "BYMINUTE=\(byminuteStrings.joined(separator: ","));"
        }

        let bysecondStrings = rule.bysecond.map { second -> String in
            String(second)
        }
        if bysecondStrings.isNotEmpty {
            rruleString += "BYSECOND=\(bysecondStrings.joined(separator: ","));"
        }

        if String(rruleString.suffix(from: rruleString.index(rruleString.endIndex, offsetBy: -1))) == ";" {
            rruleString.remove(at: rruleString.index(rruleString.endIndex, offsetBy: -1))
        }

        return rruleString
    }

    static func realDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }

        let date = ymdDateFormatter.date(from: dateString)
        let destinationTimeZone = NSTimeZone.local
        let sourceGMTOffset = destinationTimeZone.secondsFromGMT(for: Date())

        if let timeInterval = date?.timeIntervalSince1970 {
            let realOffset = timeInterval - Double(sourceGMTOffset)
            let realDate = Date(timeIntervalSince1970: realOffset)

            return realDate
        }
        return nil
    }

    public static func titleFromRule(_ rule: RecurrenceRule) -> String {
        var rruleString = ""
        rruleString += "Every"

        let interval = max(1, rule.interval)
        rruleString += " \(interval) "

        switch rule.frequency {
        case .daily:
            rruleString += "days "

        case .weekly:
            rruleString += "weeks on "

        case .monthly:
            rruleString += "months each "

        case .yearly:
            rruleString += "years each "

        default:
            rruleString += " "
        }
        //    let bysetposStrings = rule.bysetpos.compactMap({ (setpo) -> String? in
        //        guard (-366...366 ~= setpo) && (setpo != 0) else {
        //            return nil
        //        }
        //        return String(setpo)
        //    })
        //    if bysetposStrings.isNotEmpty {
        //        rruleString += "BYSETPOS=\(bysetposStrings.joined(separator: ","));"
        //    }

        //    let byyeardayStrings = rule.byyearday.compactMap({ (yearday) -> String? in
        //        guard (-366...366 ~= yearday) && (yearday != 0) else {
        //            return nil
        //        }
        //        return String(yearday)
        //    })
        //    if byyeardayStrings.isNotEmpty {
        //        rruleString += "BYYEARDAY=\(byyeardayStrings.joined(separator: ","));"
        //    }

        let bymonthStrings = rule.bymonth.compactMap { month -> String? in
            guard 1 ... 12 ~= month else {
                return nil
            }
            return String(month)
        }

        if bymonthStrings.isNotEmpty {
            if rule.frequency == .yearly {
                let months = rule.bymonth
                    .compactMap { EKReccurrenceMonth(rawValue: $0) }
                    .map { $0.toSymbol() }.joined(separator: ", ")
                rruleString += months
            } else {
                rruleString += bymonthStrings.joined(separator: ", ")
            }
        }

        //    let byweeknoStrings = rule.byweekno.compactMap({ (weekno) -> String? in
        //        guard (-53...53 ~= weekno) && (weekno != 0) else {
        //            return nil
        //        }
        //        return String(weekno)
        //    })
        //    if byweeknoStrings.isNotEmpty {
        //        rruleString += "BYWEEKNO=\(byweeknoStrings.joined(separator: ","));"
        //    }

        let bymonthdayStrings = rule.bymonthday.compactMap { monthday -> String? in
            guard -31 ... 31 ~= monthday, monthday != 0 else {
                return nil
            }
            return "\(monthday)th"
        }
        if bymonthdayStrings.isNotEmpty {
            if rule.frequency == .yearly {
                let temp = bymonthdayStrings.joined(separator: ", ")
                rruleString += " on \(temp)"
            } else {
                rruleString += bymonthdayStrings.joined(separator: ", ")
            }
        }

        let byweekdaySymbols = rule.byweekday.map { weekday -> String in
            weekday.toTitle(3)
        }
        if byweekdaySymbols.isNotEmpty {
            rruleString += byweekdaySymbols.joined(separator: ", ")
        }

        if let endDate = rule.recurrenceEnd?.endDate {
            let str = endDate.dateString()
            rruleString += " until \(str)"
        } else if let count = rule.recurrenceEnd?.occurrenceCount {
            rruleString += " after \(count) occurrences"
        }

        return rruleString
    }
}
