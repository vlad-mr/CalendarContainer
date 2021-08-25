//
//  ScheduleDateTableViewController.swift
//  Anytime
//
//  Created by Deepika on 03/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

public protocol ScheduleTableVCProtocol: FullCalendarView, UIViewController {

  var contentOffset: CGPoint { get set }
  var viewModel: ScheduleVMProtocol? { get set }
  var scrollDelegate: ScheduleCalendarScrollDelegate? { get set }
  var customizationProvider: FullCalendarCustomizationProvider? { get set }
  var dimension: ScheduleViewDimensions { get set }
  func set(backgroundView view: UIView?)
}

public class ScheduleDateTableViewController: UITableViewController {

  public var viewModel: ScheduleVMProtocol?
  public weak var customizationProvider: FullCalendarCustomizationProvider?
  public weak var scrollDelegate: ScheduleCalendarScrollDelegate?
  public lazy var dimension: ScheduleViewDimensions = ScheduleViewDimensions()

  private func cellFor(tableView: UITableView, forCellAt indexPath: IndexPath, item: Date) -> UITableViewCell {

    return UITableViewCell()
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupTable()
  }

  private func setupTable() {
    tableView.separatorStyle = .none
    tableView.showsVerticalScrollIndicator = false
    tableView.showsVerticalScrollIndicator = false
    tableView.allowsSelection = false
    tableView.backgroundColor = AnywhereCalendarView.mainSDK.theme.dateHeaderBackgroundColor
  }

  // MARK: - Table view data source

  public override func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel?.numberOfSections ?? 0
  }

  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let viewModel = self.viewModel else {
      assertionFailure("ViewModel is nil in the schedule date VC!")
      return 0
    }
    let numberOfEvents = viewModel.numberOfRows(at: section)
    return numberOfEvents > 0 ? 1 : 0
  }

  public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return heightForRow(at: indexPath.section)
  }

  public override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return heightForRow(at: indexPath.section)
  }

  public override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

    let dynamicHeaderHeight = getHeight(forRowAt: IndexPath(row: 0, section: section))
    guard dimension.dateHeaderWidth > dynamicHeaderHeight else {
      return dimension.dateHeaderHeight
    }
    return dynamicHeaderHeight
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let tableCell = UITableViewCell()
    tableCell.backgroundColor = AnywhereCalendarView.mainSDK.theme.dateHeaderBackgroundColor
    return tableCell
  }

  public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

    guard let header = customizationProvider?.dequeueCalendarHeader(at: section) as? ConfigurableHeaderFooterView, let date = viewModel?.getDate(at: section) else {
      return nil
    }
    header.configure(date, at: section)
    return header
  }

  public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

    let dynamicHeaderHeight = getHeight(forRowAt: IndexPath(row: 0, section: section))
    guard dimension.dateHeaderHeight > dynamicHeaderHeight else {
      return dimension.dateHeaderHeight
    }
    return dynamicHeaderHeight
  }

  public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollScheduleView(self)
  }
}

extension ScheduleDateTableViewController: ScheduleTableVCProtocol {

  public var contentOffset: CGPoint {
    get {
      tableView.contentOffset
    }
    set {
      tableView.contentOffset = newValue
    }
  }

  public func reloadCalendar() {
    tableView.reloadData()
  }

  public func insertSection(at section: Int) {
    tableView.insertSections(IndexSet(integer: section), with: .none)
  }

  public func deleteSection(at section: Int) {
    tableView.insertSections(IndexSet(integer: section), with: .none)
  }

  public func reloadItems(at indexPaths: [IndexPath]) {
    tableView.reloadRows(at: indexPaths, with: .none)
  }

  public func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> ConfigurableCell? {

    return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ConfigurableCell
  }
  public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
    tableView.register(nib, forCellReuseIdentifier: identifier)
  }

  public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
    tableView.register(cellClass, forCellReuseIdentifier: identifier)
  }

  public func register(_ viewType: ConfigurableView.Type, forHeaderFooterViewReuseIdentifier identifier: String) {

    guard let viewClass = viewType as? ConfigurableHeaderFooterView.Type else {
      assertionFailure("\(viewType.reuseIdentifier) needs to be UITableViewHeaderFooterView!")
      return
    }

    tableView.register(viewClass.self, forHeaderFooterViewReuseIdentifier: identifier)
  }

  public func register(_ nibType: CalendarHeaderFooterNib.Type, forHeaderFooterViewReuseIdentifier identifier: String) {

    guard nibType as? ConfigurableHeaderFooterView.Type != nil else {
      assertionFailure("Need to register a UITableViewHeaderFooterView!")
      return
    }

    tableView.register(nibType.getNib(), forHeaderFooterViewReuseIdentifier: identifier)
  }

  public func dequeueReusableHeaderFooterView(withReuseIdentifier identifier: String, for section: Int) -> ConfigurableView? {

    return tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? ConfigurableView
  }


  // this method is used to compute the height of the single cell in the date table view for sticky date
  func heightForRow(at section: Int) -> CGFloat {

    // Checking the number of events to compute the cell height
    guard let numberOfEvents = viewModel?.numberOfRows(at: section), numberOfEvents > 0  else {
      return 0
    }

    var dynamicHeight = getHeight(forSection: section, andNoOfEvents: numberOfEvents)

    let correspondenceHeight = getHeight(forRowAt: IndexPath(row: 0, section: section))
    dynamicHeight -= (correspondenceHeight < dimension.dateHeaderHeight ? correspondenceHeight : dimension.dateHeaderHeight)
    return dynamicHeight
  }

  // Gives the height based on number of events
  func getHeight(forSection section: Int, andNoOfEvents count: Int) -> CGFloat {

    var dynamicHeight: CGFloat = 0
    for index in 0..<count {
      dynamicHeight +=  getHeight(forRowAt: IndexPath(row: index, section: section))
    }
    return dynamicHeight
  }

  // This method is used to get the dynamic height provied by the app for the calendar item in the schedule view
  func getHeight(forRowAt indexPath: IndexPath) -> CGFloat {
    return customizationProvider?.delegate?.height(forRowAt: indexPath) ?? dimension.cellHeight
  }

  public func set(backgroundView view: UIView?) {
    tableView.backgroundView = view
  }

}
