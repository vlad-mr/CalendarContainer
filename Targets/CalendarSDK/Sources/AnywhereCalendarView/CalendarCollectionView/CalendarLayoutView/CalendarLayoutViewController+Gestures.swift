//
//  CalendarLayoutViewController+Gestures.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 18/08/20.
//

import UIKit

extension CalendarLayoutViewController: UIGestureRecognizerDelegate {
}

extension CalendarLayoutViewController {
    
   @objc func removeSelectedSlot() {
        tappedView.removeFromSuperview()
    }
    
    func addGesturesToCalendarView() {
        calendarCollectionView.addGestureRecognizer(tapGesture)
        //        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(gesture:)))
        //        calendarCollectionView.addGestureRecognizer(longPress)
    }
    
    @objc func longPressAction(gesture: UILongPressGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            let location = gesture.location(in: calendarCollectionView)
            markTappedLocation(location)
        case .changed:
            guard let originalCenter = initialCenter else {
                return
            }
            
            let point = gesture.location(in: calendarCollectionView)
            
            // Calculate new center position
            var newSize = tappedView.frame.size;
            var sizeToScroll = newSize
            sizeToScroll.height = point.y - originalCenter.y
            newSize.height = max(CGFloat((Int(point.y - originalCenter.y)/30) * 30 + 30), 15)
            
            // Update view center
            tappedView.frame.size = newSize
            calendarCollectionView.scrollRectToVisible(CGRect(origin: initialCenter ?? point, size: newSize), animated: true)
        case .ended:
            guard let view = gesture.view else {
                return
            }
            performActionForSelectedLocation()
            initialCenter = view.center
            
        default:
            return
        }
    }
    
    @objc func calendarViewTapped(sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: calendarCollectionView)
        
        if calendarCollectionView.indexPathForItem(at: location) != nil {
            self.removeSelectedSlot()
            return
        }
        markTappedLocation(location)
        performActionForSelectedLocation()
    }
    
    func performActionForSelectedLocation() {
        
        guard let selectedDate = dateForLocationSelected(location: tappedView.frame.origin) else {
            return
        }
        let selectedTimeInMins = getTimeForLocation(tappedView.frame.origin)
        let duration = getDurationForHeight(tappedView.frame.height)
        actionDelegate?.didTapCalendar(on: selectedDate, atTime: selectedTimeInMins, duration: duration, notifyCompletion: removeSelectedSlot)
    }
    
    func getTimeForLocation(_ location: CGPoint) -> Int {
        let count = Int(location.y / viewConfig.slotSize.divisionHeight)
        let timeInMins = count * viewConfig.slotSize.rawValue
        return timeInMins
    }
    
    func getDurationForHeight(_ height: CGFloat) -> Int {
        let numberOfDivisionsCovered = Int(height / viewConfig.slotSize.divisionHeight)
        let durationInMinutes = numberOfDivisionsCovered * viewConfig.slotSize.minutes
        return durationInMinutes
    }
    
    private func markTappedLocation(_ location: CGPoint) {
        
        removeSelectedSlot()
        if let layout = calendarCollectionView.collectionViewLayout as? CalendarCollectionViewLayout {
            
            let xPoint = (location.x / layout.sectionWidth).rounded(.towardZero) * layout.sectionWidth
            let yPoint = (location.y / viewConfig.slotSize.divisionHeight).rounded(.towardZero) * viewConfig.slotSize.divisionHeight
            tappedView.frame = CGRect(x: xPoint, y: yPoint, width: layout.sectionWidth, height: viewConfig.slotSize.divisionHeight)
        } else {
            tappedView.frame = CGRect(x: location.x - 5, y: location.y - viewConfig.slotSize.divisionHeight/2, width: 10, height: viewConfig.slotSize.divisionHeight)
        }
        tappedView.layer.borderWidth = 1
        tappedView.layer.borderColor = AnywhereCalendarView.mainSDK.theme.selectorColor.cgColor
        tappedView.backgroundColor = AnywhereCalendarView.mainSDK.theme.selectorColor.withAlphaComponent(0.3)
        initialCenter = tappedView.center
        self.calendarCollectionView.addSubview(tappedView)
    }
    
    private func sectionForLocationSelected(_ location: CGPoint) -> Int {
        let numberOfSections = CGFloat(layoutType.numberOfDays)
        let dayWidth = calendarCollectionView.frame.width / numberOfSections
        return Int((location.x / dayWidth).rounded())
    }
    
    private func dateForLocationSelected(location: CGPoint) -> Date? {
        let dateIndex = sectionForLocationSelected(location)
        print("DATE INDEX: \(dateIndex)")
        return date(forSection: dateIndex)
    }
}
