//
//  DatePickerDelegate.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 30/09/20.
//

import Foundation
import UIKit

public protocol DatePickerDelegate: class {
    
    /// This method is invoked when the user selects any date from the Picker
    /// - Parameter date: Date object
    func didSelect(date: Date)
    
    
    /// This method gives the title that can be updated for the picker
    /// - Parameter title: A string containing picker title
    func didUpdatePickerTitle(to title: String)
    
    /// This method is invoked when there is a need for the calendar to extend or decrease in height
    /// - Parameter height: A CGFloat value to denote the height
    func didUpdatePickerHeight(to height: CGFloat)
}

protocol PickerDelegate: class {
    func updateMonth(title: String)
    func didSelect(date: Date)
    var activeDate: Date { get }
    var lastSelectedDate: Date? { get }
    func updateMonthPickerHeight(to height: CGFloat)
}
