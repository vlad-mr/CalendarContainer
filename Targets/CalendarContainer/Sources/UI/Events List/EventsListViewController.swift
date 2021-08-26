//
//  EventsListViewController.swift
//  CalendarContainer
//
//  Created by Volodymyr Kravchenko on 24.08.2021.
//  Copyright © 2021 Anywhere. All rights reserved.
//

import UIKit
import CalendarSDK
import PromiseKit

public final class EventsListViewController: DrawerPresentableViewController {

  public override func loadView() {
    self.view = customView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    let calConfig = CalendarConfiguration(withUserAvailability: nil, userRegion: .ISO)
    AnywhereCalendarView.configure(withConfiguration: calConfig, theme: .Light)
    subscribeToEvents()
    showList()
    showPicker()
    showMenuDrawer()
  }

  let viewModel = EventsListViewModel()
  let customView = EventsListView()
  var currentDataSource: EventsListDataSource?
  var events: [EventModel] = []

  lazy var calendarView: CalendarView = {
      let config = ScheduleViewConfiguration(shouldHaveStickyDate: true, placeholderConfig: .daily)
      let anyCal = AnywhereCalendarView.getScheduleView(withConfig: config)
      anyCal.dataProvider = self
      anyCal.actionDelegate = self
      return anyCal
  }()

  lazy var pickerView: DatePickerView = {
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
    return AnywhereDatePicker.getDatePicker(withConfig: pickerConfig, dataSource: self, delegate: self)
  }()

  private func subscribeToEvents() {
    // TODO: show loading view
    viewModel.events
      .done(on: .main) { [weak self] events in
        self?.update(with: events)
      }
      .catch { [weak self] error in
        self?.show(error)
      }
      .finally {
        // TODO: remove loading view
      }
  }

  private func update(with events: [EventModel]) {
    self.events = events
    calendarView.reloadCalendar()
  }

  private func show(_ error: Error) {
    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .actionSheet)
    alert.addAction(.init(title: "Okay", style: .destructive) { _ in self.dismiss(animated: true, completion: nil) })
    present(alert, animated: true, completion: nil)
  }

  private func showList() {
    calendarView.view.frame = customView.list.frame
    customView.list.addSubview(calendarView.view)
    calendarView.didMove(toParent: self)
  }

  private func showPicker() {
    pickerView.view.frame = customView.picker.frame
    customView.picker.addSubview(pickerView.view)
    pickerView.didMove(toParent: self)
  }

  private func showMenuDrawer() {
    let button = UIButton()
    button.setTitle("Menu", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
    button.setTitleColor(.systemBlue, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(button)
    NSLayoutConstraint.activate([
        button.heightAnchor.constraint(equalToConstant: 40),
        button.widthAnchor.constraint(equalToConstant: 60),
        button.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
    ])
    button.addTarget(self, action: #selector(showDrawer), for: .touchUpInside)
    if #available(iOS 13.0, *) {
        configureHeader(image: UIImage(systemName: "house.fill"), title: "Anytime Calendar")
        setItems([
            SelectorItem(image: UIImage(named: "schedule"), title: "Schedule"),
            SelectorItem(image: UIImage(named: "day"), title: "Daily"),
            SelectorItem(image: UIImage(named: "week"), title: "Weekly"),
        ])
    }
    highlightCell(atRow: 0)
  }
}
