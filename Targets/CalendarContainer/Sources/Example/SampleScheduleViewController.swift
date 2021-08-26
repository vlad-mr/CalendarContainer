//
//  SampleScheduleViewController.swift
//  AnywhereCalendarSDK_Example
//
//  Created by Deepika on 23/07/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import CalendarSDK

class SampleScheduleViewController: UIViewController {
    
    
    @IBOutlet weak var containerView: UIView!
    var currentDataSource: EventsListDataSource?
    
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
    
    @IBAction func addNewEvent(_ sender: Any) {
        
      currentDataSource?.insert(calendarItem: AnywhereCalendarItem(withId: "1234", title: "Sample Meeting", startDate: Date().dateRoundedAt(at: .toCeil10Mins), endDate: Date().dateByAdding(2, .hour).dateRoundedAt(.toCeil10Mins).date, color: .blue, source: .google))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SampleScheduleViewController: CalendarActionDelegate {
    func didTapCalendar(on date: Date, atTime timeInMins: Int, duration: Int, notifyCompletion: () -> Void) {
        
    }
    
    
    func didSelectCell(for item: CalendarItem) {
        
    }
    
    func didTapCalendar(on date: Date, atTime timeInMins: Int) {
        
    }
    
}

extension SampleScheduleViewController: CalendarDataProvider {
    
    func getCustomizationProvider(for calendarView: FullCalendarView) -> FullCalendarCustomizationProvider? {
        
        let customizationProvider = FullCalendarCustomizationProvider.custom(forCalendarView: calendarView, withCustomCalendarCells: [], calendarNibs: [], delegate: self)
        customizationProvider.swipeActionDelegate = self
        return customizationProvider
    }
    
    func getDataSource(forPage page: Int) -> FullCalendarDataSource? {
        let calendarDataSource = EventsListDataSource()
        self.currentDataSource = calendarDataSource
        return calendarDataSource
    }
    
}

extension SampleScheduleViewController: CalendarSwipeActionDelegate {
    
    func leadingSwipeActionsConfiguration(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    func trailingSwipeActionsConfiguration(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            completionHandler(true)
            self.currentDataSource?.deleteItem(at: indexPath)
        }
        
        deleteAction.title = "Delete"
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
}

extension SampleScheduleViewController: CalendarCustomizationProviderDelegate {
    func reuseIdentifier(forItemAt indexPath: IndexPath) -> String {
        return ""
    }
    
    func height(forRowAt indexPath: IndexPath) -> CGFloat? {
        return nil
    }
}
