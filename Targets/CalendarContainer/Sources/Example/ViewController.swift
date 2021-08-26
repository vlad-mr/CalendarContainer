//
//  ViewController.swift
//  AnywhereCalendarSDK
//
//  Created by vignesh.mariappan@anywhere.co on 07/20/2020.
//  Copyright (c) 2020 vignesh.mariappan@anywhere.co. All rights reserved.
//

import UIKit
import CalendarSDK

class ViewController: UIViewController {
    
    lazy var numberOfDays = isDailyCalendar ? dailyNumberOfDays : weeklyNumberOfDays
    let dailyNumberOfDays = 1
    let weeklyNumberOfDays = 7
    var currentDate = Date()

    // toggle between daily and weekly
    let isDailyCalendar = false

    // switch to 'false' to show drawer
    let defaultExample = false

    var pickerTitle: String = ""
    @IBOutlet weak var containerView: UIView!
    
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

        if defaultExample {
            var calendar = Calendar.gregorian
            calendar.firstWeekday = 2
            let calConfig = CalendarConfiguration(withUserAvailability: nil, userRegion: .init(calendar: calendar, zone: TimeZone.current, locale: Locale.current))
            AnywhereCalendarView.configure(withConfiguration: calConfig, theme: .Light)
            containerView.isHidden = true
        } else {
            DispatchQueue.main.async {
                let vc = MainViewController()
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: false, completion: nil)
            }
        }
    }
    
    @IBAction func didTapLoadCalButton(_ sender: UIButton) {
        loadCalendarView()
    }
    
    @IBAction func didTapLoadDatePickerButton(_ sender: UIButton) {
        loadDatePickerView()
    }
    
    func loadCalendarView() {
        self.present(calendarView, animated: true, completion: nil)
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
        self.present(picker, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            picker.load(for: Date().dateByAdding(1, .month).date)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func embedViewController(_ viewController: UIViewController, toView containerView: UIView) {
        self.addChild(viewController)
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
        for day in 0..<numberOfDays {
            newDates.append(date.dateByAdding(day, .day).date)
        }
        return newDates
    }
}

extension ViewController: CalendarCustomizationProviderDelegate {
    
    func reuseIdentifier(forItemAt indexPath: IndexPath) -> String {
        return isDailyCalendar ? AnytimeDailyEventCell.reuseIdentifier : AnytimeWeaklyEventCell.reuseIdentifier
    }
    
    func dayOffTitle(forSection section: Int) -> String? {
        return "Vacation"
    }
    
}

extension ViewController: CalendarActionDelegate {
    func didTapCalendar(on date: Date, atTime timeInMins: Int, duration: Int, notifyCompletion: @escaping () -> Void) {
        print("""
            Date: \(date)
            timeInMinutes: \(timeInMins)
            duration: \(duration)
            """)
        presentAlertForTapAction(onCompletion: notifyCompletion)
    }
    
    func didSelectCell(for item: CalendarItem) {
        presentAlert(forItem: item)
    }
    
    func didTapCalendar(on date: Date, atTime timeInMins: Int) {
        
    }
    
    func executeAction(withIdentifier identifier: String, at section: Int) {
        print(identifier)
        print(section)
    }
    
    func presentAlert(forItem item: CalendarItem) {
        let alert = UIAlertController(title: "Tap action", message: "This would invoke the details page presented by the application", preferredStyle: .alert)
        let dismissAlert = UIAlertAction(title: "Got it!", style: .cancel, handler: nil)
        alert.addAction(dismissAlert)
        self.presentedViewController?.present(alert, animated: true, completion: nil)
    }
    
    func presentAlertForTapAction(onCompletion completionCallback: @escaping ()-> Void) {
        
        let alert = UIAlertController(title: "Create an event", message: "This action selects a particular time for booking your events", preferredStyle: .alert)
        let dismissAlert = UIAlertAction(title: "Got it!", style: .default, handler: { _ in
            completionCallback()
        })
        alert.addAction(dismissAlert)
        self.presentedViewController?.present(alert, animated: true, completion: nil)
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
    
    func numberOfEvents(for date: Date) -> Int {
        return 2
    }
}
