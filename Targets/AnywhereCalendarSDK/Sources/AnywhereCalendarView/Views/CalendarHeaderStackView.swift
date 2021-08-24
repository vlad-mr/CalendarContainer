//
//  CalendarHeaderStackView.swift
//  AnywhereCalendarSDK
//
//  Created by Deepika on 07/08/20.
//

import UIKit
#if canImport(CalendarUtils)
    import CalendarUtils
#endif

typealias ConfigurableDateHeader = ConfigurableView & UIView
protocol DateHeaderCustomizationDelegate {
    func shouldShowDayOff(forDate date: Date) -> Bool
    func getHeaderView(forDate date: Date) -> ConfigurableDateHeader?
    func getDayOffView(forDate date: Date) -> ConfigurableAllDayEventView?
    func getAllDayEventViews(forDate date: Date) -> [TappableAllDayEventView]
    func getNoOfAllDayEvents(forDate date: Date) -> Int
    func getDateHeaderHeight(forDate date: Date) -> CGFloat
}

class CalendarHeaderStackView: UIStackView {
    var dates: [Date] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_: CGRect) {
        guard dates.isNotEmpty else {
            return
        }
        updateView()
    }

    var contentWidth: CGFloat {
        let numberOfDays = CGFloat(dates.count)
        let width = (frame.width / numberOfDays) - 1
        return width
    }

    var customizationProvider: DateHeaderCustomizationDelegate?
    var calendarDimensions: CalendarDimensions = .defaultDimensions {
        didSet {
            setNeedsDisplay()
        }
    }

    var config = CalendarViewConfiguration() {
        didSet {
            setNeedsDisplay()
        }
    }

    weak var actionDelegate: CalendarActionDelegate? {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        alignment = .center
        distribution = .fillEqually
        autoresizesSubviews = false
        axis = .horizontal
    }

    func getDayOffView(forDate date: Date) -> UIView {
        guard let dayOffView = customizationProvider?.getDayOffView(forDate: date) as? UIView else {
            return UIView()
        }
        dayOffView.translatesAutoresizingMaskIntoConstraints = false
        dayOffView.backgroundColor = AnywhereCalendarView.mainSDK.theme.dayOffColor
        dayOffView.setupWidthAnchor(withConstant: contentWidth)
        dayOffView.setupHeightAnchor(withConstant: calendarDimensions.dayOffViewHeight)
        return dayOffView
    }

    func updateView() {
        print("Default implementation!")
    }

    func getAllDayView(forDate date: Date, shouldShowAllDayEvent: Bool, shouldShowDayOff: Bool) -> UIStackView {
        let stackView = configure(UIStackView()) {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.autoresizesSubviews = false
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        if shouldShowAllDayEvent, let allDayEvents = customizationProvider?.getAllDayEventViews(forDate: date) {
            stackView.addArrangedSubviews(allDayEvents)
        }

        if shouldShowDayOff {
            stackView.addArrangedSubview(getDayOffView(forDate: date))
        }

        return stackView
    }
}
