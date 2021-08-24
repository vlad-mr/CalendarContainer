//
//  CustomFrequencyCellModel.swift
//  Anytime
//
//  Created by Artem Grebinik on 23.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation

class CustomFrequencyModel {
    func getTableViewData() -> [CustomFrequencyHeaderModel] {
        return [.startRepeatSection, .onRepeatSection, .endRepeatSection]
    }

    func getPickerData() -> [[String]] {
        let firstComponnentCells = Array(1 ... 99)
        let secondComponnentCells: [RecurrenceFrequency] = [.daily, .weekly, .monthly, .yearly]
        return [
            firstComponnentCells.map { String($0) },
            secondComponnentCells.map { $0.toPickerTitleStyleString() },
        ]
    }
}

enum CustomFrequencyCellModel {
    case repeatCell
    case repeatPickerCell

    case onWeekRepeatCell
    case onMonthRepeatCell
    case onYearRepeatCell

    case endRepeatCell
}

enum CustomFrequencyHeaderModel: CellHeaderProtocol {
    typealias CellType = CustomFrequencyCellModel

    case startRepeatSection
    case onRepeatSection
    case endRepeatSection

    var cellModels: [CustomFrequencyCellModel] {
        switch self {
        case .startRepeatSection:
            return [.repeatCell, .repeatPickerCell]
        case .onRepeatSection:
            return [.onWeekRepeatCell, .onMonthRepeatCell, .onYearRepeatCell]
        case .endRepeatSection:
            return [.endRepeatCell]
        }
    }
}
