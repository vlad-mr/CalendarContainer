//
//  DatePickerInterface.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 30/09/20.
//

import Foundation

public struct AnywhereDatePicker {
    
    public static func getDatePicker(withConfig config: DatePickerConfig,
                                     dataSource: DatePickerDataSource? = nil,
                                     delegate: DatePickerDelegate? = nil,
                                     customizationProvider: DatePickerCustomizationProvider = .standard,
                                     pickerDimensions: DatePickerDimensions = .standard,
                                     theme: DatePickerTheme = AnywherePickerTheme()) -> DatePickerView {
        
        setUserDefaultRegion(config.userRegion)
        PickerUtils.shouldDisplayCurrentYearOnMonthTitle = config.viewConfiguration.shouldDisplayCurrentYearOnMonthTitle
        PickerUtils.monthTitleStyle = config.viewConfiguration.monthTitleStyle
        
        let pickerViewController = DatePickerViewController()
        pickerViewController.pickerConfig = config
        pickerViewController.dataSource = dataSource
        pickerViewController.customizationProvider = customizationProvider
        pickerViewController.delegate = delegate
        pickerViewController.pickerTheme = theme
        pickerViewController.pickerDimensions = pickerDimensions
        return pickerViewController
    }
}
