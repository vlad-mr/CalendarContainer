//
//  AnytimeCalLayoutAttributeGenerator.swift
//  Anytime
//
//  Created by Vignesh on 20/02/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

class AnytimeCalLayoutAttributesGenerator: LayoutAttributesGenerator {
    
    private let sectionWidth: CGFloat
    private let sectionHeight: CGFloat
    private let slotSize: CalendarSlotSize
    //    var hourHeight: CGFloat = 60.0
    var rowHeaderWidth: CGFloat = 0 //50.0
    //    var columnHeaderHeight: CGFloat = 63.0
    private let onlyFirstVerticalSeparator: Bool
    var attributes: CalendarAttributes = CalendarAttributes()
    
    required init(section width: CGFloat, height: CGFloat, slotSize: CalendarSlotSize, widthOfRowHeader: CGFloat, onlyFirstVerticalSeparator: Bool = false) {
        
        self.sectionWidth = width
        self.sectionHeight = height
        self.slotSize = slotSize
        self.rowHeaderWidth = widthOfRowHeader
        self.onlyFirstVerticalSeparator = onlyFirstVerticalSeparator
    }
    
    var allLayoutAttributes: [UICollectionViewLayoutAttributes] {
        return attributes.allAttributes
    }
    
    func layoutAttributesForVerticalLines(section: Int, startY: CGFloat) {
        
        var newAttributes = UICollectionViewLayoutAttributes()
        
        let indexPath = IndexPath(item: 1, section: section)
        
        (newAttributes, attributes.verticalGridlineAttributes) = layoutAttributesForDecorationView(at: indexPath, ofKind: FullCalendarDecorationViewKind.verticalSeparator, withCache: attributes.verticalGridlineAttributes)
        
        let sectionX = rowHeaderWidth + CGFloat(section) * sectionWidth
        var width: CGFloat = 1
        if !(indexPath.section == 0) {
            width = onlyFirstVerticalSeparator ? 0 : width
        }
        newAttributes.frame = CGRect(x: sectionX, y: startY-500, width: width, height: sectionHeight + 1000)
        newAttributes.zIndex = 2
    }
    
    func layoutAttributesForWorkingHour(_ workingHour: WorkingHour, index: Int, section: Int) {
        
        var newAttributes = UICollectionViewLayoutAttributes()
        
        let x = rowHeaderWidth + CGFloat(section) * sectionWidth
        let y = slotSize.getRelevantPosition(forMinutes: workingHour.start)
        let height = slotSize.getRelevantPosition(forMinutes: workingHour.boundsDifference)
        
        let size = CGRect(x: x, y: y, width: sectionWidth, height: height)
        let indexPath = IndexPath(item: index, section: section)
        
        (newAttributes, attributes.onHoursViewAttributes) = layoutAttributesForDecorationView(
            at: indexPath,
            ofKind: FullCalendarDecorationViewKind.workingHoursView,
            withCache: attributes.onHoursViewAttributes)
        
        newAttributes.frame = size
        newAttributes.zIndex = 1
    }
    
    func layoutAttributesForSlotSizeLines(section: Int, workingHours: WorkingHour) {
        
        
        var newAttributes = UICollectionViewLayoutAttributes()
        
        for minute in workingHours.start ... workingHours.end where canDrawSlotLine(forMin: minute) && !canDrawHourLine(forMin: minute) {
            let x = CGFloat(section) * sectionWidth
            let y = slotSize.getRelevantPosition(forMinutes: minute)
            
            let size = CGRect(x: x, y: y, width: sectionWidth, height: 1)
            let indexPath = IndexPath(item: Int(minute), section: section)
            
            (newAttributes, attributes.slotLinesGridLineAttributes) = layoutAttributesForDecorationView(
                at: indexPath,
                ofKind: FullCalendarDecorationViewKind.workingHoursDivLine,
                withCache: attributes.slotLinesGridLineAttributes)
            
            newAttributes.frame = size
            newAttributes.zIndex = 9
        }
    }
    
    // Refactor Me:- when iterating duration itself need to set both dark and light horizontal lines
    func layoutAttributesForHourLine(section: Int, workingHours workingHour: WorkingHour) {
        
        var newAttributes = UICollectionViewLayoutAttributes()
        
        let x = rowHeaderWidth + CGFloat(section) * sectionWidth
        
        for min in workingHour.start ... workingHour.end where canDrawHourLine(forMin: min) {
            
            let indexPath = IndexPath(item: min, section: section)
            let size = CGRect(x: x, y: slotSize.getRelevantPosition(forMinutes: min), width: sectionWidth, height: 1)
            
            (newAttributes, attributes.horizontalGridlineAttributes) = layoutAttributesForDecorationView(
                at: indexPath,
                ofKind: FullCalendarDecorationViewKind.horizonalSeparator,
                withCache: attributes.horizontalGridlineAttributes)
            
            newAttributes.frame = size
            newAttributes.zIndex = 2
        }
    }
    
    func layoutAttributesFor(items: [CalendarItem], section: Int) {
        var itemNumber = 0
        var sectionItemAttributes = [UICollectionViewLayoutAttributes]()
        for item in items {
            let indexPath = IndexPath(item: itemNumber, section: section)
            sectionItemAttributes.append(layoutAttributesForCell(at: indexPath, item: item))
            itemNumber += 1
        }
        adjustItemsForOverlap(sectionItemAttributes, inSection: section, sectionX: rowHeaderWidth + CGFloat(section) * sectionWidth)
    }
    
    func layoutAttributesForCell(at indexPath: IndexPath, item: CalendarItem) -> UICollectionViewLayoutAttributes {
        
        var newAttributes = UICollectionViewLayoutAttributes()
        
        (newAttributes, attributes.cellAttributes) = layoutAttributesForCell(at: indexPath, withCache: attributes.cellAttributes)
        
        let startDate = item.startDate
        let endDate = item.endDate
        let startTimeMins = startDate.timeInMinutes
        let endTimeMins = endDate.timeInMinutes
        
        let sectionX = rowHeaderWidth + CGFloat(indexPath.section) * sectionWidth
        
        let horizontalStartY = slotSize.getRelevantPosition(forMinutes: startTimeMins)
        
        let height = slotSize.getRelevantPosition(forMinutes: endTimeMins - startTimeMins) // - 1     //* hourHeight - 1
        
        newAttributes.frame = CGRect(x: sectionX + 2, y: horizontalStartY, width: sectionWidth - 6, height: height - 2)
        newAttributes.zIndex = 11
        
        return newAttributes
    }
    
    func layoutAttributesForTimeHeader() {
        
        
        // Row Header
        var newAttributes = UICollectionViewLayoutAttributes()
        for rowHeaderIndex in 0...23 {
            
            (newAttributes, attributes.timeHeaderAttributes) = layoutAttributesForSupplemantaryView(at: IndexPath(item: rowHeaderIndex, section: 0), ofKind: .rowHeader, withCache: attributes.timeHeaderAttributes)
            
            let rowHeaderY = slotSize.hourHeight * CGFloat(rowHeaderIndex) - 5
            newAttributes.frame = CGRect(x: 0, y: rowHeaderY, width: rowHeaderWidth, height: 10)
            newAttributes.zIndex = 1
        }
    }
    
    func layoutAttributesForOutOfBoundsView(calendarWidth: CGFloat) {
        
        var newAttributes = UICollectionViewLayoutAttributes()
        let top = 26
        let bottom = 27
        for position in top...bottom {
            
            let indexPath = IndexPath(item: position, section: 0)
            
            (newAttributes, attributes.outOfBoundsViewAttributes) = layoutAttributesForDecorationView(at: indexPath, ofKind: .outOfBoundsView, withCache: attributes.outOfBoundsViewAttributes)
            
            let horizontalY = position == top ? -500 : sectionHeight
            newAttributes.frame = CGRect(x: 0, y: horizontalY, width: calendarWidth, height: 500)
            newAttributes.zIndex = 7
            
        }
    }
    
    func layoutAttributesForCurrentTimeLine(section: Int) {
        
        var newAttributes = UICollectionViewLayoutAttributes()
        
        let hourY = slotSize.getRelevantPosition(forMinutes: Date().timeInMinutes)
        
        (newAttributes, attributes.currentTimeIndicatorAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: 24, section: 0), ofKind: .currentTimeIndicatorLine, withCache: attributes.currentTimeIndicatorAttributes)

        newAttributes.frame = CGRect(x: rowHeaderWidth + sectionWidth * CGFloat(section), y: hourY - 1, width: sectionWidth * 7, height: 1)
        newAttributes.zIndex = 100
        
        (newAttributes, attributes.currentTimeIndicatorAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: 25, section: 0), ofKind: .currentTimeIndicatorCircle, withCache: attributes.currentTimeIndicatorAttributes)
        
        newAttributes.frame = CGRect(x: rowHeaderWidth + sectionWidth * CGFloat(section), y: hourY - 6, width: 1, height: 12)
        newAttributes.zIndex = 100
    }
    
    func layoutAttributesForDecorationView(at indexPath: IndexPath, ofKind kind: FullCalendarDecorationViewKind, withCache itemCache: CalendarAttributeDict) -> (UICollectionViewLayoutAttributes, CalendarAttributeDict) {
        
        guard let layoutAttributes = itemCache[indexPath] else {
            
            var _itemCache = itemCache
            let _layoutAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: kind.rawValue, with: indexPath)
            _itemCache[indexPath] = _layoutAttributes
            return (_layoutAttributes, _itemCache)
            
        }
        
        return (layoutAttributes, itemCache)
    }
    
    func layoutAttributesForSupplemantaryView(at indexPath: IndexPath, ofKind kind: FullCalendarSupplementaryViewKind, withCache itemCache: CalendarAttributeDict) -> (UICollectionViewLayoutAttributes, CalendarAttributeDict) {
        
        guard let layoutAttributes = itemCache[indexPath] else {
            
            var _itemCache = itemCache
            let _layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: kind.rawValue, with: indexPath)
            _itemCache[indexPath] = _layoutAttributes
            return (_layoutAttributes, _itemCache)
            
        }
        
        return (layoutAttributes, itemCache)
    }
    
    func layoutAttributesForCell(at indexPath: IndexPath, withCache itemCache: CalendarAttributeDict) -> (UICollectionViewLayoutAttributes, CalendarAttributeDict) {
        
        guard let layoutAttributes = itemCache[indexPath] else {
            
            var _itemCache = itemCache
            let _layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            _itemCache[indexPath] = _layoutAttributes
            return (_layoutAttributes, _itemCache)
            
        }
        
        return (layoutAttributes, itemCache)
    }
    
    func adjustItemsForOverlap(_ sectionItemAttributes: [UICollectionViewLayoutAttributes], inSection: Int, sectionX: CGFloat) {
        var adjustedAttributes = Set<UICollectionViewLayoutAttributes>()
        let sectionZ = 20
        
        for itemAttributes in sectionItemAttributes {
            // If an item's already been adjusted, move on to the next one
            if adjustedAttributes.contains(itemAttributes) {
                continue
            }
            
            // Find the other items that overlap with this item
            var overlappingItems = [UICollectionViewLayoutAttributes]()
            let itemFrame = itemAttributes.frame
            
            overlappingItems.append(contentsOf: sectionItemAttributes.filter {
                
                return $0 != itemAttributes ? itemFrame.intersects($0.frame) : false
            })
            
            // If there's items overlapping, we need to adjust them
            if !overlappingItems.isEmpty {
                // Add the item we're adjusting to the overlap set
                overlappingItems.insert(itemAttributes, at: 0)
                var minY = CGFloat.greatestFiniteMagnitude
                var maxY = CGFloat.leastNormalMagnitude
                var divisions = 1
                
                for overlappingItemAttributes in overlappingItems {
                    if overlappingItemAttributes.frame.minY < minY {
                        minY = overlappingItemAttributes.frame.minY
                    }
                    if overlappingItemAttributes.frame.maxY > maxY {
                        maxY = overlappingItemAttributes.frame.maxY
                    }
                    
                    if overlappingItemAttributes.frame.minY == itemFrame.minY && overlappingItemAttributes.frame.maxY == itemFrame.maxY {
                        for _ in stride(from: itemFrame.minY, to: itemFrame.maxY, by: 1) {
                            var numberItemsForCurrentY = 0
                            
                            for overlappingItemAttributes in overlappingItems {
                                if (itemFrame.minY <= overlappingItemAttributes.frame.minY &&
                                    itemFrame.maxY >= overlappingItemAttributes.frame.maxY) || itemFrame.minY <= overlappingItemAttributes.frame.minY + slotSize.divisionHeight {
                                    numberItemsForCurrentY += 1
                                }
                            }
                            if numberItemsForCurrentY > divisions {
                                divisions = numberItemsForCurrentY
                            }
                            //                        }
                        }
                    }
                }
                
                
                // Adjust the items to have a width of the section size divided by the number of divisions needed
                
                let divisionWidth = nearbyint((sectionWidth - 2.5) / CGFloat(divisions + 1)) - 2.5
                var dividedAttributes = [UICollectionViewLayoutAttributes]()
                
                for divisionAttributes in overlappingItems {
                    
                    // It it hasn't yet been adjusted, perform adjustment
                    if !adjustedAttributes.contains(divisionAttributes) {
                        var divisionAttributesFrame = divisionAttributes.frame
                        divisionAttributesFrame.origin.x = sectionX + 2
                        divisionAttributesFrame.size.width = sectionWidth - 5
                        
                        // Horizontal Layout
                        var adjustments = 1
                        for dividedItemAttributes in dividedAttributes {
                            if dividedItemAttributes.frame.intersects(divisionAttributesFrame) {
                                divisionAttributesFrame.origin.x = sectionX + ((divisionWidth * CGFloat(adjustments))) + 2
                                divisionAttributesFrame.size.width = sectionWidth - ((divisionWidth * CGFloat(adjustments))) - 4.5
                                adjustments += 1
                                divisionAttributes.zIndex += sectionZ + adjustments
                                //                            } else if dividedItemAttributes.frame != divisionAttributesFrame && dividedItemAttributes.frame.minX == divisionAttributesFrame.minX {
                                //                                divisionAttributesFrame.origin.x += 30
                                //                                adjustments += 1
                                //                                divisionAttributes.zIndex += adjustments
                                //
                            }
                        }
                        
                        divisionAttributes.frame = divisionAttributesFrame
                        dividedAttributes.append(divisionAttributes)
                        adjustedAttributes.insert(divisionAttributes)
                    }
                }
            }
        }
    }
    
    func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in self.allLayoutAttributes where attributes.frame.intersects(rect) {
            layoutAttributes.append(attributes)
        }
        return layoutAttributes
    }
    
    func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attributes = self.attributes.cellAttributes.values.filter { $0.indexPath == indexPath }
        return attributes.first
    }
    
    func layoutAttributesForSupplementaryElements(ofKind kind: FullCalendarSupplementaryViewKind, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch kind {
        case .hourLabel:
            return self.attributes.timeLabelsAttributes[indexPath]
        case .rowHeader:
            return self.attributes.timeHeaderAttributes[indexPath]
        case .currentTimeTriangle:
            return self.attributes.timeHeaderAttributes[indexPath]
        default:
            return nil
        }
    }
    
    func removeGeneratedAttributes(of type: AttributesType) {
        switch type {
        case .currentTimeIndicator:
            self.attributes.invalidateCurrentTimeIndicatorAttributes()
        case .event:
            self.attributes.invalidateEventAttributes()
        default:
            self.attributes.invalidateCache()
        }
    }
}

extension AnytimeCalLayoutAttributesGenerator {
    
    // This method checks whether a slot Line can be drawn for the given minute (i.e, 4:30AM will be passed as 270 minutes)
    func canDrawSlotLine(forMin min: Int) -> Bool {
        min % slotSize.minutes == 0
    }
    
    // This method returns whether an hour line can be drawn for the given minute (i.e, 4AM will be passed as 240 minutes)
    func canDrawHourLine(forMin min: Int) -> Bool {
        min % 60 == 0
    }
}
