//
//  DateHeaderView.swift
//  AnywhereCalendarSDK
//
//  Created by Deepika on 12/08/20.
//

import UIKit

class DateHeaderView: UICollectionReusableView, CalendarHeaderFooterNib {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weekDayLabel: UILabel!
    var section: Int = 0
    weak var actionDelegate: CalendarActionDelegate?
    
    static var nibName: String = "CalendarDateHeaderView"
    
    static func getNib() -> UINib? {
        #if SWIFT_PACKAGE
        return UINib(nibName: nibName, bundle: .module)
        #else
        return UINib(nibName: nibName, bundle: Bundle(for: self))
        #endif
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLabels()
    }
    
    private func setupLabels() {
        self.backgroundColor = AnywhereCalendarView.mainSDK.theme.dateHeaderBackgroundColor
        weekDayLabel.font = AnywhereCalendarView.mainSDK.font.normal
        weekDayLabel.textAlignment = .center
        weekDayLabel.textColor = AnywhereCalendarView.mainSDK.theme.weekdayShortName
        
        dayLabel.textAlignment = .center
        dayLabel.font = AnywhereCalendarView.mainSDK.font.normal
        dayLabel.textColor = AnywhereCalendarView.mainSDK.theme.defaultDateText
        //        dayLabel.setRoundedCorners(withCornerRadius: 16)
        dayLabel.layer.cornerRadius = 16
        dayLabel.clipsToBounds = true
    }
    
    func configure(_ date: Date, at section: Int) {
        configureView(forDate: date)
    }
    
    func configureView(forDate date: Date) {
        weekDayLabel.text = "\(date.weekdayName(.veryShort).uppercased())"
        dayLabel.text = "\(date.day)"
        if date.isToday {
            dayLabel.textColor = AnywhereCalendarView.mainSDK.theme.currentDateText
            dayLabel.backgroundColor = AnywhereCalendarView.mainSDK.theme.currentDateHighlightColor
        } else if date.isInWeekend {
            dayLabel.textColor = AnywhereCalendarView.mainSDK.theme.weekdayShortName
            dayLabel.backgroundColor = AnywhereCalendarView.mainSDK.theme.dateHeaderBackgroundColor
        } else {
            dayLabel.textColor = AnywhereCalendarView.mainSDK.theme.defaultDateText
            dayLabel.backgroundColor = AnywhereCalendarView.mainSDK.theme.dateHeaderBackgroundColor
        }
    }
}
