//
//  DatePickerViewController.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 30/09/20.
//

import SwiftDate
import UIKit
#if canImport(CalendarUtils)
    @testable import CalendarUtils
#endif

open class DatePickerViewController: UIViewController, DatePickerView {
    // MARK: Properties

    var pickerTheme: DatePickerTheme = AnywherePickerTheme()
    var selectedDate = Date() {
        didSet {
            highlightWeekday()
        }
    }

    var pickerDimensions: DatePickerDimensions = .standard

    // MARK: Public properties

    public lazy var customizationProvider: DatePickerCustomizationProvider = .standard
    public var dataSource: DatePickerDataSource?
    public weak var delegate: DatePickerDelegate?

    public lazy var pickerConfig: DatePickerConfig = .standard {
        didSet {
            if pickerConfig.userRegion != oldValue.userRegion {
                setUserDefaultRegion(pickerConfig.userRegion)
            }
        }
    }

    // MARK: Buttons and Headers

    lazy var leftArrow: MonthNavigatorButton = {
        configure(customizationProvider.getButtonForPrevious()) {
            $0.frame = CGRect(x: 50, y: 18, width: 20, height: 15)
            $0.configure()
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addTarget(self, action: #selector(showPrevious), for: UIControl.Event.touchUpInside)
        }
    }()

    lazy var rightArrow: UIButton = {
        configure(customizationProvider.getButtonForNext()) {
            let originX = view.frame.width - 65
            $0.frame = CGRect(x: originX, y: 18, width: 20, height: 15)
            $0.configure()
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addTarget(self, action: #selector(showNext), for: UIControl.Event.touchUpInside)
        }
    }()

    lazy var monthTitle: MonthHeaderButton = {
        configure(customizationProvider.getMonthTitleView()) {
            let originX = view.frame.width / 2 - 75
            $0.frame = CGRect(x: originX, y: 10, width: 150, height: pickerDimensions.monthTitleHeight)
            $0.setConfig(pickerConfig)
            $0.setTheme(pickerTheme)
            $0.configure()
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addTarget(self, action: #selector(toggleMode), for: .touchUpInside)
        }
    }()

    lazy var todayButton: TodayButton = {
        configure(customizationProvider.getTodayButton()) {
            let originX: CGFloat = 10
            $0.frame = CGRect(x: originX, y: 10, width: 50, height: pickerDimensions.monthTitleHeight)
            $0.setConfig(pickerConfig)
            $0.setTheme(pickerTheme)
            $0.configure()
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addTarget(self, action: #selector(reloadToToday), for: .touchUpInside)
        }
    }()

    lazy var weekTitle: WeekHeaderView = configure(WeekHeaderView()) {
        $0.config = pickerConfig
        $0.delegate = self
        $0.theme = pickerTheme
        $0.customizationProvider = customizationProvider
        let originY: CGFloat = pickerConfig.viewConfiguration.pickerTitleMode != .none ? (pickerDimensions.monthTitleHeight + 5) : 0
        $0.frame = CGRect(x: 0, y: originY, width: self.view.bounds.width, height: pickerDimensions.weekHeaderHeight)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: Page View Controller

    private lazy var pageViewController: VerticalSwipablePageViewController = {
        configure(VerticalSwipablePageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)) {
            $0.dataSource = self
            $0.setViewControllers([self.monthView], direction: .forward, animated: false, completion: nil)
            var originY: CGFloat = pickerDimensions.weekHeaderHeight - 5
            if pickerConfig.viewConfiguration.pickerTitleMode != .none {
                originY += pickerDimensions.monthTitleHeight
            }
            $0.view.frame = CGRect(origin: CGPoint(x: 0, y: originY), size: self.view.bounds.size)
            $0.swipeActionDelegate = self
        }
    }()

    // MARK: Initial MonthPickerView

    private lazy var monthView: DatePickerCollectionViewController = {
        configure(DatePickerCollectionViewController()) {
            let activeDate = self.activeDate
            $0.pickerConfig = pickerConfig
            $0.currentViewMode = pickerConfig.mode
            $0.theme = pickerTheme
            $0.delegate = self
            $0.activeDate = activeDate
            $0.customizationProvider = customizationProvider
            $0.dataSource = dataSource
            $0.positioningDelegate = self
            $0.model = DatePickerModel(with: activeDate, mode: pickerConfig.mode)
        }
    }()

    // MARK: Computed NEXT AND PREVIOUS PAGES

    var prevPage: DatePickerCollectionViewController? {
        guard let activeDate = currentActivePageViewController?.activeDate else {
            return nil
        }
        let year: Int, month: Int, day: Int
        switch pickerConfig.mode {
        case .weekly:
            let date = activeDate.dateByAdding(-7, .day).date
            if let minDate = pickerConfig.minDate, date.isBeforeDate(minDate, granularity: .weekOfYear) {
                return nil
            }
            year = date.year
            month = date.month
            day = date.day
        case .monthly:
            year = (activeDate.month == 1) ? activeDate.year - 1 : activeDate.year
            month = (activeDate.month == 1) ? 12 : activeDate.month - 1
            day = 2
        }
        //
        guard let prevActiveDate = DateInRegion(components: DateComponents(calendar: userRegion.calendar, timeZone: TimeZone.current, year: year, month: month, day: day, hour: activeDate.hour, minute: activeDate.minute, second: activeDate.minute), region: userRegion) else { return nil }

        return configure(DatePickerCollectionViewController()) {
            $0.pickerConfig = pickerConfig
            $0.currentViewMode = pickerConfig.mode
            $0.theme = pickerTheme
            $0.activeDate = prevActiveDate.date
            $0.model = DatePickerModel(with: prevActiveDate.date, mode: pickerConfig.mode)
            $0.delegate = self
            $0.customizationProvider = customizationProvider
            $0.dataSource = dataSource
            $0.positioningDelegate = self
        }
    }

    var nextPage: DatePickerCollectionViewController? {
        guard let activeDate = currentActivePageViewController?.activeDate else {
            return nil
        }

        let year: Int, month: Int, day: Int
        switch pickerConfig.mode {
        case .weekly:
            let date = activeDate.dateByAdding(7, .day).date
            if let maxDate = pickerConfig.maxDate, date.isAfterDate(maxDate, granularity: .weekOfYear) {
                return nil
            }
            year = date.year
            month = date.month
            day = date.day
        case .monthly:
            year = (activeDate.month == 12) ? activeDate.year + 1 : activeDate.year
            month = (activeDate.month == 12) ? 1 : activeDate.month + 1
            day = 2
        }
        guard let nextActiveDate = DateInRegion(components: DateComponents(calendar: userRegion.calendar, timeZone: TimeZone.current, year: year, month: month, day: day, hour: activeDate.hour, minute: activeDate.minute, second: activeDate.minute), region: userRegion) else { return nil }

        // TODO: Need to replace this with builder pattern ;)
        return configure(DatePickerCollectionViewController()) {
            $0.pickerConfig = pickerConfig
            $0.currentViewMode = pickerConfig.mode
            $0.theme = pickerTheme
            $0.activeDate = nextActiveDate.date
            $0.model = DatePickerModel(with: nextActiveDate.date, mode: pickerConfig.mode)
            $0.delegate = self
            $0.customizationProvider = customizationProvider
            $0.dataSource = dataSource
            $0.positioningDelegate = self
        }
    }

    // MARK: Current Active Controller

    private var currentActivePageViewController: DatePickerCollectionViewController? {
        return pageViewController.viewControllers?.first as? DatePickerCollectionViewController
    }

    // MARK: Methods

    override open func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        view.backgroundColor = .white
        let viewHeight: CGFloat = pickerConfig.viewConfiguration.pickerTitleMode != .none ? 290 : 250
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: viewHeight)
        switch pickerConfig.viewConfiguration.pickerTitleMode {
        case .monthName:
            view.addSubview(monthTitle)
        case .monthNameWithNavButtons:
            view.addSubview(monthTitle)
            view.addSubview(leftArrow)
            view.addSubview(rightArrow)
        case .monthNameWithTodayButton:
            view.addSubview(monthTitle)
            view.addSubview(todayButton)
        default:
            break
        }
        view.addSubview(weekTitle)
        pageViewController.setViewControllers([monthView], direction: .forward, animated: false, completion: nil)
        view.addSubview(pageViewController.view)
        setupConstraints()
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlingOrientationChanges), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    func setupConstraints() {
        var layoutConstraintsToActivate = [NSLayoutConstraint]()
        layoutConstraintsToActivate.append(contentsOf: [
            weekTitle.widthAnchor.constraint(equalTo: view.widthAnchor),
            pageViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])

        switch pickerConfig.viewConfiguration.pickerTitleMode {
        case .monthName:
            layoutConstraintsToActivate.append(contentsOf: [
                monthTitle.topAnchor.constraint(equalTo: view.topAnchor),
                weekTitle.topAnchor.constraint(equalTo: monthTitle.bottomAnchor),
                monthTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
        case .monthNameWithNavButtons:
            layoutConstraintsToActivate.append(contentsOf: [
                monthTitle.topAnchor.constraint(equalTo: view.topAnchor),
                weekTitle.topAnchor.constraint(equalTo: monthTitle.bottomAnchor),
                monthTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                leftArrow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                rightArrow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10),
            ])
        case .monthNameWithTodayButton:
            layoutConstraintsToActivate.append(contentsOf: [
                monthTitle.topAnchor.constraint(equalTo: view.topAnchor),
                weekTitle.topAnchor.constraint(equalTo: monthTitle.bottomAnchor),
                monthTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                todayButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            ])
        case .none:
            layoutConstraintsToActivate.append(contentsOf: [
                weekTitle.topAnchor.constraint(equalTo: view.topAnchor),
            ])
        }
        NSLayoutConstraint.activate(layoutConstraintsToActivate)
    }

    @objc func handlingOrientationChanges() {
        updateHeaderView()
        invalidateLayout()
    }

    func invalidateLayout() {
        guard isViewLoaded else {
            print("The layout cannot be invalidated as view is not loaded")
            return
        }
        DispatchQueue.main.async {
            self.currentActivePageViewController?.reloadView()
            self.monthView.reloadView()
        }
    }

    func updateHeaderView() {
        let originY: CGFloat = pickerConfig.viewConfiguration.pickerTitleMode != .none ? pickerDimensions.monthTitleHeight + 5 : 0
        let frame = CGRect(x: 0, y: originY, width: view.bounds.width, height: pickerDimensions.weekHeaderHeight)
        weekTitle.updateView(forFrame: frame)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func reloadModel() {
        monthView.model = DatePickerModel(with: activeDate, mode: pickerConfig.mode)
        monthView.collectionView.reloadData()
    }

    @objc func toggleMode() {
        let newMode: DatePickerMode = pickerConfig.mode == .weekly ? .monthly : .weekly
        pickerConfig.switchTo(newMode)
        handleMinMaxMode()
    }

    @objc func reloadToToday() {
        load(for: Date())
    }

    func resetView() {
        var direction = UIPageViewController.NavigationDirection.forward
        var shouldAnimate = true
        if let activeView = pageViewController.viewControllers?.first as? DatePickerCollectionViewController {
            direction = activeView.activeDate > activeDate ? .reverse : .forward
            if activeView.activeDate.compare(.isSameDay(activeDate)) {
                activeView.reloadView()
                return
            } else if activeView.activeDate.isInSameMonthAs(activeDate) || pickerConfig.mode == .weekly {
                activeView.selectCell(for: selectedDate)
                shouldAnimate = false
            }
        }

        let monthPicker = configure(DatePickerCollectionViewController()) {
            $0.pickerConfig = pickerConfig
            $0.currentViewMode = pickerConfig.mode
            $0.positioningDelegate = self
            $0.delegate = self
            $0.dataSource = dataSource
            $0.activeDate = activeDate
            $0.theme = pickerTheme
            $0.model = DatePickerModel(with: activeDate, mode: pickerConfig.mode)
        }
        pageViewController.setViewControllers([monthPicker], direction: direction, animated: shouldAnimate, completion: nil)
    }

    func handleMinMaxMode() {
        let activeView = currentActivePageViewController!
        switch pickerConfig.mode {
        case .weekly:
            let weekOfMonth = CGFloat(lastSelectedDate?.weekOfMonth ?? activeDate.weekOfMonth)
            let originY: CGFloat = -((weekOfMonth - 1) * pickerDimensions.pickerDateHeight) + weekOfMonth
            let heightToUpdate = abs(originY) + pickerDimensions.pickerDateHeight
            UIView.animate(withDuration: 0.25) {
                activeView.collectionView.frame.origin.y = originY
                activeView.collectionView.frame.size.height = heightToUpdate
                activeView.currentViewMode = .weekly
                activeView.collectionView.reloadDataWithoutAnimation()
            }
            updateMonthPickerHeight(to: pickerDimensions.pickerDateHeight + 10)
        case .monthly:
            if activeView.model?.dates.count == 7 {
                activeView.pickerConfig.switchTo(.monthly)
                activeView.model = DatePickerModel(with: activeView.activeDate, mode: .monthly)
                activeView.reloadView()
            }
            UIView.animate(withDuration: 0.25) {
                activeView.collectionView.frame.origin.y = 0
                activeView.collectionView.frame.size.height = activeView.pickerHeight
                activeView.currentViewMode = .monthly
                activeView.collectionView.reloadDataWithoutAnimation()
            }
            updateMonthPickerHeight(to: activeView.pickerHeight)
        }
        if pickerConfig.mode == .weekly, !(currentActivePageViewController?.model?.dates.contains(activeDate.dateAt(.startOfDay)) ?? true) {
            pageViewController.removeNonActivePages()
            resetView()
        } else {
            pageViewController.setViewControllers([activeView], direction: .forward, animated: false, completion: nil)
        }
        highlightWeekday()
    }

    @objc func showPrevious() {
        guard let prevPage = prevPage else { return }
        pageViewController.setViewControllers([prevPage], direction: .reverse, animated: true, completion: nil)
    }

    @objc func showNext() {
        guard let nextPage = nextPage else { return }
        pageViewController.setViewControllers([nextPage], direction: .forward, animated: true, completion: nil)
    }

    public func reload() {
        resetView()
    }

    public func load(for date: Date) {
        guard pickerConfig.isDateInBounds(date) else {
            // MARK: Need to check the functionality for this and send back an error to the client saying that the date is out of bounds

            print("Unable to load calendar for this date")
            return
        }
        selectedDate = date
        guard let currentlyActiveDate = currentActivePageViewController?.activeDate else {
            print("Date not available")
            return
        }
        switch currentActivePageViewController?.pickerConfig.mode {
        case .monthly where currentlyActiveDate.isInSameMonthAs(date):

            currentActivePageViewController?.selectCell(for: date)
            if pickerConfig.mode == .weekly {
                currentActivePageViewController?.pickerConfig = pickerConfig
                currentActivePageViewController?.model = DatePickerModel(with: currentActivePageViewController?.activeDate ?? selectedDate, mode: pickerConfig.mode)
            }
            currentActivePageViewController?.reloadView()
        case .weekly where currentlyActiveDate.isInSameWeekAs(date):
            currentActivePageViewController?.selectCell(for: date)
            currentActivePageViewController?.reloadView()
        default:
            reload()
        }
    }

    public func expand() {
        guard pickerConfig.mode == .weekly else {
            return
        }
        toggleMode()
    }

    public func collapse() {
        guard pickerConfig.mode == .monthly else {
            return
        }
        toggleMode()
    }

    func highlightWeekday() {
        todayButton.isHidden = selectedDate.isInSameWeekAs(Date()) && pickerConfig.mode == .weekly
        if pickerConfig.mode == .monthly {
            weekTitle.shouldHighlightToday = selectedDate.isInSameMonthAs(Date())
        } else {
            weekTitle.shouldHighlightToday = selectedDate.isInSameWeekAs(Date())
        }
    }
}

extension DatePickerViewController: UIPageViewControllerDataSource {
    public func pageViewController(_: UIPageViewController, viewControllerBefore _: UIViewController) -> UIViewController? {
        return prevPage
    }

    public func pageViewController(_: UIPageViewController, viewControllerAfter _: UIViewController) -> UIViewController? {
        return nextPage
    }
}

extension DatePickerViewController: PickerDelegate {
    func updateMonthPickerHeight(to height: CGFloat) {
        delegate?.didUpdatePickerHeight(to: getPickerHeight(forDatesViewHeight: height))
    }

    private func getPickerHeight(forDatesViewHeight height: CGFloat) -> CGFloat {
        let heightToAdd: CGFloat = pickerConfig.viewConfiguration.pickerTitleMode == .none ? 15 : pickerDimensions.weekHeaderHeight + 15
        return height + heightToAdd
    }

    var activeDate: Date {
        return selectedDate
    }

    func updateMonth(title: String) {
        if pickerConfig.viewConfiguration.pickerTitleMode != .none {
            monthTitle.setMonthTitle(title)
        }
        delegate?.didUpdatePickerTitle(to: title)
    }

    func didSelect(date: Date) {
        selectedDate = date
        reload()
        delegate?.didSelect(date: date)
    }

    var lastSelectedDate: Date? {
        return selectedDate
    }
}

extension DatePickerViewController: SwipeActionDelegate {
    func didSwipe(_ direction: SwipeDirection) {
        switch direction {
        case .down:
            expand()
        case .up:
            collapse()
        }
    }
}

extension DatePickerViewController: WeekHeaderViewDelegate {
    func isOffHour(onDay day: Int) -> Bool {
        guard let dates = currentActivePageViewController?.model?.dates, dates.count > day else {
            return false
        }

        let datesToCheck: [Date]
        if pickerConfig.mode == .monthly {
            datesToCheck = dates.filter { $0.weekday == day }
        } else {
            datesToCheck = dates.filter { ($0.weekday == day) && ($0.weekOfYear == activeDate.weekOfYear) }
        }

        if pickerConfig.viewConfiguration.shouldDimWeekends {
            return datesToCheck.allSatisfy { $0.isInWeekend }
        }

        return datesToCheck.allSatisfy { dataSource?.isDayOff(on: $0) ?? false }
    }
}

extension DatePickerViewController: DatePickerCollectionViewPositioningDelegate {
    var width: CGFloat {
        view.frame.width
    }
}
