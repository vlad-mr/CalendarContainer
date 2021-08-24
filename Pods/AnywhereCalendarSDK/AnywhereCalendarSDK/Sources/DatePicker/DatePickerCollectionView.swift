//
//  DatePickerCollectionView.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 30/09/20.
//

import UIKit
import SwiftDate

func setUserDefaultRegion(_ region: Region) {
    SwiftDate.defaultRegion = region
}

public protocol DatePickerView: UIViewController {
    
    var pickerConfig: DatePickerConfig { get set }
    var dataSource: DatePickerDataSource? { get }
    var delegate: DatePickerDelegate? { get }
    var customizationProvider: DatePickerCustomizationProvider { get set }
    
    func reload()
    func load(for date: Date)
    func collapse()
    func expand()
}

public protocol AnywhereDatePickerView {
    func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> DatePickerCell?
    func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String)
    func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String)
}

protocol DatePickerCollectionViewPositioningDelegate {
    var width: CGFloat { get }
}

class DatePickerCollectionViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var layout: UICollectionViewFlowLayout!
    var collectionViewFrame: CGRect {
        CGRect(x: 0, y: topSpaceCollectionView, width: positioningDelegate?.width ?? self.view.frame.width, height: pickerHeight)
    }
    
    var model: DatePickerModel?
    lazy var pickerConfig: DatePickerConfig = .standard
    lazy var theme: DatePickerTheme = AnywherePickerTheme()
    
    var positioningDelegate: DatePickerCollectionViewPositioningDelegate?
    var currentViewMode: DatePickerMode = .monthly
    
    weak var delegate: PickerDelegate?
    var dataSource: DatePickerDataSource?
    
    var selectedIndexPath: IndexPath?
    
    var activeDate: Date = Date()
    
    var pickerHeight: CGFloat {
        guard let numberOfDates = self.model?.dates.count else {
            return pickerConfig.mode == .monthly ? 250 : 40
        }
        let numberOfRows = numberOfDates/7
        return CGFloat(numberOfRows) * pickerItemHeight + 10
    }
    
    var pickerItemHeight: CGFloat = 40
    
    var pickerItemWidth: CGFloat { collectionViewFrame.width / 7 }
    
    var topSpaceCollectionView: CGFloat {
        pickerConfig.mode == .monthly ? 0 : 0
    }
    
    lazy var customizationProvider: DatePickerCustomizationProvider = .standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    private func prepareView() {
        
        layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: pickerItemWidth, height: pickerItemHeight)
        layout.minimumLineSpacing = CGFloat(0)
        layout.minimumInteritemSpacing = CGFloat(0)
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.bounces = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        
        self.view.addSubview(collectionView)
        customizationProvider.pickerView = self
        customizationProvider.registerViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMonthTitle()
        updateMonthPickerHeight()
    }
    
    func updateMonthPickerHeight() {
        
        delegate?.updateMonthPickerHeight(to: pickerHeight)
    }
    
    private func updateMonthTitle() {
        
        let title = PickerUtils.getHeaderTitle(forDate: activeDate, mode: pickerConfig.mode)
        delegate?.updateMonth(title: title)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (pickerConfig.viewConfiguration.shouldSelectNextDateOnSwipe && pickerConfig.mode == .weekly) || delegate?.lastSelectedDate == activeDate {
            var dateToSelect = activeDate
            if let minDate = pickerConfig.minDate {
                dateToSelect = max(dateToSelect, minDate)
            }
            if let maxDate = pickerConfig.maxDate {
                dateToSelect = min(dateToSelect, maxDate)
            }
            selectCell(for: dateToSelect)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if collectionView.frame.width != collectionViewFrame.width {
            UIView.performWithoutAnimation {
                reloadView()
            }
        }
    }
    
    func selectCell(for date: Date) {
        if let index = model?.dates.firstIndex(of: date.dateAt(.startOfDay)) {
            let indexPath = IndexPath(row: index, section: 0)
            activeDate = date.dateAt(.startOfDay)
            collectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
}

extension DatePickerCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.dates.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = customizationProvider.dequeuePickerCell(forIndexPath: indexPath), let date = model?.dates[indexPath.row] else {
            return UICollectionViewCell()
        }
        cell.pickerConfig = pickerConfig
        cell.theme = theme
        cell.viewMode = currentViewMode
        var isInActiveMonth: Bool
        let isOutOfBounds = !pickerConfig.isDateInBounds(date)
        switch pickerConfig.viewConfiguration.nonActiveMonthDateMode {
        case .normal:
            isInActiveMonth = true
        case .hidden where (currentViewMode == .monthly || isOutOfBounds),
             .dimmed where (currentViewMode == .monthly || isOutOfBounds):
            isInActiveMonth = date.isInSameMonthAs(activeDate)
        default:
            isInActiveMonth = false
        }
        var isLastChosen = false
        if let lastSelectedDate = delegate?.lastSelectedDate {
            isLastChosen = date == lastSelectedDate
        }
        var isDayOff = dataSource?.isDayOff(on: date) ?? false
        if pickerConfig.viewConfiguration.shouldDimWeekends {
            isDayOff = date.isInWeekend
        }
        let numberOfEventsToShow = dataSource?.numberOfEvents(for: date) ?? 0
        let cellModel = DatePickerCellModel(date: date,
                                            isDayOff: isDayOff,
                                            isInActiveMonth: isInActiveMonth,
                                            isLastSelected: isLastChosen,
                                            numberOfEvents: numberOfEventsToShow,
                                            isOutOfBounds: isOutOfBounds)
        cell.set(model: cellModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let date = model?.dates[indexPath.row] else {
            return
        }
        // No Action for dates in previous or next month. Comment to provide action.
        guard date.isInSameMonthAs(activeDate) || currentViewMode == .weekly else {
            return
        }
        
        highlightItem(at: indexPath)
        delegate?.didSelect(date: date)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        guard let date = model?.dates[indexPath.row] else {
            return false
        }
        
        // No Action for dates in previous or next month. Comment to provide action.
        return (date.isInSameMonthAs(activeDate) || currentViewMode == .weekly) && pickerConfig.isDateInBounds(date)
    }
    
    func highlightItem(at indexPath: IndexPath) {
        
        guard let dayCell = self.collectionView(collectionView, cellForItemAt: indexPath) as? DayCell else {
            print("ERROR HERE: Unable to find the cell")
            return
        }
        
        if let lastSelectedDate = delegate?.lastSelectedDate, let index = model?.dates.firstIndex(of: lastSelectedDate),
           let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? DayCell, indexPath.row != index {
            cell.isSelected = false
        }
        
        dayCell.isSelected = true
    }
    
    func reloadView() {
        
        collectionView.removeFromSuperview()
        prepareView()
        updateMonthTitle()
        updateMonthPickerHeight()
    }
}

extension DatePickerCollectionViewController: AnywhereDatePickerView {
    
    func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> DatePickerCell? {
        collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? DatePickerCell
    }
    
    func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
}

extension UICollectionView {
    func reloadDataWithoutAnimation() {
        self.reloadItems(at: self.indexPathsForVisibleItems)
    }
}
