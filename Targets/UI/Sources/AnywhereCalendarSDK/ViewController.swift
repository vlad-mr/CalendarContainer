//
//  ViewController.swift
//  AnywhereCalendarSDK
//
//  Created by vignesh.mariappan@anywhere.co on 07/20/2020.
//  Copyright (c) 2020 vignesh.mariappan@anywhere.co. All rights reserved.
//

import AnywhereCalendarSDK
import UIKit

class ViewController: UIViewController {
    lazy var numberOfDays = isDailyCalendar ? dailyNumberOfDays : weeklyNumberOfDays
    let dailyNumberOfDays = 1
    let weeklyNumberOfDays = 7
    var currentDate = Date()

    // toggle between daily and weekly
    let isDailyCalendar = true

    var pickerTitle: String = ""
    @IBOutlet var containerView: UIView!

    lazy var calendarView: CalendarView = isDailyCalendar ? dailyCalendarView : weeklyCalendarView

    lazy var dailyCalendarView: CalendarView = AnywhereCalendarView.getDailyCalendar(
        withConfiguration: .init(
            withSlotSize: .thirty,
            shouldShowSlotLines: false,
            calendarDimensions: .defaultDimensions
        ),
        dataProvider: self,
        actionDelegate: self
    )

    lazy var weeklyCalendarView: CalendarView = AnywhereCalendarView.getWeeklyCalendar(
        withConfiguration: .init(
            withSlotSize: .thirty,
            shouldShowSlotLines: false,
            calendarDimensions: .defaultDimensions
        ),
        dataProvider: self,
        actionDelegate: self
    )

    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var calendar = Calendar.gregorian
        calendar.firstWeekday = 2
        let calConfig = CalendarConfiguration(withUserAvailability: nil, userRegion: .init(calendar: calendar, zone: TimeZone.current, locale: Locale.current))
        AnywhereCalendarView.configure(withConfiguration: calConfig, theme: .Light)
        containerView.isHidden = true
    }

    @IBAction func didTapLoadCalButton(_: UIButton) {
        loadCalendarView()
    }

    @IBAction func didTapLoadDatePickerButton(_: UIButton) {
        loadDatePickerView()
    }

    func loadCalendarView() {
        present(calendarView, animated: true, completion: nil)
    }

    func loadDatePickerView() {
        let viewConfig = DatePickerViewConfiguration(weekDayTitleMode: .singleLetter,
                                                     monthTitleStyle: .short,
                                                     pickerTitleMode: .monthNameWithTodayButton,
                                                     shouldDisplayCurrentYearOnMonthTitle: false,
                                                     todayHighlightMode: .highlighted)
        let pickerConfig = DatePickerConfig(font: .systemFont(ofSize: 16),
                                            mode: .monthly,
                                            userRegion: .current,
                                            minDate: Date().dateAt(.startOfMonth),
                                            maxDate: Date().dateAt(.endOfMonth),
                                            viewConfiguration: viewConfig)
        let picker = AnywhereDatePicker.getDatePicker(withConfig: pickerConfig, dataSource: self, delegate: self)
        present(picker, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            picker.load(for: Date().dateByAdding(1, .month).date)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public func embedViewController(_ viewController: UIViewController, toView containerView: UIView) {
        addChild(viewController)
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}

extension ViewController: CalendarDataProvider {
    func getCustomizationProvider(for calendarView: FullCalendarView) -> FullCalendarCustomizationProvider? {
        return FullCalendarCustomizationProvider.custom(forCalendarView: calendarView, withCustomCalendarCells: [isDailyCalendar ? AnytimeDailyEventCell.self : AnytimeWeaklyEventCell.self], calendarNibs: [], delegate: self)
    }

    func getDataSource(forPage page: Int) -> FullCalendarDataSource? {
        let dataSource = DataSource()
        let calendarDataSource = CalendarDataSource(withSource: dataSource)
        let currentDate = self.currentDate.dateByAdding(page * numberOfDays, .day).date
        dataSource.activeDates = getCalendarDates(forDate: currentDate)
        return calendarDataSource
    }

    private func getCalendarDates(forDate date: Date) -> [Date] {
        var newDates = [Date]()
        for day in 0 ..< numberOfDays {
            newDates.append(date.dateByAdding(day, .day).date)
        }
        return newDates
    }
}

extension ViewController: CalendarCustomizationProviderDelegate {
    func reuseIdentifier(forItemAt _: IndexPath) -> String {
        return isDailyCalendar ? AnytimeDailyEventCell.reuseIdentifier : AnytimeWeaklyEventCell.reuseIdentifier
    }

    func dayOffTitle(forSection _: Int) -> String? {
        return "Vacation"
    }
}

class CalendarDataSource: FullCalendarDataSource {
    var activeCalendarView: FullCalendarView? {
        didSet {
            source.activeCalendarView = activeCalendarView
        }
    }

    var source: FullCalendarDataSource
    // for testing purpose
    var shouldAllDayEventPartOfHeader: Bool = true
    var activeDates: [Date] {
        return source.activeDates
    }

    init(withSource source: FullCalendarDataSource) {
        self.source = source
    }

    func getAllEvents() -> [CalendarItem] {
        var calendarItems = [CalendarItem]()
        for index in 0 ..< activeDates.count {
            calendarItems += source.getCalendarItems(forSection: index)
        }
        return calendarItems
    }

    func getCalendarItems(forSection section: Int) -> [CalendarItem] {
        guard let date = getDate(forSection: section) else {
            return []
        }
        guard let calendarItems = AnywhereCalendarView.getIntraEventsByDate(originalEvents: getAllEvents())[date.dateAt(.startOfDay)] else {
            return []
        }

        guard shouldAllDayEventPartOfHeader else {
            return calendarItems
        }

        return calendarItems.filter { !$0.isAllDay }
    }

    func getDate(forSection section: Int) -> Date? {
        guard section < activeDates.count else {
            return nil
        }
        return activeDates[section]
    }

    func numberOfItems(inSection section: Int) -> Int {
        return getCalendarItems(forSection: section).count
    }

    func getAllDayEvents(forSection section: Int) -> [CalendarItem] {
        guard shouldAllDayEventPartOfHeader else {
            return []
        }
        guard let date = getDate(forSection: section) else {
            return []
        }
        guard let calendarItems = AnywhereCalendarView.getIntraEventsByDate(originalEvents: getAllEvents())[date.dateAt(.startOfDay)] else {
            return []
        }

        return calendarItems.filter { $0.isAllDay }
    }

    func shouldShowDayOff(forSection section: Int) -> Bool {
        source.shouldShowDayOff(forSection: section)
    }
}

class DataSource: FullCalendarDataSource {
    var activeCalendarView: FullCalendarView?

    var activeDates: [Date] = [Date()]

    func getCalendarItems(forSection section: Int) -> [CalendarItem] {
        let activeDate = activeDates[section]
        guard activeDate.isToday else {
            return []
        }
        let item0 = AnywhereCalendarItem(withId: "A123", title: "Meeting with Team", startDate: activeDate, endDate: activeDate.dateByAdding(2, .hour).date, color: .systemBlue, source: .google)
        let item1 = AnywhereCalendarItem(withId: "A123", title: "Meeting with Team", startDate: activeDate, endDate: activeDate.dateByAdding(2, .hour).date, color: .systemBlue, source: .google)
        let item2 = AnywhereCalendarItem(withId: "B123", title: "Workshop", startDate: activeDate.dateAt(.tomorrow), endDate: activeDate.dateByAdding(4, .hour).date, color: .systemGreen, source: .local)
        let item3 = AnywhereCalendarItem(withId: "C123", title: "Discussion", startDate: activeDate.dateByAdding(3, .hour).date, endDate: activeDate.dateByAdding(4, .hour).date, color: .systemTeal, source: .setmore)
        return [
            //            getCalendarItem(forDate: activeDate, title: ""),
            //                getCalendarItem(forDate: activeDate.dateAt(.tomorrow), title: "", color: .systemBlue),
            getCalendarItem(forDate: activeDate.dateAt(.tomorrow), title: "Multi day event", color: .systemPurple),
            item0,
            item1,
            item2,
            item3,
        ]
    }

    private func getCalendarItem(forDate date: Date, title: String?, color: UIColor? = .red) -> CalendarItem {
        return AnywhereCalendarItem(withId: "1234", title: title, startDate: date.add(component: .hour, value: 2), endDate: date.add(component: .day, value: 2), color: color, source: .microsoft)
    }

    func numberOfItems(inSection _: Int) -> Int {
        guard !activeDates.isEmpty else {
            return 0
        }
        return 1
    }

    func shouldShowDayOff(forSection section: Int) -> Bool {
        guard section < activeDates.count else {
            return false
        }
        return activeDates[section].isToday ? true : false
    }
}

extension ViewController: CalendarActionDelegate {
    func didTapCalendar(on date: Date, atTime timeInMins: Int, duration: Int, notifyCompletion: @escaping () -> Void) {
        print("""
        Date: \(date)
        timeInMinutes: \(timeInMins)
        duration: \(duration)
        """)
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        //            notifyCompletion()
        //        }
        presentAlertForTapAction(onCompletion: notifyCompletion)
    }

    func didSelectCell(for item: CalendarItem) {
        presentAlert(forItem: item)
    }

    func didTapCalendar(on _: Date, atTime _: Int) {}

    func executeAction(withIdentifier identifier: String, at section: Int) {
        print(identifier)
        print(section)
    }

    func presentAlert(forItem _: CalendarItem) {
        let alert = UIAlertController(title: "Tap action", message: "This would invoke the details page presented by the application", preferredStyle: .alert)
        let dismissAlert = UIAlertAction(title: "Got it!", style: .cancel, handler: nil)
        alert.addAction(dismissAlert)
        presentedViewController?.present(alert, animated: true, completion: nil)
    }

    func presentAlertForTapAction(onCompletion completionCallback: @escaping () -> Void) {
        let alert = UIAlertController(title: "Create an event", message: "This action selects a particular time for booking your events", preferredStyle: .alert)
        let dismissAlert = UIAlertAction(title: "Got it!", style: .default, handler: { _ in
            completionCallback()
        })
        alert.addAction(dismissAlert)
        presentedViewController?.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: DatePickerDelegate {
    func didUpdatePickerTitle(to title: String) {
        print("TItle: \(title)")
    }

    func didSelect(date: Date) {
        print("Selected Date: \(date)")
    }

    func didUpdatePickerHeight(to height: CGFloat) {
        print("New Height: \(height)")
    }
}

extension ViewController: DatePickerDataSource {
    func isDayOff(on date: Date) -> Bool {
        return date.day == 21 || date.day == 11
    }

    func numberOfEvents(for _: Date) -> Int {
        return 2
    }
}
