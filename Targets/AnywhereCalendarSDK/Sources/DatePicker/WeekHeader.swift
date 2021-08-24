//
//  WeekHeader.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 11/03/21.
//

import UIKit
#if canImport(CalendarUtils)
import CalendarUtils
#endif

protocol WeekHeaderViewDelegate {
    func isOffHour(onDay day: Int) -> Bool
}

class WeekHeaderView: UIStackView {
    
    var config: DatePickerConfig = .standard
    var delegate: WeekHeaderViewDelegate?
    var customizationProvider: DatePickerCustomizationProvider = .standard
    var theme: DatePickerTheme = AnywherePickerTheme()
    
    var shouldHighlightToday = true {
        didSet {
            updateView(forFrame: self.frame)
        }
    }
    
    override var frame: CGRect {
        didSet {
            self.updateView(forFrame: frame)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        updateView(forFrame: self.frame)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupView()
        updateView(forFrame: rect)
    }
    
    func setupView() {
        self.axis = .horizontal
        self.distribution = .fillEqually
        self.alignment = .center
        self.backgroundColor = .white
    }
    
    func updateView(forFrame rect: CGRect) {
        
        if !subviews.isEmpty {
            for subview in self.subviews {
                subview.removeFromSuperview()
            }
        }
        
        var day = calendarWeekStartDay
        for _ in 0...6 {
            let weekDay = configure(customizationProvider.getWeekDayHeader(forDay: day)) {
                let isActiveWeekday = Date().weekday == day
                var dayType: DateType = .ActiveMonth
                if shouldHighlightToday, isActiveWeekday {
                    dayType = .Today
                } else if let isOffHour = delegate?.isOffHour(onDay: day), isOffHour {
                    dayType = .Holiday
                }
                $0.setTheme(theme)
                $0.configure(with: config, for: day, dayType: dayType)
            }
            self.addArrangedSubview(weekDay)
            
            let nextDay = day + 1
            day = nextDay == 8 ? 1 : nextDay
        }
    }
}

class WeekHeaderDay: UIButton, CustomizableDateHeader {
    
    var dayType: DateType = .ActiveMonth
    var theme: DatePickerTheme = AnywherePickerTheme()
    var config: DatePickerConfig = .init()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupButton()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupButton()
    }
    
    func setupButton() {
        
        highlightDay(forDayType: dayType)
        self.titleLabel?.textAlignment = .center
        self.backgroundColor = .white
    }
    
    func configure(with configuration: DatePickerConfig, for weekday: Int, dayType: DateType) {
        
        self.dayType = dayType
        let weekDayTitle = configuration.viewConfiguration.weekDayTitleMode.weekDayString(forDay: weekday)
        self.setTitle(weekDayTitle, for: .normal)

        // font is not applying through config and I can't figure out why
        // self.titleLabel?.font = configuration.font
        self.titleLabel?.font = .systemFont(ofSize: 12)
        setupButton()
    }
    
    func highlightDay(forDayType dayType: DateType) {
        let highlightColor: UIColor
        switch dayType {
        case .Today:
            highlightColor = config.viewConfiguration.shouldHighlightCurrentWeekday
                ? theme.todayColor
                : theme.weekdayPrimaryColor
        case .Holiday:
            highlightColor = theme.holidayColor
        default:
            highlightColor = theme.weekdayPrimaryColor
        }
        self.setTitleColor(highlightColor, for: .normal)
    }
    
    func setConfig(_ config: DatePickerConfig) {
        self.config = config
    }
    
    func setTheme(_ theme: DatePickerTheme) {
        self.theme = theme
    }
}
