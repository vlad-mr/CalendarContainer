//
//  CalendarCollectionViewLayout.swift
//  Anytime
//
//  Created by Vignesh on 18/02/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

typealias CalendarAttributeDict = [IndexPath: UICollectionViewLayoutAttributes]

class CalendarCollectionViewLayout: UICollectionViewLayout {
    var numberOfDays: Int = 1
    var viewConfiguration: CalendarViewConfiguration = .init()
    var shouldShowTimeHeader: Bool = false
    weak var delegate: CalendarCollectionViewLayoutDelegate?

    var sectionWidth: CGFloat {
        if shouldShowTimeHeader {
            return (collectionView!.frame.size.width - viewConfiguration.calendarDimensions.timeHeaderWidth) / CGFloat(numberOfDays)
        } else {
            return collectionView!.frame.size.width / CGFloat(numberOfDays)
        }
    }

    private var sectionRange: Range<Int> {
        return Range(uncheckedBounds: (lower: 0, upper: numberOfDays))
    }

    private var sectionHeight: CGFloat {
        return viewConfiguration.slotSize.dayHeight
    }

    private var attributesGenerator: LayoutAttributesGenerator?

    private var shouldGenerateLayoutAttributes = true

    override public func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        invalidateLayoutCache()
        prepare()
        super.prepare(forCollectionViewUpdates: updateItems)
    }

    override public func prepare() {
        super.prepare()
        invalidateLayoutCache()
        guard shouldGenerateLayoutAttributes else {
            return
        }
        attributesGenerator = AnytimeCalLayoutAttributesGenerator(section: sectionWidth, height: sectionHeight, slotSize: viewConfiguration.slotSize, widthOfRowHeader: shouldShowTimeHeader ? viewConfiguration.calendarDimensions.timeHeaderWidth : 0, onlyFirstVerticalSeparator: true)
        prepareLayoutAttributesForSections(sectionRange)
        shouldGenerateLayoutAttributes = false
    }

    override public var collectionViewContentSize: CGSize {
        if shouldShowTimeHeader {
            return CGSize(width: sectionWidth * CGFloat(numberOfDays) + viewConfiguration.calendarDimensions.timeHeaderWidth, height: sectionHeight)
        }
        return CGSize(width: sectionWidth * CGFloat(numberOfDays), height: sectionHeight)
    }

    func layoutAttributesForSupplementaryView(ofKind elementKind: FullCalendarSupplementaryViewKind, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesGenerator?.layoutAttributesForSupplementaryElements(ofKind: elementKind, at: indexPath)
    }

    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesGenerator?.layoutAttributesForElements(in: rect)
    }

    override public func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
        return false
    }

    private func setLayoutAttributesForCurrentTime() {
        guard !sectionRange.isEmpty else { return }

        guard let indexForTimeline = delegate?.indexForCurrentTimeLine else { return }
        attributesGenerator?.layoutAttributesForCurrentTimeLine(section: indexForTimeline)
    }

    private func invalidateCurrentTimeIndicator() {
        attributesGenerator?.removeGeneratedAttributes(of: .currentTimeIndicator)
        invalidateLayout()
    }

    func prepareLayoutAttributesForSections(_ sections: Range<Int>) {
        guard !sections.isEmpty else { return }
        attributesGenerator?.layoutAttributesForOutOfBoundsView(calendarWidth: collectionView!.bounds.size.width)
        setLayoutAttributesForCurrentTime()
        if shouldShowTimeHeader {
            attributesGenerator?.layoutAttributesForTimeHeader()
        }
        for section in sections {
            attributesGenerator?.layoutAttributesForVerticalLines(section: section, startY: 0)
            setAttributesForHourTypes(section: section)
            setAttributesForEvents(section: section)
        }
    }

    var scrollPositionForCurrentTime: CGFloat {
        let y = CGFloat(Date().hour) * viewConfiguration.slotSize.hourHeight - collectionView!.frame.height / 2
        if y < collectionView!.frame.origin.y {
            return 0
        } else if y > viewConfiguration.slotSize.dayHeight - collectionView!.frame.height {
            return viewConfiguration.slotSize.dayHeight - collectionView!.frame.height
        }
        return y
    }

    func setAttributesForHourTypes(section: Int) {
        var index = 0

        guard let availability = delegate?.userAvailability(forSection: section), !availability.isEmpty else {
            let timeStretch = WorkingHour(start: 0, end: Int(sectionHeight))
            attributesGenerator?.layoutAttributesForWorkingHour(timeStretch, index: index, section: section)
            attributesGenerator?.layoutAttributesForHourLine(section: section, workingHours: timeStretch)
            return
        }
        for workingHour in availability {
            attributesGenerator?.layoutAttributesForWorkingHour(workingHour, index: index, section: section)
            attributesGenerator?.layoutAttributesForHourLine(section: section, workingHours: workingHour)
            if viewConfiguration.shouldShowSlotLines {
                attributesGenerator?.layoutAttributesForSlotSizeLines(section: section, workingHours: workingHour)
            }
            index += 1
        }
    }

    func setAttributesForEvents(section: Int) {
        guard let dataSource = collectionView?.dataSource as? CalendarLayoutViewController else {
            return
        }
        let items = dataSource.getCalendarItems(forSection: section)
        attributesGenerator?.layoutAttributesFor(items: items, section: section)
        //        guard let dataSource = collectionView?.dataSource as? CalendarCollectionViewDataSource<Event> else { return }
        //        let events = dataSource.objects(inSection: section)
        //        let items = events.compactMap { EventModel(fromEvent: $0) }
        //        attributesGenerator?.layoutAttributesFor(items: items, section: section)
    }

    func setAttributesForAllEvents() {
        for section in sectionRange {
            setAttributesForEvents(section: section)
        }
    }

    func updateCurrentTimeLine() {
        invalidateCurrentTimeIndicator()
        setLayoutAttributesForCurrentTime()
    }

    func invalidateLayoutCache() {
        shouldGenerateLayoutAttributes = true
        attributesGenerator?.removeGeneratedAttributes(of: .all)
        invalidateLayout()
    }

    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        attributesGenerator?.layoutAttributesForItem(at: indexPath)
    }

    func layoutAttributesForDecorationView(ofKind elementKind: FullCalendarDecorationViewKind, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let cache: CalendarAttributeDict?
        switch elementKind {
        case .verticalSeparator:
            cache = attributesGenerator?.attributes.verticalGridlineAttributes
        case .horizonalSeparator:
            cache = attributesGenerator?.attributes.horizontalGridlineAttributes
        case .outOfBoundsView:
            cache = attributesGenerator?.attributes.outOfBoundsViewAttributes
        case .currentTimeIndicatorCircle:
            cache = attributesGenerator?.attributes.currentTimeIndicatorAttributes
        case .currentTimeIndicatorLine:
            cache = attributesGenerator?.attributes.currentTimeIndicatorAttributes
        case .workingHoursDivLine:
            cache = attributesGenerator?.attributes.slotLinesGridLineAttributes
        default:
            return nil
        }
        guard let currentCache = cache else { return nil }
        return attributesGenerator?.layoutAttributesForDecorationView(at: indexPath, ofKind: elementKind, withCache: currentCache).0
    }

    func reloadCells() {
        attributesGenerator?.removeGeneratedAttributes(of: .event)
        setAttributesForAllEvents()
    }
}

extension CalendarCollectionViewLayout {
    override public func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let calendarElementKind = FullCalendarDecorationViewKind(rawValue: elementKind) else {
            return nil // Should I return nil or super value
        }
        return layoutAttributesForDecorationView(ofKind: calendarElementKind, at: indexPath)
    }

    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let supplementaryElementKind = FullCalendarSupplementaryViewKind(rawValue: elementKind) else {
            return nil
        }
        return layoutAttributesForSupplementaryView(ofKind: supplementaryElementKind, at: indexPath)
    }
}
