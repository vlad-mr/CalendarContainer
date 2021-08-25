//
//  FullCalendarBaseViewController.swift
//  AnywhereCalendarView
//
//  Created by Vignesh on 04/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
#if canImport(CalendarUtils)
import CalendarUtils
#endif

public protocol ConstraintModifier: AnyObject {
  func updateTopConstraint(withConstant constant: CGFloat, sender: UIViewController)
  func updateTopConstraint(withConstant constant: CGFloat)
}

public class CalendarViewController: UIViewController, CalendarView {

  lazy var topBorderLine = configure(UIView()) {
    $0.backgroundColor = UIColor.clear
    $0.translatesAutoresizingMaskIntoConstraints = false
  }

  lazy var timeHeaderTopContraint = topBorderLine.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.viewConfig.shouldShowDateHeader ? self.viewConfig.calendarDimensions.dateHeaderHeight : 0)

  lazy var timeHeaderScrollView: UIScrollView = configure(UIScrollView()) {
    $0.delegate = self
    $0.backgroundColor = AnywhereCalendarView.mainSDK.theme.timeHeaderBackgroundColor
    $0.showsVerticalScrollIndicator = false
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.contentSize = CGSize(width: self.viewConfig.calendarDimensions.timeHeaderWidth, height: viewConfig.slotSize.dayHeight)
  }

  lazy var timeHeaderView: UICollectionView = {
    let timeHeaderLayout = TimeHeaderLayout(withSlotSize: self.viewConfig.slotSize, calendarDimensions: self.viewConfig.calendarDimensions, currentTimeIndicator: self.viewConfig.currentTimeIndicator)
    let _timeHeaderView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.viewConfig.calendarDimensions.timeHeaderWidth, height: viewConfig.slotSize.dayHeight), collectionViewLayout: timeHeaderLayout)
    _timeHeaderView.dataSource = self
    _timeHeaderView.backgroundColor = AnywhereCalendarView.mainSDK.theme.timeHeaderBackgroundColor //.white // .timeHeaderBackgroundColor
    _timeHeaderView.register(TimeHeader.self,
                             forSupplementaryViewOfKind: FullCalendarSupplementaryViewKind.hourLabel.identifier,
                             withReuseIdentifier: FullCalendarSupplementaryViewKind.hourLabel.identifier)
    _timeHeaderView.register(TimeHeaderTriangleView.self,
                             forSupplementaryViewOfKind: FullCalendarSupplementaryViewKind.currentTimeTriangle.identifier,
                             withReuseIdentifier: FullCalendarSupplementaryViewKind.currentTimeTriangle.identifier)
    _timeHeaderView.register(TimeHeader.self,
                             forSupplementaryViewOfKind: FullCalendarSupplementaryViewKind.rowHeader.rawValue,
                             withReuseIdentifier: FullCalendarSupplementaryViewKind.rowHeader.rawValue)
    return _timeHeaderView
  }()

  lazy var calendarPageContainer: UIView = configure(UIView()) {
    $0.backgroundColor = AnywhereCalendarView.mainSDK.theme.workingHoursBackgroundColor
    $0.translatesAutoresizingMaskIntoConstraints = false
  }

  lazy var calendarPage: CalendarPageViewController = configure(CalendarViewControllers.calendarPageView) {
    $0.calendarLayoutDelegate = self
    $0.constraintModifier = self
    addChild($0)
  }

  public var dataProvider: CalendarDataProvider? {
    didSet {
      self.calendarPage.calendarDataProvider = self.dataProvider
    }
  }

  public weak var actionDelegate: CalendarActionDelegate? {
    didSet {
      self.calendarPage.calendarActionDelegate = self.actionDelegate
    }
  }

  var viewConfig: CalendarViewConfiguration = CalendarViewConfiguration() {
    didSet {
      self.calendarPage.viewConfig = self.viewConfig
    }
  }

  var didScrolledToCurrentTime: Bool = false

  var layoutType: CalendarLayoutType = .daily {
    didSet {
      calendarPage.layoutType = self.layoutType
    }
  }

  public var staffKey: String = "" {
    didSet {
      if staffKey != oldValue {
        reloadCalendar()
      }
    }
  }

  public var activeDate: Date = Date().dateAtStartOf(.day) {
    didSet {
      guard calendarPage.doesVisiblePageContain(date: activeDate) else {
        calendarPage.setDefaultView()
        return
      }
      reloadCalendar()
    }
  }

  public var startDateOfActivePage: Date? {
    return calendarPage.startDateOfVisibleView
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = AnywhereCalendarView.mainSDK.theme.timeHeaderBackgroundColor
    addTimeHeaderView()
    addCalendarView()
    self.view.layoutViewWithoutAnimation()
    calendarPage.setDefaultView()
    addObservers()
  }

  func addTimeHeaderView() {
    self.view.addSubViews([topBorderLine,timeHeaderScrollView])
    timeHeaderScrollView.addSubview(timeHeaderView)
    setupTimeHeaderConstraints()
  }

  func addCalendarView() {
    self.view.addSubview(calendarPageContainer)
    calendarPageContainer.addSubview(calendarPage.view)
    setupCalendarViewConstraints()
  }

  func addObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleSignificantTimeChange), name: UIApplication.significantTimeChangeNotification, object: nil)
  }

  func setupTimeHeaderConstraints() {

    NSLayoutConstraint.activate([
      //top border line
      timeHeaderTopContraint,
      topBorderLine.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
      topBorderLine.widthAnchor.constraint(equalToConstant: self.viewConfig.calendarDimensions.timeHeaderWidth),
      topBorderLine.heightAnchor.constraint(equalToConstant: 1),

      //time header scroll view
      timeHeaderScrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      timeHeaderScrollView.topAnchor.constraint(equalTo: topBorderLine.bottomAnchor, constant: 0),
      timeHeaderScrollView.widthAnchor.constraint(equalToConstant: self.viewConfig.calendarDimensions.timeHeaderWidth),
      timeHeaderScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
    ])
  }

  func setupCalendarViewConstraints() {
    NSLayoutConstraint.activate([

      //calendar container view
      calendarPageContainer.leadingAnchor.constraint(equalTo: timeHeaderView.trailingAnchor, constant: 0),
      calendarPageContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      calendarPageContainer.topAnchor.constraint(equalTo: view.topAnchor),
      calendarPageContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      //calendar view
      calendarPage.view.leadingAnchor.constraint(equalTo: calendarPageContainer.leadingAnchor),
      calendarPage.view.trailingAnchor.constraint(equalTo: calendarPageContainer.trailingAnchor),
      calendarPage.view.topAnchor.constraint(equalTo: calendarPageContainer.topAnchor),
      calendarPage.view.bottomAnchor.constraint(equalTo: calendarPageContainer.bottomAnchor)
    ])
  }

  @objc func handleSignificantTimeChange() {
    if AnywhereCalendarView.mainSDK.currentTimeFormat != AnywhereCalendarView.mainSDK.calConfig.timeFormat {
      timeHeaderView.reloadData()
    }
    self.reloadCalendar()
  }

  var lastScrollPostion: CGPoint?

  // TODO: when zoom in happened this has to be recalculated
  lazy var defaultScrollOffSet: CGPoint = {

    let hourHeight: CGFloat = CGFloat(Date().hour * 120)
    let offsetToReduce = UIScreen.main.bounds.height / 4

    if hourHeight < offsetToReduce {
      return CGPoint.zero
    } else {
      let x = (self.view.bounds.height - 60)
      let y = (self.timeHeaderView.frame.height / x)
      let scrollPostionHeight = (x * y) - x

      while hourHeight > scrollPostionHeight {
        return CGPoint(x: 0, y: scrollPostionHeight)
      }
      return CGPoint(x: 0, y: hourHeight - offsetToReduce)
    }
  }()

  override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    //        setDefaultScrollPosition()
    let secondsToWait: TimeInterval = TimeInterval(60 - Date().second)
    DispatchQueue.main.asyncAfter(deadline: .now() + secondsToWait) {
      self.updateCurrentTimeLine()
      _ = Timer.scheduledTimer(timeInterval: 60.0,
                               target: self,
                               selector: #selector(self.updateCurrentTimeLine),
                               userInfo: nil,
                               repeats: true)
    }
  }

  @objc public func updateCurrentTimeLine() {
    DispatchQueue.main.async {
      guard let layout = self.timeHeaderView.collectionViewLayout as? TimeHeaderLayout else {
        return
      }
      layout.updateCurrentTime()
      self.timeHeaderView.reloadData()
    }
  }

  private func setDefaultScrollPosition() {
    guard !didScrolledToCurrentTime else {
      return
    }
    timeHeaderScrollView.contentOffset = defaultScrollOffSet
    didScrolledToCurrentTime = true
  }

  // TODO:- Need to handle refreshing the calendar pages
  public func reloadCalendar() {
    calendarPage.reloadAllPages()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
    print("deinit calendar view controller")
  }
}

extension CalendarViewController: UICollectionViewDataSource {

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView == timeHeaderScrollView {
      calendarPage.setScrollOffSetToVisibleView(scrollView.contentOffset)
    }
  }
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 0
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return UICollectionViewCell()
  }

  public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

    guard let supplementaryViewKind = FullCalendarSupplementaryViewKind(rawValue: kind) else {
      return UICollectionReusableView()
    }
    switch supplementaryViewKind {
    case .hourLabel:
      let view = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: FullCalendarSupplementaryViewKind.hourLabel.identifier,
        for: indexPath) as! TimeHeader
      view.setTimeText(with: indexPath.row)
      return view
    case .rowHeader:
      let view = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: FullCalendarSupplementaryViewKind.rowHeader.identifier,
        for: indexPath) as! TimeHeader
      view.setCurrentTimeText()
      return view
    case .currentTimeTriangle:
      let view = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: FullCalendarSupplementaryViewKind.currentTimeTriangle.identifier,
        for: indexPath) as! TimeHeaderTriangleView
      return view
    default:
      return UICollectionReusableView()
    }
  }
}

extension CalendarViewController: UIScrollViewDelegate, CalendarLayoutDelegate {
  var calendarScrollOffset: CGPoint? {
    return lastScrollPostion
  }

  public func calendarViewDidScroll(_ scrollView: UIScrollView) {
    lastScrollPostion = scrollView.contentOffset
    timeHeaderScrollView.contentOffset = scrollView.contentOffset
  }
}

extension CalendarViewController {
  public func setActiveDate(_ date: Date) {
    activeDate = date
  }
}

extension CalendarViewController: ConstraintModifier {

  public func updateTopConstraint(withConstant constant: CGFloat) {
    //Laying out the view without any animation before updating the top constraint, inorder to avoid unwanted animations on the other views
    self.view.layoutViewWithoutAnimation()
    if !timeHeaderTopContraint.isActive {
      self.timeHeaderTopContraint.isActive = true
    }
    self.timeHeaderTopContraint.constant = constant
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }

  public func updateTopConstraint(withConstant constant: CGFloat, sender: UIViewController) {

    guard calendarPage.currentCalendarView == sender else {
      return
    }
    updateTopConstraint(withConstant: constant)
  }
}
