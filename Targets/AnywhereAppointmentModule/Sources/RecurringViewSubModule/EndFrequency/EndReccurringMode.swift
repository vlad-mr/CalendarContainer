//
//  EndReccurringMode.swift
//  Anytime
//
//  Created by Artem Grebinik on 24.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
// MARK: - EndReccurringMode

enum EndReccurringMode: Equatable {
    case never
    case date(date: Date? = nil)
    case occurence(count: Int? = nil)
    
    static func == (lhs: EndReccurringMode, rhs: EndReccurringMode) -> Bool {
        switch (lhs, rhs) {
        
        case (.date(let lhsDate), .date(let rhsDate)):
            return lhsDate?.timeIntervalSince1970 == rhsDate?.timeIntervalSince1970
            
        case (.occurence(let lhsCount), .occurence(let rhsCount)):
            return lhsCount == rhsCount
            
        case (.never, .never):
            return true
            
        case (.never, .date):
            return false
            
        case (.never, .occurence):
            return false
            
        case (.occurence, .date):
            return false
            
        default:
            return false
        }
    }
}

// MARK: - HeaderModel
class EndFrequencyModel {
    func getTableViewData() -> [EndFrequencyHeaderModel] {
        return [.neverRecurrence, .onDateRecurrence, .occurrenceRecurrence]
    }
    
    func getPickerData() -> [String] {
        return Array(1...99).map { String($0) }
    }
}

enum EndFrequencyCellModel {
    case never
    case onDate
    case onDatePicker
    case occurrences
    case occurrencesPicker
}

enum EndFrequencyHeaderModel: CellHeaderProtocol {
    typealias CellType = EndFrequencyCellModel
    case neverRecurrence
    case onDateRecurrence
    case occurrenceRecurrence
    
    var cellModels: [EndFrequencyCellModel] {
        switch self {
        case .neverRecurrence: return [.never]
        case .onDateRecurrence: return [.onDate, .onDatePicker]
        case .occurrenceRecurrence: return [.occurrences, .occurrencesPicker]
        }
    }
}

