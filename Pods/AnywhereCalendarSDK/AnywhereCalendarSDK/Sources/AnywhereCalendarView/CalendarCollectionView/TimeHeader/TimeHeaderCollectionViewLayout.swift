//
//  TimeHeaderCollectionViewLayout.swift
//  AnywhereCalendarView
//
//  Created by Vignesh on 19/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

public enum CurrentTimeIndicator {
    case timeLabel
    case triangle
    case none
}

class TimeHeaderLayout: UICollectionViewLayout {

    let slotSize: CalendarSlotSize
    let calendarDimensions: CalendarDimensions
    let currentTimeIndicator: CurrentTimeIndicator
    
    var attributes = [UICollectionViewLayoutAttributes]()
    var attributesDict = [IndexPath: UICollectionViewLayoutAttributes]()
    private let currentTimeIndexPath = IndexPath(row: 24, section: 0)
    
    init(withSlotSize slotSize: CalendarSlotSize, calendarDimensions: CalendarDimensions, currentTimeIndicator: CurrentTimeIndicator) {
        
        self.slotSize = slotSize
        self.calendarDimensions = calendarDimensions
        self.currentTimeIndicator = currentTimeIndicator
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        prepare()
        super.prepare(forCollectionViewUpdates: updateItems)
    }
    
    override func prepare() {
        super.prepare()
        if attributes.isEmpty {
            for i in 1...23 {
                let indexPath = IndexPath(item: i, section: 0)
                let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: FullCalendarSupplementaryViewKind.hourLabel.rawValue, with: indexPath)
                attribute.frame = CGRect(x: 0, y: (CGFloat(i) * slotSize.hourHeight) - 17 , width: self.calendarDimensions.timeHeaderWidth, height: 20)
                attribute.zIndex = 7
                attributesDict[indexPath] = attribute
            }
            attributes.append(contentsOf: attributesDict.values)
        }

        switch currentTimeIndicator {
        case .timeLabel:
            layoutCurrentTimeAttributes()
        case .triangle:
            layoutCurrentTimeTriangleAttributes()
        case .none:
            break
        }
    }
    
    private func layoutCurrentTimeAttributes() {
        let today = Date()
        let indexPath = currentTimeIndexPath
        let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: FullCalendarSupplementaryViewKind.currentTimeTriangle.rawValue, with: indexPath)
//        let heightToAdjust: CGFloat = (today.minute < 53) ? 0 : (CGFloat(18 + (60-today.minute)))
        attribute.frame = CGRect(x: 0, y: (CGFloat(today.hour) * slotSize.hourHeight) - 17 + CGFloat(today.minute) , width: self.calendarDimensions.timeHeaderWidth, height: 20)
        attributesDict[indexPath] = attribute
        attribute.zIndex = 8
        attributes.append(contentsOf: attributesDict.values)
    }

    private func layoutCurrentTimeTriangleAttributes() {
        let today = Date()
        let indexPath = currentTimeIndexPath
        let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: FullCalendarSupplementaryViewKind.currentTimeTriangle.rawValue, with: indexPath)
        attribute.frame = CGRect(x: 0, y: (CGFloat(today.hour) * slotSize.hourHeight) - 17 + CGFloat(today.minute) , width: self.calendarDimensions.timeHeaderWidth, height: 20)
        attributesDict[indexPath] = attribute
        attribute.zIndex = 8
        attributes.append(contentsOf: attributesDict.values)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attribute in attributes where attribute.frame.intersects(rect) {
            layoutAttributes.append(attribute)
        }
        return layoutAttributes
    }
    
    func layoutAttributesForSupplementaryElements(ofKind kind: FullCalendarSupplementaryViewKind, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch kind {
        case FullCalendarSupplementaryViewKind.hourLabel, .rowHeader, .currentTimeTriangle:
            return attributesDict[indexPath]
        default:
            return nil
        }
    }
    
    func invalidateLayoutCache() {
        attributes.removeAll()
        attributesDict.removeAll()
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    func updateCurrentTime() {
        attributesDict[currentTimeIndexPath] = nil
        attributes.removeAll(where: { $0.indexPath == currentTimeIndexPath })
        self.invalidateLayout()
    }
}
