//
//  CalendarLayoutViewController.swift
//  Anytime
//
//  Created by Vignesh on 18/02/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import CoreData
import Foundation
import SwiftDate
import UIKit
#if canImport(CalendarUtils)
    import CalendarUtils
#endif

class CalendarLayoutViewController: UIViewController {
    // Outlets
    @IBOutlet public var calendarCollectionView: UICollectionView!

    @IBOutlet var dateHeaderStackView: DateHeaderStackView!
    @IBOutlet var excessAllDayEventIndicatorStackView: ExcessAllDayEventStackView!
    @IBOutlet var allDayEventStackView: AllDayEventStackView!

    @IBOutlet var collapserIndicatorButton: UIButton!
    @IBOutlet var separatorView: UIView!

    @IBOutlet var calendarCollectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var excessAllDayEventTopConstraint: NSLayoutConstraint!

    @IBOutlet var excessAllDayEventIndicatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet var collapserIndicatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet var allDayViewHeightContraint: NSLayoutConstraint!
    @IBOutlet var dateHeaderHeightConstraint: NSLayoutConstraint!

    weak var constraintModifier: ConstraintModifier?
    var shouldShowDayOff: Bool = false
    var isHeaderExpanded: Bool = false {
        didSet {
            toggleHeaderExpansionState()
        }
    }

    var shouldShowExpanderView = false {
        didSet {
            adjustExapansionView()
        }
    }

    var headerViewHeight: CGFloat {
        guard shouldShowExpanderView else {
            return dateHeaderHeight
        }
        return dateHeaderHeightBasedOnExpansionState + collapserIndicatorHeight + excessAllDayEventIndicatorHeight
    }

    var dateHeaderHeight: CGFloat {
        return getHeaderHeight(shouldShowDateHeader: viewConfig.shouldShowDateHeader, shouldShowAllDayEvents: !viewConfig.shouldHaveFloatingAllDayEvent, shouldShowDayOff: !viewConfig.shouldHaveFloatingDayOff)
    }

    var dateHeaderHeightBasedOnExpansionState: CGFloat {
        guard !isHeaderExpanded else {
            return dateHeaderHeight
        }
        let numberOfExcessEvents = numberOfAllDayEvents - viewConfig.numberOfAllDayEventInCollapsedMode
        let heightOfHeaderViewToBeHidden = CGFloat(numberOfExcessEvents) * viewConfig.calendarDimensions.allDayEventHeight
        return dateHeaderHeight - heightOfHeaderViewToBeHidden
    }

    var collapserIndicatorHeight: CGFloat {
        guard shouldShowExpanderView, shouldShowCollapserIndicator else {
            return 0
        }
        return 20
    }

    var excessAllDayEventIndicatorHeight: CGFloat {
        guard shouldShowExpanderView, shouldShowExcessAllDayEventIndicator else {
            return 0
        }
        return 20
    }

    var shouldShowCollapserIndicator: Bool = false {
        didSet {
            guard isViewLoaded else {
                return
            }
            collapserIndicatorHeightConstraint.constant = collapserIndicatorHeight
        }
    }

    var shouldShowExcessAllDayEventIndicator: Bool = false {
        didSet {
            guard isViewLoaded else {
                return
            }
            excessAllDayEventIndicatorHeightConstraint.constant = excessAllDayEventIndicatorHeight
            excessAllDayEventTopConstraint.constant = headerViewHeight - (excessAllDayEventIndicatorHeight + collapserIndicatorHeight)
        }
    }

    var initialCenter: CGPoint?

    var numberOfAllDayEvents: Int = 0
    weak var layoutDelegate: CalendarLayoutDelegate? {
        didSet {
            self.collectionViewLayout.shouldShowTimeHeader = false
        }
    }

    weak var actionDelegate: CalendarActionDelegate? {
        didSet {
            guard isViewLoaded else {
                return
            }
            dateHeaderStackView.actionDelegate = actionDelegate
            allDayEventStackView.actionDelegate = actionDelegate
        }
    }

    var viewConfig = CalendarViewConfiguration() {
        didSet {
            collectionViewLayout.viewConfiguration = viewConfig

            guard isViewLoaded else {
                return
            }

            setupHeaders()
        }
    }

    var layoutType: CalendarLayoutType = .daily

    var activePageNumber: Int = 0 {
        didSet {
            if isViewLoaded {
                calendarCollectionView.reloadData()
            }
        }
    }

    public var dataSource: FullCalendarDataSource? {
        didSet {
            guard let dataSource = self.dataSource else {
                return
            }
            let datesToDisplay = dataSource.activeDates
            guard datesToDisplay.count == layoutType.numberOfDays else {
                preconditionFailure("Number of Days supplied (\(datesToDisplay.count)) is not equivalent to the expected days (\(layoutType.numberOfDays)) in current view")
            }
            collectionViewLayout.numberOfDays = datesToDisplay.count
            collectionViewLayout.delegate = self
            self.dataSource?.activeCalendarView = self
            setupDayOff()
            if isViewLoaded {
                calendarCollectionView.reloadData()
                dateHeaderStackView.dates = datesToDisplay
                allDayEventStackView.dates = datesToDisplay
                excessAllDayEventIndicatorStackView.dates = datesToDisplay
                adjustHeaderView()
            }
        }
    }

    public lazy var customizationProvider = FullCalendarCustomizationProvider(withCalendarView: self, calendarCells: [AnytimeEventCell.self], nibs: [], headerFooterViews: [], headerFooterNibs: [DateHeaderView.self], placeholderView: nil, placeholderNib: nil, allDayEventView: nil, allDayEventNib: nil)

    func setupHeaders() {
        dateHeaderStackView.config = viewConfig
        allDayEventStackView.config = viewConfig
        excessAllDayEventIndicatorStackView.config = viewConfig
    }

    func setupDayOff() {
        guard let dataSource = dataSource else {
            return
        }

        for section in 0 ..< layoutType.numberOfDays where dataSource.shouldShowDayOff(forSection: section) {
            shouldShowDayOff = true
            break
        }
    }

    func setupAllDayEvent() {
        numberOfAllDayEvents = 0
        guard let dataSource = dataSource else {
            return
        }

        for section in 0 ..< layoutType.numberOfDays {
            let noOfAllDayEvent = dataSource.getAllDayEvents(forSection: section).count
            guard numberOfAllDayEvents < noOfAllDayEvent else {
                continue
            }
            numberOfAllDayEvents = noOfAllDayEvent
        }
        shouldShowExpanderView = numberOfAllDayEvents > viewConfig.numberOfAllDayEventInCollapsedMode
    }

    lazy var tappedView: UIView = {
        let view = UIView()
        view.backgroundColor = AnywhereCalendarView.mainSDK.theme.selectorColor.withAlphaComponent(0.3)
        return view
    }()

    private lazy var collectionViewLayout = configure(CalendarCollectionViewLayout()) {
        $0.numberOfDays = dataSource?.activeDates.count ?? 7
        $0.shouldShowTimeHeader = self.layoutDelegate == nil
        $0.viewConfiguration = self.viewConfig
        $0.delegate = self
    }

    lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(calendarViewTapped))
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        return gesture
    }()

    private var diagonalView: UIView {
        let view = viewConfig.shouldHaveStripedOffHours ? DiagonalLinesView(frame: calendarCollectionView.frame) : UIView(frame: calendarCollectionView.frame)
        view.backgroundColor = AnywhereCalendarView.mainSDK.theme.offHoursBackgroundColor
        return view
    }

    private func updateCalendarDimensionsInSubviews() {
        if let activeDates = dataSource?.activeDates, activeDates.isNotEmpty {
            dateHeaderStackView.calendarDimensions = viewConfig.calendarDimensions
            allDayEventStackView.calendarDimensions = viewConfig.calendarDimensions
            excessAllDayEventIndicatorStackView.calendarDimensions = viewConfig.calendarDimensions
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        addGesturesToCalendarView()
        dataSource?.activeCalendarView = self
        calendarCollectionView.reloadData()
        setupView()
        addObservers()
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlingOrientationChanges), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc func handlingOrientationChanges() {
        updateHeaderView()
        invalidateLayout()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupView() {
        setBackgroundColor()
        setupHeaders()
        setCollapserImage()
        addActionToCollapserButton()
        calendarCollectionViewTopConstraint.constant = headerViewHeight
        excessAllDayEventIndicatorStackView.delegate = self
        adjustHeaderView()
    }

    private func addActionToCollapserButton() {
        collapserIndicatorButton.addTarget(self, action: #selector(didTapCollapserIndicator), for: .touchUpInside)
    }

    private func setCollapserImage() {
        guard let image = UIImage.getImage(withName: "Up") else {
            return
        }
        collapserIndicatorButton.setImage(image, for: .normal)
    }

    private func adjustExapansionView() {
        isHeaderExpanded = false
        guard !shouldShowExpanderView else {
            return
        }
        shouldShowCollapserIndicator = false
        shouldShowExcessAllDayEventIndicator = false
    }

    private func toggleHeaderExpansionState() {
        guard shouldShowExpanderView else {
            return
        }
        shouldShowCollapserIndicator = isHeaderExpanded
        shouldShowExcessAllDayEventIndicator = !isHeaderExpanded

        guard isViewLoaded else {
            return
        }
        calendarCollectionViewTopConstraint.constant = headerViewHeight
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        constraintModifier?.updateTopConstraint(withConstant: headerViewHeight, sender: self)
    }

    private func setBackgroundColor() {
        view.backgroundColor = AnywhereCalendarView.mainSDK.theme.backgroundColor
        separatorView.backgroundColor = AnywhereCalendarView.mainSDK.theme.daySeparatorColor
        excessAllDayEventIndicatorStackView.backgroundColor = AnywhereCalendarView.mainSDK.theme.backgroundColor
        collapserIndicatorButton.backgroundColor = AnywhereCalendarView.mainSDK.theme.backgroundColor
    }

    @objc func didTapCollapserIndicator() {
        didTap(onView: collapserIndicatorButton)
    }

    func getHeaderHeight(shouldShowDateHeader: Bool, shouldShowAllDayEvents: Bool, shouldShowDayOff: Bool) -> CGFloat {
        let dateHeaderHeight = shouldShowDateHeader ? viewConfig.calendarDimensions.dateHeaderHeight : 0
        let allDayEventHeight = shouldShowAllDayEvents ? CGFloat(numberOfAllDayEvents) * viewConfig.calendarDimensions.allDayEventHeight : 0
        let dayOffHeight = shouldShowDayOff && self.shouldShowDayOff ? viewConfig.calendarDimensions.dayOffViewHeight : 0

        return dateHeaderHeight + max(allDayEventHeight, dayOffHeight)
    }

    func adjustHeaderView() {
        setupAllDayEvent()
        updateHeaderView()
        updateHeaderConstraints()
    }

    private func updateHeaderConstraints() {
        dateHeaderHeightConstraint.constant = dateHeaderHeight
        allDayViewHeightContraint.constant = getHeaderHeight(shouldShowDateHeader: false, shouldShowAllDayEvents: viewConfig.shouldHaveFloatingAllDayEvent, shouldShowDayOff: viewConfig.shouldHaveFloatingDayOff)
        calendarCollectionViewTopConstraint.constant = headerViewHeight
        constraintModifier?.updateTopConstraint(withConstant: headerViewHeight, sender: self)
    }

    public func scrollToCurrentTimeLine() {
        guard indexForCurrentTimeLine != nil else {
            return
        }
        calendarCollectionView.setContentOffset(CGPoint(x: 0, y: collectionViewLayout.scrollPositionForCurrentTime), animated: true)
    }

    @objc func setBackgroundView() {
        guard layoutDelegate != nil else {
            return
        }
        calendarCollectionView.backgroundView = diagonalView
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        constraintModifier?.updateTopConstraint(withConstant: headerViewHeight)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentOffset()
    }

    func updateContentOffset() {
        if let scrollOffset = layoutDelegate?.calendarScrollOffset {
            calendarCollectionView.setContentOffset(scrollOffset, animated: false)
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let dates = dataSource?.activeDates {
            actionDelegate?.didSwipeToCalendar(withDates: dates)
        }
        let secondsToWait = TimeInterval(60 - Date().second)
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToWait) {
            self.updateCurrentTimeLine()
            _ = Timer.scheduledTimer(timeInterval: 60.0,
                                     target: self,
                                     selector: #selector(self.updateCurrentTimeLine),
                                     userInfo: nil,
                                     repeats: true)
        }
    }

    @objc public func updateCurrentTimeLine() {
        DispatchQueue.main.async {
            if let layout = self.calendarCollectionView.collectionViewLayout
                as? CalendarCollectionViewLayout
            {
                layout.updateCurrentTimeLine()
            }
        }
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeSelectedSlot()
    }

    func updateHeaderView() {
        dateHeaderStackView.updateView()
        allDayEventStackView.updateView()
        excessAllDayEventIndicatorStackView.updateView()
    }

    public func reloadLayout() {
        invalidateLayout()
        calendarCollectionView.reloadData()
    }

    func invalidateLayout() {
        guard isViewLoaded, let layout = calendarCollectionView.collectionViewLayout as? CalendarCollectionViewLayout else {
            return
        }
        DispatchQueue.main.async {
            layout.invalidateLayoutCache()
        }
    }
}

extension CalendarLayoutViewController: UICollectionViewDataSource {
    public func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        getCalendarCell(forItemAt: indexPath)
    }

    public func numberOfSections(in _: UICollectionView) -> Int {
        return layoutType.numberOfDays
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let numberOfItems = dataSource?.numberOfItems(inSection: section) else {
            return 0
        }
        return numberOfItems
    }
}

extension CalendarLayoutViewController {
    public func reloadView() {
        guard let layout = calendarCollectionView.collectionViewLayout as? CalendarCollectionViewLayout else {
            return
        }
        layout.reloadCells()
        calendarCollectionView.reloadData()
        reloadLayout()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        layoutDelegate?.calendarViewDidScroll(scrollView)
    }
}

// EXTENSION TO INITIALIZE THE CALENDAR VIEW
extension CalendarLayoutViewController {
    func initializeCollectionView() {
        calendarCollectionView.delegate = self
        calendarCollectionView.setCollectionViewLayout(collectionViewLayout, animated: true)
        calendarCollectionView.showsVerticalScrollIndicator = false
        calendarCollectionView.canCancelContentTouches = false
        customizationProvider.registerCalendarViews()
        registerSupplementaryViews()
        registerDecorationViews()
        calendarCollectionView.clipsToBounds = true
        calendarCollectionView.alwaysBounceVertical = true
        calendarCollectionView.isUserInteractionEnabled = true
        calendarCollectionView.dataSource = self

        dateHeaderStackView.customizationProvider = self
        allDayEventStackView.customizationProvider = self
        excessAllDayEventIndicatorStackView.customizationProvider = self
        dateHeaderStackView.actionDelegate = actionDelegate
        if let dataSource = self.dataSource {
            dateHeaderStackView.dates = dataSource.activeDates
            allDayEventStackView.dates = dataSource.activeDates
            excessAllDayEventIndicatorStackView.dates = dataSource.activeDates
            self.dataSource?.activeCalendarView = self
        }
        setBackgroundView()
    }

    func registerSupplementaryViews() {
        calendarCollectionView.register(RowHeader.self,
                                        forSupplementaryViewOfKind: FullCalendarSupplementaryViewKind.rowHeader.rawValue,
                                        withReuseIdentifier: FullCalendarSupplementaryViewKind.rowHeader.rawValue)
        calendarCollectionView.register(MonthHeader.self,
                                        forSupplementaryViewOfKind: FullCalendarSupplementaryViewKind.monthHeader.rawValue,
                                        withReuseIdentifier: FullCalendarSupplementaryViewKind.monthHeader.rawValue)
        // calendarCollectionView.register(HourLabelView.self,
        //                                        forSupplementaryViewOfKind: AnytimeCalendarSubviewTypes.hourLabelView,
        //                                        withReuseIdentifier: AnytimeCalendarSubviewTypes.hourLabelView)
    }

    func registerDecorationViews() {
        calendarCollectionView.collectionViewLayout.register(OutOfBoundsView.self,
                                                             forDecorationViewOfKind: FullCalendarDecorationViewKind.outOfBoundsView.rawValue)
        calendarCollectionView.collectionViewLayout.register(HorizontalGridLine.self,
                                                             forDecorationViewOfKind: FullCalendarDecorationViewKind.verticalSeparator.rawValue)
        calendarCollectionView.collectionViewLayout.register(DashedHorizontalGridLine.self,
                                                             forDecorationViewOfKind: FullCalendarDecorationViewKind.horizonalSeparator.rawValue)
        calendarCollectionView.collectionViewLayout.register(WorkingHoursDivLine.self,
                                                             forDecorationViewOfKind: FullCalendarDecorationViewKind.workingHoursDivLine.rawValue)
        calendarCollectionView.collectionViewLayout.register(OffHourGridLine.self,
                                                             forDecorationViewOfKind: FullCalendarDecorationViewKind.offHoursGridLine.rawValue)
        calendarCollectionView.collectionViewLayout.register(WorkingHoursView.self,
                                                             forDecorationViewOfKind: FullCalendarDecorationViewKind.workingHoursView.rawValue)
        calendarCollectionView.collectionViewLayout.register(CurrentTimeIndicatorLine.self,
                                                             forDecorationViewOfKind: FullCalendarDecorationViewKind.currentTimeIndicatorLine.rawValue)
        calendarCollectionView.collectionViewLayout.register(CurrentTimeIndicatorVerticalLine.self,
                                                             forDecorationViewOfKind: FullCalendarDecorationViewKind.currentTimeIndicatorCircle.rawValue)
        calendarCollectionView.collectionViewLayout.register(WorkingHoursDivLine.self,
                                                             forDecorationViewOfKind: FullCalendarDecorationViewKind.workingHoursDivLine.rawValue)
    }
}
