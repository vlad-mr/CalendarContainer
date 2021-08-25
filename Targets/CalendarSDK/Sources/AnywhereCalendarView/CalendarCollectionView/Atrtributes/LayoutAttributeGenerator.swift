//
//  LayoutAttributeGenerator.swift
//  Anytime
//
//  Created by Vignesh on 18/02/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol LayoutAttributesGenerator {
    
    //    var sectionWidth: CGFloat { get set }
    var attributes: CalendarAttributes { get set }
    var allLayoutAttributes: [UICollectionViewLayoutAttributes] { get }
    
    init(
        section width: CGFloat,
        height: CGFloat,
        slotSize: CalendarSlotSize,
        widthOfRowHeader: CGFloat,
        onlyFirstVerticalSeparator: Bool
    )

    func layoutAttributesForVerticalLines(section: Int, startY: CGFloat)
    func layoutAttributesForOutOfBoundsView(calendarWidth: CGFloat)
    func layoutAttributesForCurrentTimeLine(section: Int)
    
    // May be refactored later
    func layoutAttributesForDecorationView(at indexPath: IndexPath, ofKind kind: FullCalendarDecorationViewKind, withCache itemCache: CalendarAttributeDict) -> (UICollectionViewLayoutAttributes, CalendarAttributeDict)
    
    func layoutAttributesForSupplemantaryView(at indexPath: IndexPath, ofKind kind: FullCalendarSupplementaryViewKind, withCache itemCache: CalendarAttributeDict) -> (UICollectionViewLayoutAttributes, CalendarAttributeDict)
    
    func layoutAttributesFor(items: [CalendarItem], section: Int)
    
    func removeGeneratedAttributes(of type: AttributesType)
    
    func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    
    func layoutAttributesForSupplementaryElements(ofKind kind: FullCalendarSupplementaryViewKind, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    
    func layoutAttributesForWorkingHour(_ workingHours: WorkingHour, index: Int, section: Int)
    func layoutAttributesForHourLine(section: Int, workingHours: WorkingHour)
    func layoutAttributesForSlotSizeLines(section: Int, workingHours: WorkingHour)
    //    func layoutAttributesForTimeLabels(section: Int, duration: TimeStretch)
    func layoutAttributesForTimeHeader()
}


enum AttributesType {
    case all
    case currentTimeIndicator
    case event
    //    case timeLabel
}
