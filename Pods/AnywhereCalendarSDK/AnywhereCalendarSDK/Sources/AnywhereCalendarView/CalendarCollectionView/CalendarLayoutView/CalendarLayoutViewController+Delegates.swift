//
//  CalendarLayoutViewController+Delegates.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 18/08/20.
//

import UIKit
#if canImport(CalendarUtils)
import CalendarUtils
#endif

extension CalendarLayoutViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        guard let calendarItem = calendarItem(forIndexPath: indexPath) else {
            return
        }
        actionDelegate?.didSelectCell(for: calendarItem)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let supplementaryElementKind = FullCalendarSupplementaryViewKind(rawValue: kind) else {
            return UICollectionReusableView()
        }
        switch supplementaryElementKind {
        case .rowHeader:
            guard let rowHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FullCalendarSupplementaryViewKind.rowHeader.identifier, for: indexPath) as? RowHeader else {
                return UICollectionReusableView()
            }
            rowHeader.timeLabel?.text = (indexPath.item > 0 && indexPath.item < 24) ? DateUtilities.getTimeString(indexPath.item) : ""
            return rowHeader
        default:
            return UICollectionReusableView()
        }
    }
}
extension CalendarLayoutViewController: DateHeaderCustomizationDelegate {
    
    func getDateHeaderHeight(forDate date: Date) -> CGFloat {
        
        let noOfAllDayEventsForDate = getNoOfAllDayEvents(forDate: date)
        let heightToBeReduced = CGFloat(self.numberOfAllDayEvents - noOfAllDayEventsForDate) * viewConfig.calendarDimensions.allDayEventHeight
        return dateHeaderHeight - heightToBeReduced
    }
    func shouldShowDayOff(forDate date: Date) -> Bool {
        
        guard let dataSource = dataSource, let section = dataSource.activeDates.firstIndex(of: date) else {
            return false
        }
        
        return dataSource.shouldShowDayOff(forSection: section)
    }
    
    func getHeaderView(forDate date: Date) -> ConfigurableDateHeader? {
        
        guard let headerView = customizationProvider.dequeueCalendarHeader(at: 0) as? ConfigurableDateHeader else {
            return nil
        }
        headerView.configure(date, at: 0)
        headerView.actionDelegate = self.actionDelegate
        return headerView
    }
    
    func getDayOffView(forDate date: Date) -> ConfigurableAllDayEventView? {
        
        guard let dataSource = dataSource, let section = dataSource.activeDates.firstIndex(of: date), dataSource.shouldShowDayOff(forSection: section) else {
            return nil
        }
        
        return customizationProvider.getViewForDayOff(at: section)
    }
    
    func getAllDayEventViews(forDate date: Date) -> [TappableAllDayEventView] {
        
        guard let dataSource = dataSource, let section = dataSource.activeDates.firstIndex(of: date) else {
            return []
        }
        
        let allDayEvents = dataSource.getAllDayEvents(forSection: section)
        
        return allDayEvents.compactMap {
            
            guard let allDayEventView = customizationProvider.getViewForAllDayEvent(at: section) as? TappableAllDayEventView else {
                return nil
            }
            allDayEventView.actionDelegate = self.actionDelegate
            
            if allDayEventView.action == nil {
                allDayEventView.action = allDayEventView.tapAction
            }
            allDayEventView.configure(withEvent: $0)
            allDayEventView.translatesAutoresizingMaskIntoConstraints = false
            allDayEventView.setupHeightAnchor(withConstant: viewConfig.calendarDimensions.allDayEventHeight)
            return allDayEventView
        }
    }
    
    func getNoOfAllDayEvents(forDate date: Date) -> Int {
        
        guard let dataSource = dataSource, let section = dataSource.activeDates.firstIndex(of: date) else {
            return 0
        }
        
        return dataSource.getAllDayEvents(forSection: section).count
    }
}


extension CalendarLayoutViewController: CalendarCollectionViewLayoutDelegate {
    
    public func userAvailability(forSection: Int) -> [WorkingHour] {
        dataSource?.getAvailability(forSection: forSection) ?? []
    }
    
    public var indexForCurrentTimeLine: Int? {
        dataSource?.activeDates.firstIndex(where: { $0.isToday })
    }
}

extension CalendarLayoutViewController: HeaderExpansionDelegate {
    
    func didTap(onView view: UIView) {
        isHeaderExpanded = view == excessAllDayEventIndicatorStackView
    }
}
