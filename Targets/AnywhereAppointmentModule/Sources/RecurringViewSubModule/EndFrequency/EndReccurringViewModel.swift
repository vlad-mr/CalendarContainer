//
//  EndReccurringViewModel.swift
//  Anytime
//
//  Created by Artem Grebinik on 24.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

// MARK: - ViewModel

protocol EndFryquencyTableViewModelProtocol {
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellForRowAt(indexPath: IndexPath) -> EndFrequencyCellModel
}

protocol EndFryquencyPickerViewModelProtocol {
    func numberOfComponents() -> Int
    func numberOfRowsInComponent(_ component: Int) -> Int
    func titleForRow(_ row: Int, forComponent component: Int) -> String
    func didSelectRow(_ row: Int, inComponent component: Int)
}

protocol EndFryquencyViewModelProtocol {
    var tableViewData: [EndFrequencyHeaderModel] { get }
    var pickerData: [String] { get }
    
    func viewDidLoad()
}

class EndReccurringViewModel: EndFryquencyViewModelProtocol {
    
    private let model = EndFrequencyModel()
    var view: EndReccurringVCProtocol

    init(view: EndReccurringVCProtocol) {
        self.view = view
    }
    
    var tableViewData: [EndFrequencyHeaderModel] {
        return model.getTableViewData()
    }
    var pickerData: [String] {
        return model.getPickerData()
    }
    
    func viewDidLoad() {
        
    }
}
extension EndReccurringViewModel: EndFryquencyTableViewModelProtocol {
    func numberOfSections() -> Int {
        return tableViewData.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return tableViewData[section].cellModels.count
    }
    
    func cellForRowAt(indexPath: IndexPath) -> EndFrequencyCellModel {
        return tableViewData[indexPath.section].cellModels[indexPath.row]
    }
}

extension EndReccurringViewModel: EndFryquencyPickerViewModelProtocol {
    func numberOfComponents() -> Int {
        return 1
    }
    
    func numberOfRowsInComponent(_ component: Int) -> Int {
        return pickerData.count
    }
    
    func titleForRow(_ row: Int, forComponent component: Int) -> String {
        return pickerData[row]
    }
    
    func didSelectRow(_ row: Int, inComponent component: Int) {
//        let componentData = pickerData[component][row]
//
//        if component == 0 {
//            editedRule.interval = Int(componentData) ?? 0
//        } else if component == 1 {
//            newMode = RecurrenceFrequency.frequencyFromPickerTitle(from: componentData) ?? .daily
//        }
    }
}
