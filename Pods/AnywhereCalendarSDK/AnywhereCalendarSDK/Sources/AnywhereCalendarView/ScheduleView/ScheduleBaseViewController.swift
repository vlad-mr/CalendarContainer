//
//  ScheduleBaseViewController.swift
//  Anytime
//
//  Created by Deepika on 03/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit
#if canImport(CalendarUtils)
import CalendarUtils
#endif

protocol ScheduleCalendarScrollDelegate: class {
    func scrollScheduleView(_ scrollView: ScheduleTableVCProtocol)
}

public class ScheduleBaseViewController: UIViewController {
    
    public weak var actionDelegate: CalendarActionDelegate? {
        didSet {
            placeHolderView?.actionDelegate = actionDelegate
        }
    }
    public var dataProvider: CalendarDataProvider?
    
    private var activeDate: Date = Date() {
        didSet {
            scrollToDate(date: activeDate)
        }
    }
    
    lazy var config: ScheduleViewConfiguration = ScheduleViewConfiguration()
    var placeHolderView: ActionableView? = nil
    
    var viewModel: ScheduleVMProtocol?
    private var customizationProvider: FullCalendarCustomizationProvider?
    private lazy var dimension: ScheduleViewDimensions = ScheduleViewDimensions()
    private var calendarViewWidth: CGFloat {
        return self.config.shouldHaveStickyDate ? self.view.bounds.width - dimension.dateHeaderWidth : self.view.bounds.width
    }
    
    var dateView: ScheduleTableVCProtocol!
    var calendarItemView: ScheduleEventTableVCProtocol!
    
    private lazy var dateContainerView: UIView = configure(UIView()) {
        $0.frame = CGRect(x: 0, y: 0, width: self.dimension.dateHeaderWidth, height: self.view.frame.size.height)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var calendarItemContainerView: UIView = configure(UIView()) {
        $0.frame = CGRect(x: self.dimension.dateHeaderWidth, y: 0, width: self.calendarViewWidth, height: self.view.frame.size.height)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    /// These constraints are defined outside the activateConstraint method as their reference to adjust the width when toggling the placeholder
    lazy var dateViewWidthContraint: NSLayoutConstraint = self.dateContainerView.widthAnchor.constraint(equalToConstant: self.dimension.dateHeaderWidth)
    lazy var calendarItemViewWidthConstraint: NSLayoutConstraint = self.calendarItemContainerView.widthAnchor.constraint(equalToConstant: self.calendarViewWidth)

    convenience init(withConfiguration scheduleConfig: ScheduleViewConfiguration = ScheduleViewConfiguration(),
                     placeholderView: ActionableView? = nil,
                     dimension: ScheduleViewDimensions = ScheduleViewDimensions(),
                     dateView: ScheduleTableVCProtocol = ScheduleDateTableViewController(),
                     calendarItemView: ScheduleEventTableVCProtocol = ScheduleEventTableViewController()) {
        self.init()
        
        self.config = scheduleConfig
        self.dimension = dimension
        self.placeHolderView = placeholderView
        self.dateView = dateView
        self.calendarItemView = calendarItemView
        self.calendarItemView.config = scheduleConfig
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AnywhereCalendarView.mainSDK.theme.backgroundColor
        initializeViewModel()
        //NOTE: need to call addSubviews only after initializing the viewModel
        configureCustomizationProvider()
        addSubviews()
        activateContraints()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        UIView.animate(withDuration: 0.25) {
            self.calendarItemViewWidthConstraint.constant = self.config.shouldHaveStickyDate ? size.width - self.dimension.dateHeaderWidth : size.width
        }
    }
    
    private func configureCustomizationProvider() {
        
        if let customCustomizationProvider = dataProvider?.getCustomizationProvider(for: self) {
            self.customizationProvider = customCustomizationProvider
        } else {
            self.customizationProvider = FullCalendarCustomizationProvider(withCalendarView: self, calendarCells: [ScheduleEventCell.self], nibs: [], headerFooterViews: [], headerFooterNibs: [], placeholderView: nil, placeholderNib: nil, allDayEventView: nil, allDayEventNib: nil)
        }
        
        guard let customizationProvider = self.customizationProvider else {
            return
        }
        
        if customizationProvider.headerFooterNibs.isEmpty && customizationProvider.headerFooterViews.isEmpty {
            if config.shouldHaveStickyDate {
                customizationProvider.headerFooterNibs = [ScheduleDateCell.self]
            } else {
                customizationProvider.headerFooterViews = [NonStickyDateHeaderView.self]
            }
        }
        
        if customizationProvider.calendarCells.isEmpty && customizationProvider.calendarNibs.isEmpty {
            customizationProvider.calendarCells = [ScheduleEventCell.self]
        }
        
        self.customizationProvider?.registerCalendarViews()
        calendarItemView.customizationProvider = self.customizationProvider
        dateView.customizationProvider = self.customizationProvider
    }
    
    private func activateContraints() {
        
        /// constraints for the date view container
        if config.shouldHaveStickyDate {
            
            NSLayoutConstraint.activate([
                // constraints for the container views
                self.dateContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                self.dateContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.dateContainerView.topAnchor.constraint(equalTo: self.view.topAnchor),
                
                // constraints for the date view
                dateViewWidthContraint,
                self.dateView.view.bottomAnchor.constraint(equalTo: self.dateContainerView.bottomAnchor),
                self.dateView.view.leadingAnchor.constraint(equalTo: self.dateContainerView.leadingAnchor),
                self.dateView.view.topAnchor.constraint(equalTo: self.dateContainerView.topAnchor)
            ])
        }
        
        /// constraints for the calendar view container
        NSLayoutConstraint.activate([
            
            /// constraints for the container views
            self.calendarItemContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.calendarItemContainerView.leadingAnchor.constraint(equalTo: config.shouldHaveStickyDate ? self.dateContainerView.trailingAnchor : self.view.leadingAnchor),
            self.calendarItemContainerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            
            /// constraints for the calendar item view
            calendarItemViewWidthConstraint,
            self.calendarItemView.view.leadingAnchor.constraint(equalTo: self.calendarItemContainerView.leadingAnchor),
            self.calendarItemView.view.topAnchor.constraint(equalTo: self.calendarItemContainerView.topAnchor),
            self.calendarItemView.view.bottomAnchor.constraint(equalTo: self.calendarItemContainerView.bottomAnchor),
            self.calendarItemView.view.trailingAnchor.constraint(equalTo: self.calendarItemContainerView.trailingAnchor)
        ])
    }
    
    private func initializeViewModel() {
        
        guard let calendarDataSource = dataProvider?.getDataSource(forPage: 0) else {
            assertionFailure("Delegate is missing!")
            return
        }
        calendarDataSource.activeCalendarView = self
        self.viewModel = ScheduleViewModel(calendarDatasource: calendarDataSource, withConfig: config)
        
        if config.shouldHaveStickyDate {
            setupDateView()
        }
        setupEventView()
    }
    
    private func setupDateView() {
        dateView.viewModel = self.viewModel
        dateView.scrollDelegate = self
        dateView.dimension = self.dimension
    }
    
    private func setupEventView() {
        calendarItemView.viewModel = self.viewModel
        calendarItemView.actionDelegate = self.actionDelegate
        calendarItemView.scrollDelegate = self
        calendarItemView.config = config
        calendarItemView.dimension = self.dimension
    }
    
    private func addSubviews() {
        
        var subViews: [UIView] = []
        if config.shouldHaveStickyDate {
            embedViewController(dateView, toContainerView: dateContainerView)
            subViews.append(dateContainerView)
        }
        calendarItemView.config.shouldShowHeader = !self.config.shouldHaveStickyDate
        embedViewController(calendarItemView, toContainerView: calendarItemContainerView)
        subViews.append(calendarItemContainerView)
        self.view.addSubViews(subViews)
    }
    
    func togglePlaceholderIfNeeded() {
        
        guard config.placeholderConfig != .daily else {
            return
        }
        
        DispatchQueue.main.async {
            
            guard self.viewModel?.canShowPlaceHolder ?? false else {
                
                self.calendarItemView.set(backgroundView: nil)
                if self.config.shouldHaveStickyDate {
                    self.dateView.set(backgroundView: nil)
                    self.dateViewWidthContraint.constant = self.dimension.dateHeaderWidth
                }
                self.calendarItemViewWidthConstraint.constant  = self.calendarViewWidth
                self.calendarItemView.config.shouldShowEventView = true
                self.calendarItemView.reloadCalendar()
                return
            }
            
            self.calendarItemView.config.shouldShowEventView = false
            self.calendarItemView.reloadCalendar()
            self.dateViewWidthContraint.constant = 0
            self.calendarItemViewWidthConstraint.constant = self.view.frame.width
            self.calendarItemContainerView.frame.origin.x = 0
            if let placeHolderView = self.placeHolderView as? UIView {
                self.calendarItemView.set(backgroundView: placeHolderView)
            } else {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.size.height))
                label.text = "No Events Found!!"
                label.textColor = UIColor.black
                label.font = AnywhereCalendarView.mainSDK.font.header
                label.textAlignment = .center
                self.calendarItemView.set(backgroundView: label)
            }
        }
    }
}

extension ScheduleBaseViewController: CalendarView {
    
    public func setActiveDate(_ date: Date) {
        activeDate = date
        scrollToDate(date: date)
    }
    
    public func reloadCalendar() {
        dateView.reloadCalendar()
        calendarItemView.reloadCalendar()
        togglePlaceholderIfNeeded()
    }
    
    public func scrollToDate(date: Date, toLastItem: Bool = false) {
        guard let indexPath = viewModel?.getIndexPath(forDate: date, shouldGetLastRow: toLastItem) else {
            return
        }
        guard let numberOfRows = viewModel?.numberOfRows(at: indexPath.section), numberOfRows > indexPath.row else {
            return
        }
        DispatchQueue.main.async {
            let scrollPosition: UITableView.ScrollPosition = toLastItem ? .middle : .top
            self.calendarItemView.scrollToRow(at: indexPath, with: scrollPosition)
        }
    }
}

extension ScheduleBaseViewController: FullCalendarView {
    
    public func insertItems(at indexPaths: [IndexPath]) {
        indexPaths.forEach {
            self.insertCalendarItem(at: $0)
        }
    }
    
    public func deleteItems(at indexPaths: [IndexPath]) {
        indexPaths.forEach {
            self.deleteCalendarItem(at: $0)
        }
    }
    
    public func moveItem(from indexPath: IndexPath, to newIndexPath: IndexPath) {
        self.moveCalendarItem(from: indexPath, to: newIndexPath)
    }
    
    public func reloadItems(at indexPaths: [IndexPath]) {
        indexPaths.forEach {
            self.updateCalendarItem(at: $0)
        }
    }
    
    public func scrollToDate(date: Date) {
        scrollToDate(date: date, toLastItem: false)
    }
    
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> ConfigurableCell? {
        calendarItemView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        // registering only for the calendarView and not for the dateView
        calendarItemView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        
        guard let cell = cellClass as? ConfigurableTableViewCell.Type else {
            return
        }
        // registering only for the calendarView and not for the dateView
        calendarItemView.register(cell, forCellWithReuseIdentifier: identifier)
    }
    
    public func register(_ viewType: ConfigurableView.Type, forHeaderFooterViewReuseIdentifier identifier: String) {
        
        guard config.shouldHaveStickyDate else {
            calendarItemView.register(viewType, forHeaderFooterViewReuseIdentifier: identifier)
            return
        }
        dateView.register(viewType, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    public func register(_ nibType: CalendarHeaderFooterNib.Type, forHeaderFooterViewReuseIdentifier identifier: String) {
        
        guard config.shouldHaveStickyDate else {
            calendarItemView.register(nibType, forHeaderFooterViewReuseIdentifier: identifier)
            return
        }
        dateView.register(nibType, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    public func dequeueReusableHeaderFooterView(withReuseIdentifier identifier: String, for section: Int) -> ConfigurableView? {
        
        guard config.shouldHaveStickyDate else {
            return calendarItemView.dequeueReusableHeaderFooterView(withReuseIdentifier: identifier, for: section)
        }
        return dateView.dequeueReusableHeaderFooterView(withReuseIdentifier: identifier, for: section)
    }
    
}

extension ScheduleBaseViewController: ScheduleCalendarScrollDelegate {
    
    func scrollScheduleView(_ scrollView: ScheduleTableVCProtocol) {
        guard config.shouldHaveStickyDate else {
            return
        }
        
        guard calendarItemView == scrollView else {
            calendarItemView.contentOffset = scrollView.contentOffset
            return
        }
        dateView.contentOffset = scrollView.contentOffset
    }
    
}
