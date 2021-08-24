//
//  CalendarBasePageViewController.swift
//  AnywhereCalendarView
//
//  Created by Vignesh on 04/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation

import UIKit

class CalendarPageViewController: UIPageViewController {
    private let defaultPageNumber = 0
    weak var constraintModifier: ConstraintModifier?
    var calendarDataProvider: CalendarDataProvider? {
        didSet {
            setDataSourceForAllActiveViews()
            setCustomizationProviderForAllActiveViews()
        }
    }

    weak var calendarActionDelegate: CalendarActionDelegate? {
        didSet {
            setActionDelegateForAllActiveViews()
        }
    }

    var calendarLayoutDelegate: CalendarLayoutDelegate? {
        didSet {
            setLayoutDelegateForAllActiveViews()
        }
    }

    private(set) var currentCalendarView: CalendarLayoutViewController?

    var activeCalendarViews: [CalendarLayoutViewController] {
        return viewControllers as? [CalendarLayoutViewController] ?? []
    }

    var viewConfig = CalendarViewConfiguration() {
        didSet {
            setConfigForAllActiveViews()
        }
    }

    var layoutType: CalendarLayoutType = .daily {
        didSet {
            setLayoutTypeForAllActiveViews()
        }
    }

    var startDateOfVisibleView: Date? {
        return currentCalendarView?.dataSource?.activeDates.first
    }

    func doesVisiblePageContain(date: Date) -> Bool {
        guard let activeDates = currentCalendarView?.dataSource?.activeDates else {
            return false
        }
        for activeDate in activeDates where activeDate.isSameAs(date: date) {
            return true
        }

        return false
    }

    func isPageActive(_ pageNumber: Int) -> Bool {
        let views = activeCalendarViews.filter { $0.activePageNumber == pageNumber }
        return views.count > 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    public func setDefaultView() {
        var direction: NavigationDirection = .forward
        if let activePage = currentCalendarView?.activePageNumber, activePage > 0 {
            direction = .reverse
        }
        currentCalendarView = createNewCalendar(pageNumber: defaultPageNumber)
        setViewControllers([currentCalendarView!], direction: direction, animated: true, completion: nil)
    }

    public func gotoNextPage() {
        let nextPageNumber = (currentCalendarView?.activePageNumber ?? defaultPageNumber) + 1
        currentCalendarView = createNewCalendar(pageNumber: nextPageNumber)
        setViewControllers([currentCalendarView!], direction: .forward, animated: true, completion: nil)
    }

    public func gotoPrevPage() {
        let prevPageNumber = (currentCalendarView?.activePageNumber ?? defaultPageNumber) - 1
        currentCalendarView = createNewCalendar(pageNumber: prevPageNumber)
        setViewControllers([currentCalendarView!], direction: .reverse, animated: true, completion: nil)
    }

    public func reloadAllPages() {
        activeCalendarViews.forEach {
            $0.reloadView()
        }
    }

    func createNewCalendar(pageNumber: Int) -> CalendarLayoutViewController? {
        let calendarLayoutView = CalendarViewControllers.calendarLayoutView
        calendarLayoutView.view.frame = view.bounds
        calendarLayoutView.activePageNumber = pageNumber
        let dataSource = calendarDataProvider?.getDataSource(forPage: pageNumber)
        dataSource?.activeCalendarView = calendarLayoutView
        calendarLayoutView.layoutType = layoutType
        calendarLayoutView.dataSource = dataSource
        calendarLayoutView.actionDelegate = calendarActionDelegate
        calendarLayoutView.layoutDelegate = calendarLayoutDelegate
        calendarLayoutView.viewConfig = viewConfig
        calendarLayoutView.constraintModifier = constraintModifier
        if let customizationProvider = calendarDataProvider?.getCustomizationProvider(for: calendarLayoutView) {
            calendarLayoutView.customizationProvider = customizationProvider
        }
        calendarLayoutView.initializeCollectionView()
        return calendarLayoutView
    }

    func setConfigForAllActiveViews() {
        activeCalendarViews.forEach { $0.viewConfig = self.viewConfig }
    }

    private func setDataSourceForAllActiveViews() {
        activeCalendarViews.forEach { $0.dataSource = self.calendarDataProvider?.getDataSource(forPage: $0.activePageNumber)
        }
    }

    private func setCustomizationProviderForAllActiveViews() {
        guard let dataProvider = calendarDataProvider else {
            return
        }
        activeCalendarViews.forEach {
            guard let customizationProvider = dataProvider.getCustomizationProvider(for: $0) else {
                return
            }
            $0.customizationProvider = customizationProvider
            $0.customizationProvider.registerCalendarViews()
        }
    }

    private func setActionDelegateForAllActiveViews() {
        activeCalendarViews.forEach { $0.actionDelegate = self.calendarActionDelegate }
    }

    private func setLayoutDelegateForAllActiveViews() {
        activeCalendarViews.forEach { $0.layoutDelegate = self.calendarLayoutDelegate }
    }

    private func setLayoutTypeForAllActiveViews() {
        activeCalendarViews.forEach { $0.layoutType = self.layoutType }
    }

    public func setScrollOffSetToVisibleView(_ offSet: CGPoint) {
        currentCalendarView?.calendarCollectionView.contentOffset = offSet
    }

    public func removeModelForAllVisibleViewControllers() {
        activeCalendarViews.forEach { $0.dataSource = nil }
    }
}

// MARK: UIPageViewControllerDelegate

extension CalendarPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating _: Bool,
                            previousViewControllers _: [UIViewController],
                            transitionCompleted completed: Bool)
    {
        guard completed else {
            return
        }
        currentCalendarView = pageViewController.viewControllers?.first as? CalendarLayoutViewController
    }
}

// MARK: UIPageViewControllerDataSource

extension CalendarPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let adjecentViewController = viewController as? CalendarLayoutViewController else {
            return nil
        }
        return createNewCalendar(pageNumber: adjecentViewController.activePageNumber + 1)
    }

    func pageViewController(_: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        guard let adjecentViewController = viewController as? CalendarLayoutViewController else {
            return nil
        }
        return createNewCalendar(pageNumber: adjecentViewController.activePageNumber - 1)
    }
}

extension CalendarPageViewController: CalendarLayoutDelegate {
    var calendarScrollOffset: CGPoint? {
        calendarLayoutDelegate?.calendarScrollOffset
    }

    func calendarViewDidScroll(_ scrollView: UIScrollView) {
        calendarLayoutDelegate?.calendarViewDidScroll(scrollView)
    }
}
