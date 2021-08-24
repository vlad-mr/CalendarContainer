//
//  CalendarAttributes.swift
//  Anytime
//
//  Created by Vignesh on 18/02/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

enum LayoutAttributeTypes {
    case verticalGridLine
    case horizontalGridLine
    case outOfBoundsView
    case onHoursView
    case slotsGridLine
    case currentTimeIndicator
    case timeLabel
    case event
    case timeHeader
}

struct CalendarAttributes {
    var outOfBoundsViewAttributes = CalendarAttributeDict()
    var verticalGridlineAttributes = CalendarAttributeDict()
    var eventAttributes = CalendarAttributeDict()
    var horizontalGridlineAttributes = CalendarAttributeDict()
    var slotLinesGridLineAttributes = CalendarAttributeDict()
    var onHoursViewAttributes = CalendarAttributeDict()
    var timeLabelsAttributes = CalendarAttributeDict()
    var currentTimeIndicatorAttributes = CalendarAttributeDict()
    var cellAttributes = CalendarAttributeDict()
    var timeHeaderAttributes = CalendarAttributeDict()

    var allAttributes: [UICollectionViewLayoutAttributes] {
        var attributes = [UICollectionViewLayoutAttributes]()

        attributes.append(contentsOf: outOfBoundsViewAttributes.values)
        attributes.append(contentsOf: verticalGridlineAttributes.values)
        attributes.append(contentsOf: eventAttributes.values)
        attributes.append(contentsOf: horizontalGridlineAttributes.values)

        attributes.append(contentsOf: slotLinesGridLineAttributes.values)
        attributes.append(contentsOf: onHoursViewAttributes.values)
        //        attributes.append(contentsOf: timeLabelsAttributes.values)

        attributes.append(contentsOf: timeHeaderAttributes.values)
        attributes.append(contentsOf: currentTimeIndicatorAttributes.values)
        attributes.append(contentsOf: cellAttributes.values)

        return attributes
    }

    mutating func setLayoutAttribute(for type: LayoutAttributeTypes, attributes: CalendarAttributeDict) {
        switch type {
        case .verticalGridLine:
            verticalGridlineAttributes = attributes

        case .horizontalGridLine:
            horizontalGridlineAttributes = attributes

        case .slotsGridLine:
            slotLinesGridLineAttributes = attributes

        case .outOfBoundsView:
            outOfBoundsViewAttributes = attributes

        case .onHoursView:
            onHoursViewAttributes = attributes

        case .event:
            eventAttributes = attributes

        case .timeHeader:
            timeHeaderAttributes = attributes

        case .timeLabel:
            timeLabelsAttributes = attributes

        case .currentTimeIndicator:
            currentTimeIndicatorAttributes = attributes
        }
    }

    mutating func invalidateCache() {
        cellAttributes.removeAll()
        verticalGridlineAttributes.removeAll()
        eventAttributes.removeAll()
        horizontalGridlineAttributes.removeAll()
        slotLinesGridLineAttributes.removeAll()
        onHoursViewAttributes.removeAll()
        timeLabelsAttributes.removeAll()
        currentTimeIndicatorAttributes.removeAll()
        outOfBoundsViewAttributes.removeAll()
        cellAttributes.removeAll()
        timeHeaderAttributes.removeAll()
    }

    mutating func invalidateCurrentTimeIndicatorAttributes() {
        currentTimeIndicatorAttributes.removeAll()
    }

    mutating func invalidateEventAttributes() {
        eventAttributes.removeAll()
    }
}
