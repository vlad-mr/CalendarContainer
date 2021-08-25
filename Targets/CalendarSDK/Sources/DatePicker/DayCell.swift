//
//  DayCell.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 30/09/20.
//

import UIKit
import SwiftDate
#if canImport(CalendarUtils)
import CalendarUtils
#endif

public struct DatePickerCellModel {
    var date: Date
    var isDayOff: Bool
    var isInActiveMonth: Bool
    var isLastSelected: Bool
    var numberOfEvents: Int
    var isOutOfBounds: Bool
    
    public static var standard: Self {
        DatePickerCellModel(date: Date(), isDayOff: false, isInActiveMonth: false, isLastSelected: false, numberOfEvents: 0, isOutOfBounds: false)
    }
}

public protocol DatePickerCell: ReusableView, UICollectionViewCell {
    
    // PROPERTIES
    var pickerConfig: DatePickerConfig { get set }
    var viewMode: DatePickerMode { get set }
    var theme: DatePickerTheme { get set }
    var isSelected: Bool { get set }
    
    // METHODS
    func set(model: DatePickerCellModel)
}

public protocol DatePickerCellNib: DatePickerCell, ReusableNib {}

public enum DateType {
    case Today
    case ActiveMonth
    case NonActiveMonth
    case Holiday
}

open class DayCell: UICollectionViewCell, DatePickerCellNib {
    
    @IBOutlet public weak var dayButton: UIButton!
    public static var nibName: String = "MonthCell"
    
    public static var reuseIdentifier: String {
        return "DayCell"
    }
    
    public static func getNib() -> UINib? {
        #if SWIFT_PACKAGE
        return UINib(nibName: nibName, bundle: .module)
        #else
        return UINib(nibName: nibName, bundle: Bundle(for: self))
        #endif
    }
    
    public lazy var pickerConfig: DatePickerConfig = .standard
    lazy var activeCalendarDate: Date = Date()
    lazy var model: DatePickerCellModel = .standard
    public lazy var theme: DatePickerTheme = AnywherePickerTheme()
    public lazy var viewMode: DatePickerMode = .monthly
    
    open override var isSelected: Bool {
        didSet {
            if isSelected {
                self.highlightDate()
            } else {
                self.unHighlightDate()
            }
        }
    }
    
    open override func prepareForReuse() {
        resetViews()
    }
    
    public func set(model: DatePickerCellModel) {
        
        resetViews()
        self.model = model
        dayButton.setTitle(model.date.dayString, for: .normal)
        dayButton.titleLabel?.font = pickerConfig.font.withSize(13)
        dayButton.titleLabel?.textAlignment = .center
        
        setCellColors()
        
        if model.isLastSelected {
            highlightDate()
        } else {
            unHighlightDate()
        } 
    }
    
    func highlightDate() {
        switch pickerConfig.viewConfiguration.selectedDateHighlightMode {
        case .circled:
            dayButton.backgroundColor = theme.selectedDateTintColor
            dayButton.setTitleColor(UIColor.white, for: .normal)
        case .highlighted:
            dayButton.backgroundColor = UIColor.white
            dayButton.setTitleColor(theme.selectedDateTintColor, for: .normal)
        }
        dayButton.layer.cornerRadius = 15
    }
    
    func highlitedToday() {
        switch pickerConfig.viewConfiguration.todayHighlightMode {
        case .circled:
            dayButton.backgroundColor = theme.todayColor
            dayButton.setTitleColor(UIColor.white, for: .normal)
        case .highlighted:
            dayButton.backgroundColor = theme.todayColor
            dayButton.setTitleColor(theme.selectedDateTintColor, for: .normal)
        }
        dayButton.layer.cornerRadius = 15
    }
    
    func unHighlightDate() {
        dayButton.backgroundColor = UIColor.clear
        dayButton.layer.cornerRadius = 15
        setCellColors()
    }
    
    func setCellColors() {
        if !model.isOutOfBounds, model.isInActiveMonth || viewMode == .weekly {
            if model.date.isToday, !isSelected {
                setDayColor(for: .Today)
            } else if model.isDayOff {
                setDayColor(for: .Holiday)
            } else {
                setDayColor(for: .ActiveMonth)
            }
        } else {
            setDayColor(for: .NonActiveMonth)
        }
    }
    
    private func setDayColor(for type: DateType) {
        switch type {
        case .Today:
            highlitedToday()
        case .ActiveMonth:
            let color = model.date.isInWeekend ? theme.secondaryColor : theme.primaryColor
            dayButton.setTitleColor(color, for: .normal)
        case .NonActiveMonth:
            switch pickerConfig.viewConfiguration.nonActiveMonthDateMode {
            case .dimmed:
                dayButton.setTitleColor(theme.secondaryColor, for: .normal)
            case .hidden:
                dayButton.setTitleColor(.clear, for: .normal)
            case .normal:
                dayButton.setTitleColor(theme.primaryColor, for: .normal)
            }
        case .Holiday:
            dayButton.setTitleColor(theme.holidayColor, for: .normal)
        }
    }
    
    private func resetViews() {
        dayButton.setTitle("", for: .normal)
        dayButton.isUserInteractionEnabled = false
    }
}
