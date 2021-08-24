//
//  FrequencyCellModel.swift
//  Anytime
//
//  Created by Artem Grebinik on 25.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation

extension FrequencyViewController {
    enum FrequencyCellModel {
        case customRepeat
        case doNotRepeat
        case daily
        case weekly
        case monthly
        case yearly
        case customFrequencyEdit
    }

    enum FrequencyHeaderModel: CellHeaderProtocol {
        typealias CellType = FrequencyCellModel
        case customFrequencyCells
        case staticFrequencyCells
        case anotherCells

        var cellModels: [FrequencyCellModel] {
            switch self {
            case .customFrequencyCells:
                return [.customRepeat]
            case .staticFrequencyCells:
                return [.doNotRepeat, .daily, .weekly, .monthly, .yearly]
            case .anotherCells:
                return [.customFrequencyEdit]
            }
        }
    }
}
