//
//  SampleScheduleViewController.swift
//  AnywhereCalendarSDK_Example
//
//  Created by Deepika on 23/07/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import AnywhereCalendarSDK
import UIKit

class SampleScheduleViewController: UIViewController {
    @IBOutlet var containerView: UIView!
    var currentDataSource: ScheduleViewDataSource?

    lazy var calendarView: CalendarView = {
        let config = ScheduleViewConfiguration(shouldHaveStickyDate: true, placeholderConfig: .daily)
        let anyCal = AnywhereCalendarView.getScheduleView(withConfig: config)
        anyCal.dataProvider = self
        anyCal.actionDelegate = self
        return anyCal
    }()

    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.view.frame = containerView.frame
        containerView.addSubview(calendarView.view)
        calendarView.didMove(toParent: self)
        let calConfig = CalendarConfiguration(withUserAvailability: nil, userRegion: .ISO)
        AnywhereCalendarView.configure(withConfiguration: calConfig, theme: .Light)
    }

    @IBAction func addNewEvent(_: Any) {
        currentDataSource?.insert(calendarItem: AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: Date().dateRoundedAt(at: .toCeil10Mins), endDate: Date().dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .google))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SampleScheduleViewController: CalendarActionDelegate {
    func didTapCalendar(on _: Date, atTime _: Int, duration _: Int, notifyCompletion _: () -> Void) {}

    func didSelectCell(for _: CalendarItem) {}

    func didTapCalendar(on _: Date, atTime _: Int) {}
}

extension SampleScheduleViewController: CalendarDataProvider {
    func getCustomizationProvider(for calendarView: FullCalendarView) -> FullCalendarCustomizationProvider? {
        let customizationProvider = FullCalendarCustomizationProvider.custom(forCalendarView: calendarView, withCustomCalendarCells: [], calendarNibs: [], delegate: self)
        customizationProvider.swipeActionDelegate = self
        return customizationProvider
    }

    func getDataSource(forPage _: Int) -> FullCalendarDataSource? {
        let calendarDataSource = ScheduleViewDataSource()
        currentDataSource = calendarDataSource
        return calendarDataSource
    }
}

class ScheduleViewDataSource: FullCalendarDataSource {
    private lazy var calendarItems: [Date: [CalendarItem]] = [
        Date().dateAt(.tomorrow).dateAt(.startOfDay): self.getCalendarItems(forDate: Date().dateAt(.tomorrow)),
    ]

    var activeCalendarView: FullCalendarView?
    var activeDates: [Date] {
        let date = Date().dateAt(.startOfDay)
        var newDates = [Date]()
        for day in 0 ..< 7 {
            newDates.append(date.dateByAdding(day, .day).date)
        }
        return newDates
    }

    var noOfItemsForActiveDates: Int {
        return calendarItems.count
    }

    func insert(calendarItem: CalendarItem) {
        let date = calendarItem.startDate.dateAt(.startOfDay)
        insert(date: date)
        calendarItems[date]?.append(calendarItem)
        activeCalendarView?.insertItems(at: [IndexPath(row: 0, section: 0)])
    }

    func insert(date: Date) {
        let date = date.dateAt(.startOfDay)
        guard calendarItems[date] == nil else {
            return
        }
        calendarItems[date] = []
    }

    func deleteItem(at indexPath: IndexPath) {
        let date = activeDates[indexPath.section]
        calendarItems[date]?.removeFirst()
        activeCalendarView?.deleteItems(at: [IndexPath(row: 0, section: indexPath.section)])
    }

    func getCalendarItems(forSection section: Int) -> [CalendarItem] {
        guard section < activeDates.count else {
            return []
        }

        let date = activeDates[section]

        guard let items = calendarItems[date] else {
            return []
        }
        return items
    }

    private func getCalendarItems(forDate date: Date) -> [CalendarItem] {
        return [
            AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: date.dateRoundedAt(at: .toCeil10Mins), endDate: date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .google),
            AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: date.dateRoundedAt(at: .toCeil10Mins), endDate: date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .setmore),
            AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: date.dateRoundedAt(at: .toCeil10Mins), endDate: date.dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .microsoft),
        ]
    }

    func numberOfItems(inSection section: Int) -> Int {
        return getCalendarItems(forSection: section).count
    }
}

extension SampleScheduleViewController: CalendarSwipeActionDelegate {
    func leadingSwipeActionsConfiguration(forRowAt _: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }

    func trailingSwipeActionsConfiguration(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, completionHandler in
            completionHandler(true)
            self.currentDataSource?.deleteItem(at: indexPath)
        }

        deleteAction.title = "Delete"
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension SampleScheduleViewController: CalendarCustomizationProviderDelegate {
    func reuseIdentifier(forItemAt _: IndexPath) -> String {
        return ""
    }

    func height(forRowAt _: IndexPath) -> CGFloat? {
        return nil
    }
}
