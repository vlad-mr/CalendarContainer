//
//  TimeStretch.swift
//  Anytime
//
//  Created by Vignesh on 20/02/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

public enum CalendarSlotSize: Int {
    case five = 5, fifteen = 15, thirty = 30, sixty = 60

    var divisionsPerHour: Int {
        return 60 / minutes
    }

    var divisionHeight: CGFloat {
        return CGFloat(30)
    }

    var hourHeight: CGFloat {
        return CGFloat(divisionsPerHour) * divisionHeight * scaleFactor
    }

    var dayHeight: CGFloat {
        return 24 * hourHeight
    }

    var minutes: Int {
        return rawValue
    }

    var scaleFactor: CGFloat {
        return 1
    }

    func getRelevantPosition(forMinutes minutes: Int) -> CGFloat {
        return CGFloat(minutes) / 60 * hourHeight * scaleFactor
    }
}

extension Array where Element == WorkingHour {
    var sortByStartTime: [WorkingHour] {
        return sorted { $0.start < $1.start }
    }

    var sortByEndTime: [WorkingHour] {
        return sorted { $0.end < $1.end }
    }
}
