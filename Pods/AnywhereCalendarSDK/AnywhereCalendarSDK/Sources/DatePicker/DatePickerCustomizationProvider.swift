//
//  DatePickerCustomizationProvider.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 16/03/21.
//

import UIKit
#if canImport(CalendarUtils)
import CalendarUtils
#endif

public class DatePickerCustomizationProvider {
    
    var pickerView: AnywhereDatePickerView?
    var cellNib: DatePickerCellNib.Type?
    var cellView: DatePickerCell.Type?
    var monthButton: MonthHeaderButton.Type?
    var weekDateHeader: CustomizableDateHeader.Type?
    
    var previousButton: MonthNavigatorButton.Type?
    var nextButton: MonthNavigatorButton.Type?
    var todayButton: TodayButton.Type?
    
    private var registeredCell: DatePickerCell.Type?
    
    required internal init(withCell pickerCellView: DatePickerCell.Type?,
                           withNib pickerCellNib: DatePickerCellNib.Type?,
                           monthButton: MonthHeaderButton.Type?,
                           weekDateHeader: CustomizableDateHeader.Type?,
                           previousButton: MonthNavigatorButton.Type?,
                           nextButton: MonthNavigatorButton.Type?,
                           todayButton: TodayButton.Type?) {
        
        self.cellView = pickerCellView
        self.cellNib = pickerCellNib
        self.monthButton = monthButton
        self.weekDateHeader = weekDateHeader
        self.previousButton = previousButton
        self.nextButton = nextButton
        self.todayButton = todayButton
    }
    
    
    func registerViews() {
        
        if let cellToRegister = cellView {
            
            self.pickerView?.register(cellToRegister.self, forCellWithReuseIdentifier: cellToRegister.reuseIdentifier)
            self.registeredCell = cellToRegister
        } else if let nibToRegister = cellNib {
            
            self.pickerView?.register(nibToRegister.getNib(), forCellWithReuseIdentifier: nibToRegister.reuseIdentifier)
            self.registeredCell = nibToRegister
        } else {
            
            let defaultNibToRegister = DayCell.self
            self.pickerView?.register(defaultNibToRegister.getNib(), forCellWithReuseIdentifier: defaultNibToRegister.reuseIdentifier)
            self.registeredCell = defaultNibToRegister
        }
    }
    
    public func dequeuePickerCell(forIndexPath indexPath : IndexPath) -> DatePickerCell? {
        
        guard let pickerCell = self.registeredCell  else {
            return nil
        }
        let reuseIdentifier = pickerCell.reuseIdentifier
        return pickerView?.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }
    
    func getWeekDayHeader(forDay day: Int) -> CustomizableDateHeader {
        guard let header = weekDateHeader else {
            return WeekHeaderDay()
        }
        return header.init()
    }
    
    func getMonthTitleView() -> MonthHeaderButton {
        guard let titleView = monthButton else {
            return MonthTitleHeaderButton()
        }
        return titleView.init()
    }
    
    func getButtonForPrevious() -> MonthNavigatorButton {
        
        guard let leftNavButton = previousButton else {
            return MonthPickerNavButton.leftNavButton
        }
        return leftNavButton.init()
    }
    
    func getButtonForNext() -> MonthNavigatorButton {
        
        guard let rightNavButton = nextButton else {
            return MonthPickerNavButton.rightNavButton
        }
        return rightNavButton.init()
    }
    
    func getTodayButton() -> TodayButton {
        
        guard let todayButton = todayButton else {
            return MonthPickerTodayButton()
        }
        return todayButton.init()
    }
}

public extension DatePickerCustomizationProvider {
    
    static func custom(withCell pickerCellView: DatePickerCell.Type? = nil,
                       withNib pickerCellNib: DatePickerCellNib.Type? = nil,
                       monthPickerHeaderView: MonthHeaderButton.Type? = nil,
                       weekDayHeader: CustomizableDateHeader.Type? = nil,
                       buttonForPrevious: MonthNavigatorButton.Type? = nil,
                       buttonForNext: MonthNavigatorButton.Type? = nil,
                       buttonForToday: TodayButton.Type? = nil) -> Self {
        
        let customizationProvider = self.init(withCell: pickerCellView,
                                              withNib: pickerCellNib,
                                              monthButton: monthPickerHeaderView,
                                              weekDateHeader: weekDayHeader,
                                              previousButton: buttonForPrevious,
                                              nextButton: buttonForNext,
                                              todayButton: buttonForToday)
        return customizationProvider
    }
    
    static var standard: Self {
        return self.init(withCell: nil,
                         withNib: DayCell.self,
                         monthButton: MonthTitleHeaderButton.self,
                         weekDateHeader: WeekHeaderDay.self,
                         previousButton: nil,
                         nextButton: nil,
                         todayButton: nil)
    }
}
