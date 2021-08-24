//
//  CustomFryquencyViewModel.swift
//  Anytime
//
//  Created by Artem Grebinik on 23.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation

protocol CustomFryquencyTableViewModelProtocol {
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellForRowAt(indexPath: IndexPath) -> CustomFrequencyCellModel
}

protocol CustomFryquencyPickerViewModelProtocol {
    func numberOfComponents() -> Int
    func numberOfRowsInComponent(_ component: Int) -> Int
    func titleForRow(_ row: Int, forComponent component: Int) -> String
    func didSelectRow(_ row: Int, inComponent component: Int)
}

protocol CustomFryquencyViewModelProtocol {
    var tableViewData: [CustomFrequencyHeaderModel] { get }
    var pickerData: [[String]] { get }
    
    func viewDidLoad()
}

protocol CustomFryquencyVMProtocol {
    var view: CustomFryquencyVCProtocol? { get set }
}

class CustomFryquencyViewModel: CustomFryquencyViewModelProtocol {
    private let model = CustomFrequencyModel()
    var view: CustomFryquencyVCProtocol

    init(view: CustomFryquencyVCProtocol) {
        self.view = view
    }
    
    var tableViewData: [CustomFrequencyHeaderModel] {
        return model.getTableViewData()
    }
    
    var pickerData: [[String]] {
        return model.getPickerData()
    }
    
    lazy var editedRule = RecurrenceRule(frequency: .daily) {
        didSet {
            let descriptionData = [
                String(editedRule.interval),
                editedRule.frequency.toPickerTitleStyleString()
            ]
            view.updateRepeatCell(with: descriptionData.joined(separator: " "))
            
            var dynamicTitle: String = ""
            if let endReccurrenceCount = editedRule.recurrenceEnd?.occurrenceCount, endReccurrenceCount != 0 {
                dynamicTitle = "After \(endReccurrenceCount) occurrencess"
            }
            if let endReccurrenceDate = editedRule.recurrenceEnd?.endDate {
                dynamicTitle = "After \(endReccurrenceDate.dateString())"
            }
            view.updateEndReccurrenceCell(with: dynamicTitle.isEmpty ? "Never" : dynamicTitle)
        }
    }
    
    func viewDidLoad() {
    }
    
    private var newMode: RecurrenceFrequency = .daily {
        didSet {
            let tempInterval = editedRule.interval
            editedRule = .init(frequency: newMode)
            editedRule.interval = tempInterval
            
            view.toggleCell(for: newMode)
        }
    }
}

extension CustomFryquencyViewModel: CustomFryquencyTableViewModelProtocol {
    func numberOfSections() -> Int {
        return tableViewData.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return tableViewData[section].cellModels.count
    }
    
    func cellForRowAt(indexPath: IndexPath) -> CustomFrequencyCellModel {
        return tableViewData[indexPath.section].cellModels[indexPath.row]
    }
}

extension CustomFryquencyViewModel: CustomFryquencyPickerViewModelProtocol {
    func numberOfComponents() -> Int {
        return pickerData.count
    }
    
    func numberOfRowsInComponent(_ component: Int) -> Int {
        return pickerData[component].count
    }
    
    func titleForRow(_ row: Int, forComponent component: Int) -> String {
        return pickerData[component][row]
    }
    
    func didSelectRow(_ row: Int, inComponent component: Int) {
        let componentData = pickerData[component][row]
        
        if component == 0 {
            editedRule.interval = Int(componentData) ?? 0
        } else if component == 1 {
            newMode = RecurrenceFrequency.frequencyFromPickerTitle(from: componentData) ?? .daily
        }
    }
}
