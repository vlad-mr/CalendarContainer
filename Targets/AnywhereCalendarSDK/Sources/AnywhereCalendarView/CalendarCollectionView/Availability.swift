//
//  Availability.swift
//  AnywhereCalendarView
//
//  Created by Vignesh on 04/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation

public struct UserAvailability: Codable, Equatable, Hashable {
    public var sunday = DayAvailability(hours: [WorkingHour(start: 420, end: 1080)])
    public var monday = DayAvailability()
    public var tuesday = DayAvailability()
    public var wednesday = DayAvailability()
    public var thursday = DayAvailability()
    public var friday = DayAvailability()
    public var saturday = DayAvailability(hours: [])

    private var weeklyAvailability: [DayAvailability] {
        [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
    }

    public init() {
        sunday = DayAvailability()
        monday = DayAvailability()
        tuesday = DayAvailability()
        wednesday = DayAvailability()
        thursday = DayAvailability()
        friday = DayAvailability()
        saturday = DayAvailability(hours: [])
    }

    enum CodingKeys: String, CodingKey {
        case sunday = "SU"
        case monday = "MO"
        case tuesday = "TU"
        case wednesday = "WE"
        case thursday = "TH"
        case friday = "FR"
        case saturday = "SA"
    }

    public func getAvailability(forDay day: Int) -> DayAvailability {
        guard day < 7 else {
            preconditionFailure("Invalid day value passed")
        }
        switch day {
        case 0:
            return sunday
        case 1:
            return monday
        case 2:
            return tuesday
        case 3:
            return wednesday
        case 4:
            return thursday
        case 5:
            return friday
        case 6:
            return saturday
        default:
            preconditionFailure("Invalid Day")
        }
    }
}

extension UserAvailability {}

public struct DayAvailability: Codable, Equatable, Hashable {
    var hours: [WorkingHour] = [WorkingHour()]
}

public struct WorkingHour: Codable, Equatable, Hashable {
    var start: Int = 540
    var end: Int = 1020

    init() {
        start = 0
        end = 1439
    }

    public init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }

    var isLowerAndUpperBoundEqual: Bool {
        return start == end
    }

    var boundsDifference: Int {
        return end - start
    }

    func contains(_ element: Int) -> Bool {
        return ClosedRange(uncheckedBounds: (lower: start, upper: end)).contains(element)
    }
}
