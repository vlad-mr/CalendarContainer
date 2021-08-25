//
//  ScheduleEventTableViewController.swift
//  Anytime
//
//  Created by Deepika on 04/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

public protocol ScheduleEventTableVCProtocol: ScheduleTableVCProtocol {

  var actionDelegate: CalendarActionDelegate? { get set }
  var config: ScheduleViewConfiguration { get set }
  var numberOfSections: Int { get }
  func scrollToRow(at indexPath: IndexPath, with scrollPosition: UITableView.ScrollPosition)
}

public class ScheduleEventTableViewController: UITableViewController {

  public var viewModel: ScheduleVMProtocol?
  public weak var actionDelegate: CalendarActionDelegate?
  public weak var scrollDelegate: ScheduleCalendarScrollDelegate?
  public var customizationProvider: FullCalendarCustomizationProvider?
  public lazy var config: ScheduleViewConfiguration = ScheduleViewConfiguration()

  public convenience init(withConfig config: ScheduleViewConfiguration = ScheduleViewConfiguration()) {
    self.init()
    self.config = config
  }

  public lazy var dimension: ScheduleViewDimensions = ScheduleViewDimensions()

  private func cellFor(tableView: UITableView, forCellAt indexPath: IndexPath, item: CalendarItem) -> UITableViewCell {

    guard let cell = customizationProvider?.dequeueCalendarCell(forIndexPath: indexPath) as? ConfigurableTableViewCell else {
      return UITableViewCell()
    }
    cell.selectionStyle = .none
    cell.configure(item, at: indexPath)
    return cell
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupTable()
  }

  private func setupTable() {
    tableView.separatorStyle = .none
    tableView.tableFooterView = UIView()
    tableView.backgroundColor = AnywhereCalendarView.mainSDK.theme.backgroundColor
    
    let refreshControl = UIRefreshControl()
    refreshControl.backgroundColor = AnywhereCalendarView.mainSDK.theme.backgroundColor
    refreshControl.tintColor = AnywhereCalendarView.mainSDK.theme.heading
    refreshControl.addTarget(self, action: #selector(refreshCalendar), for: .valueChanged)
    self.refreshControl = refreshControl
  }

  @objc public func refreshCalendar() {
    actionDelegate?.refreshContent()
  }

  // MARK: - Table view data source

  public override func numberOfSections(in tableView: UITableView) -> Int {

    guard config.shouldShowEventView else {
      return 0
    }
    guard let viewModel = self.viewModel else {
      assertionFailure("ViewModel is nil in the schedule event VC!")
      return 0
    }
    return viewModel.numberOfSections
  }

  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    if viewModel?.canShowPlaceholder(forSection: section) ?? true {
      return 1
    }

    guard config.shouldShowEventView else {
      return 0
    }
    return viewModel?.numberOfRows(at: section) ?? 0
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    self.getTableViewCellFor(indexPath: indexPath)
  }

  private func getTableViewCellFor(indexPath: IndexPath) -> UITableViewCell {

    guard let event = viewModel?.getCalendarItem(at: indexPath) else {
      guard viewModel?.canShowPlaceholder(forSection: indexPath.section) ?? false else {
        return UITableViewCell()
      }
      let tableCell = UITableViewCell(style: .default, reuseIdentifier: "TablePlaceholder")
      tableCell.textLabel?.text = "·"
      tableCell.textLabel?.textAlignment = .center
      tableCell.textLabel?.setMargins(margin: 70 + (UIScreen.main.bounds.width / 11))
      return tableCell
    }
    return cellFor(tableView: tableView, forCellAt: indexPath, item: event)
  }

  public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return customizationProvider?.delegate?.height(forRowAt: indexPath) ?? dimension.cellHeight
  }

  public override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return customizationProvider?.delegate?.height(forRowAt: indexPath) ?? dimension.cellHeight
  }

  public override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    customizationProvider?.swipeActionDelegate?.trailingSwipeActionsConfiguration(forRowAt: indexPath)
  }

  public override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

    customizationProvider?.swipeActionDelegate?.leadingSwipeActionsConfiguration(forRowAt: indexPath)
  }

  public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    guard let calendarItem = viewModel?.getCalendarItem(at: indexPath) else {
      return
    }
    actionDelegate?.didSelectCell(for: calendarItem)
  }

  public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollScheduleView(self)

    guard let actionDelegate = self.actionDelegate, let section = tableView.indexPathsForVisibleRows?.first?.section, let date = viewModel?.getDate(at: section) else {
      return
    }
    actionDelegate.didScroll(toDate: date)
  }

  public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

    guard config.shouldShowHeader, let header = customizationProvider?.dequeueCalendarHeader(at: section), let date = viewModel?.getDate(at: section) else {
      return nil
    }

    header.configure(date, at: section)
    header.actionDelegate = self.actionDelegate
    return header as? ConfigurableHeaderFooterView
  }

  public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return config.shouldShowHeader ? dimension.dateHeaderHeight : 0
  }

  public override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

    //        guard config.shouldShowPlaceholderOnEmptyDay, viewModel?.canShowPlaceholder(forSection: section) ?? true else {
    return nil
    //        }

    guard let placeHolder = customizationProvider?.dequeueCalendarPlaceholder(at: section) as? ConfigurableHeaderFooterView, let date = viewModel?.getDate(at: section) else {
      let label = UILabel()
      label.text = config.textForNoEventDay
      label.textAlignment = .center
      return label
    }
    placeHolder.configure(date, at: section)
    placeHolder.actionDelegate = actionDelegate
    return placeHolder

  }

  public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    //        guard config.shouldShowPlaceholderOnEmptyDay, viewModel?.canShowPlaceholder(forSection: section) ?? true else {
    if config.shouldAllowFreeScrollToBottom, section == numberOfSections - 1 {
      let heightToReduce = CGFloat(64 + 100 + 35 + 83)
      return UIScreen.main.bounds.height - heightToReduce
    }
    return 0
    //        }
    //        return dimension.cellHeight
  }

}

extension ScheduleEventTableViewController: ScheduleEventTableVCProtocol {

  public var numberOfSections: Int {
    tableView.numberOfSections
  }

  public var contentOffset: CGPoint {
    get {
      tableView.contentOffset
    }
    set {
      tableView.contentOffset = newValue
    }
  }

  public func insertSection(at section: Int) {
    tableView.insertSections(IndexSet(integer: section), with: .none)
  }

  public func deleteSection(at section: Int) {
    tableView.deleteSections(IndexSet(integer: section), with: .none)
  }

  public func reloadSection(at section: Int) {
    tableView.reloadSections(IndexSet(integer: section), with: .none)
  }

  public func insertItems(at indexPaths: [IndexPath]) {
    var indexPathToInsert = [IndexPath]()
    var indexPathToReload = [IndexPath]()
    indexPaths.forEach({
      if (viewModel?.numberOfRows(at: $0.section) == 1) && $0.row == 0 {
        indexPathToReload.append($0)
      } else {
        indexPathToInsert.append($0)
      }
    })
    if indexPathToReload.isNotEmpty {
      tableView.reloadRows(at: indexPathToReload, with: .none)
    }
    if indexPathToInsert.isNotEmpty {
      tableView.insertRows(at: indexPathToInsert, with: .none)
    }
  }

  public func deleteItems(at indexPaths: [IndexPath]) {
    var indexPathToDelete = [IndexPath]()
    var indexPathToReload = [IndexPath]()
    indexPaths.forEach({
      if (viewModel?.canShowPlaceholder(forSection: $0.section) ?? false) && $0.row == 0 {
        indexPathToReload.append($0)
      } else {
        indexPathToDelete.append($0)
      }
    })
    if indexPathToDelete.isNotEmpty {
      tableView.deleteRows(at: indexPathToDelete, with: .none)
    }
    if indexPathToReload.isNotEmpty {
      tableView.reloadRows(at: indexPathToReload, with: .none)
    }
  }

  public func scrollToRow(at indexPath: IndexPath, with scrollPosition: UITableView.ScrollPosition) {

    tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
  }

  public func set(backgroundView view: UIView?) {
    tableView.backgroundView = view
    view?.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
  }

  public func reloadCalendar() {
    if refreshControl?.isRefreshing ?? false {
      refreshControl?.endRefreshing()
    }
    tableView.reloadData()
  }

  public func reloadItems(at indexPaths: [IndexPath]) {
    tableView.reloadRows(at: indexPaths, with: .none)
  }


  public func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> ConfigurableCell? {
    tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ConfigurableCell
  }

  public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
    tableView.register(nib, forCellReuseIdentifier: identifier)
  }

  public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
    tableView.register(cellClass, forCellReuseIdentifier: identifier)
  }

  public func register(_ viewType: ConfigurableView.Type, forHeaderFooterViewReuseIdentifier identifier: String) {

    guard let viewClass = viewType as? ConfigurableHeaderFooterView.Type else {
      assertionFailure("Need to register a UITableViewHeaderFooterView!")
      return
    }

    tableView.register(viewClass, forHeaderFooterViewReuseIdentifier: identifier)
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
}
