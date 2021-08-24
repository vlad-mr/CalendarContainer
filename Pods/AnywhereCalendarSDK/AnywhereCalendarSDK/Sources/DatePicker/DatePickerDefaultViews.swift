//
//  DatePickerDefaultViews.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 20/05/21.
//

import UIKit

class MonthTitleHeaderButton: UIButton, MonthHeaderButton {
    
    var titleFont: UIFont = .systemFont(ofSize: 14)
    var titleColor: UIColor = .blue
    
    func setMonthTitle(_ title: String) {
        self.setTitle(title, for: .normal)
    }
    
    func configure() {
        self.setTitle("MONTH YEAR", for: .normal)
        self.titleLabel?.font = titleFont
        self.setTitleColor(titleColor, for: .normal)
        self.backgroundColor = .white
        self.titleLabel?.baselineAdjustment = .alignCenters
        self.titleLabel?.textAlignment = .center
    }
    
    func setConfig(_ config: DatePickerConfig) {
        self.titleFont = config.font.withSize(14)
    }
    
    func setTheme(_ theme: DatePickerTheme) {
        self.titleColor = theme.titleColor
    }
}

class MonthPickerNavButton: UIButton, MonthNavigatorButton {
    
    enum NavDirection {
        case left, right
    }
    
    var navDirection: NavDirection = .left
    func configure() {
        
        if #available(iOS 13.0, *), let image = UIImage(systemName: navDirection == .left ? "arrow.left" : "arrow.right") {
            self.setImage(image, for: .normal)
        } else {
            self.setTitle(navDirection == .left ? "Previous" : "Next", for: .normal)
        }
        self.backgroundColor = .white
    }
}

extension MonthPickerNavButton {
    
    static var leftNavButton: MonthPickerNavButton {
        let monthNavButton = MonthPickerNavButton()
        monthNavButton.navDirection = .left
        return monthNavButton
    }
    
    static var rightNavButton: MonthPickerNavButton {
        let monthNavButton = MonthPickerNavButton()
        monthNavButton.navDirection = .right
        return monthNavButton
    }
}

class MonthPickerTodayButton: UIButton, TodayButton {
    
    var buttonFont: UIFont = .systemFont(ofSize: 12)
    var theme: DatePickerTheme = AnywherePickerTheme()
    
    func configure() {
        self.titleLabel?.font = buttonFont
        self.setTitle("Today", for: .normal)
        self.setTitleColor(theme.selectedDateTintColor, for: .normal)
        self.backgroundColor = .white
        self.titleLabel?.baselineAdjustment = .alignCenters
        self.titleLabel?.textAlignment = .center
    }
    
    func setConfig(_ config: DatePickerConfig) {
        self.buttonFont = config.font
    }
    
    func setTheme(_ theme: DatePickerTheme) {
        self.theme = theme
    }
}
