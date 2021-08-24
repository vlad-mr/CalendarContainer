//
//  Frequency.swift
//  Anytime
//
//  Created by Artem Grebinik on 25.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import EventKit

public enum Frequency: Equatable {
    
    public static func == (lhs: Frequency, rhs: Frequency) -> Bool {
        switch (lhs, rhs) {
        case (.daily, .daily): return true
        case (.weekly, .weekly):return true
        case (.monthly, .monthly): return true
        case (.yearly, .yearly): return true
        case (.doNotRepeat, .doNotRepeat): return true
        case (.custom, .custom): return true
        default:
            return false
        }
    }
    case doNotRepeat
    case daily(_ recurrrence: RecurrenceRule? = nil)
    case weekly(_ recurrrence: RecurrenceRule? = nil)
    case monthly(_ recurrrence: RecurrenceRule? = nil)
    case yearly(_ recurrrence: RecurrenceRule? = nil)
    case custom(_ recurrrence: RecurrenceRule? = nil)
    
    var displayNameTitle: String {
        switch self {
        case .doNotRepeat:
            return "Don't Repeat"
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Annually"
        case .custom:
            return "Custom"
        }
    }
    
    public func getStaticRule(_ startEventDate: Date?) -> String? {
        guard let date = startEventDate else { return nil }
        switch self {
        
        case .daily(let reccurr):
            guard let rec = reccurr else { return nil }
            return rec.getStaticRule(date)

        case .monthly(let reccurr):
            guard let rec = reccurr else { return nil }
            return rec.getStaticRule(date)
        
        case .weekly(let reccurr):
            guard let rec = reccurr else { return nil }
            return rec.getStaticRule(date)
            
        case .yearly(let reccurr):
            guard let rec = reccurr else { return nil }
            return rec.getStaticRule(date)
            
        case .custom(let reccurr):
            guard let rule = reccurr else { return nil }
            return rule.toRRuleString()

        case .doNotRepeat: return displayNameTitle
        }
    }
    
    public init(rule: String?, startDate: Date) {
        
        guard let ruleString = rule, !ruleString.isEmpty else {
            self = .doNotRepeat
            return
        }
        
        guard let recurrenceRule = RecurrenceRule(rruleString: ruleString) else {
            self = .doNotRepeat
            return
        }
        
        guard let staticCaseRule = recurrenceRule.getStaticRule(startDate) else {
            self = .doNotRepeat
            return
        }
        
        guard staticCaseRule == rule else {
            self = .custom(recurrenceRule)
            return
        }

        switch recurrenceRule.frequency {
        case .daily:
            self = .daily(recurrenceRule)
        case .weekly:
            self = .weekly(recurrenceRule)
        case .monthly:
            self = .monthly(recurrenceRule)
        case .yearly:
            self = .yearly(recurrenceRule)
        case .hourly, .minutely, .secondly:
            fatalError()
        }
    }
    
    func getRecurrenceRule() -> RecurrenceRule? {
        switch self {
        case .custom(let rule): return rule
        default:
            return nil
        }
    }

    public static func cellDynamicTitle(for mode: Frequency, _ startEventDate: Date?) -> String {
        guard let date = startEventDate else { return "" }
        let additionalText = " on "
        switch mode {
        case .monthly:
            
            let calendar = date.calendar
            var components = calendar.dateComponents([.year, .month, .weekdayOrdinal, .weekday], from: date)
            var suchDatesAtMonth: [Date] = []
            
            for ordinal in 1..<6 { // maximum 5 occurrences
                components.weekdayOrdinal = ordinal
                guard let date = calendar.date(from: components) else { break }
                if calendar.component(.month, from: date) != components.month! { break }
                suchDatesAtMonth.append(date)
            }
            
            var titles: [String] = []
            for value in suchDatesAtMonth.enumerated() {
                var title: String = ""
                switch value.offset {
                case 0: title = "first"
                case 1: title = "second"
                case 2: title = "third"
                case 3: title = "fourth"
                default:
                    title = ""
                }
                if value.offset == suchDatesAtMonth.count - 1 {
                    title = "last"
                }
                titles.append("the \(title) \(value.element.weekdayName(.default))")
            }
            
            guard let index = suchDatesAtMonth.firstIndex(where: { $0.day == date.day }) else { return "" }
            return mode.displayNameTitle + additionalText + titles[index]
        case .weekly:
            return mode.displayNameTitle + additionalText + date.weekdayName(.default)
        case .yearly:
            return mode.displayNameTitle + additionalText + date.monthName(.default) + " \(date.day)"
        case .custom(let recurrenceRule):
            guard let rule = recurrenceRule else { return "Custom" }
            return rule.getTitle()
        default:
            return mode.displayNameTitle
        }
    }
}
