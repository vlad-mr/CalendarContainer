//
//  DrawerSource.swift
//  AnywhereCalendarSDK_Example
//
//  Created by Essence K on 19.08.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import CalendarSDK

public class DrawerPresentableViewController: UIViewController, DrawerViewControllerDelegate {
  private lazy var drawerController = DrawerViewController(theme: theme)
  private var drawerLeadingConstraint: NSLayoutConstraint!

  var drawerWidth: CGFloat {
    return UIScreen.main.bounds.width - 50
  }

  var theme: DrawerTheme {
    return DefaultDrawerTheme()
  }

  private let shadowView: UIView = {
    let view = UIView()
    view.backgroundColor = .init(red: 2/255, green: 11/255, blue: 43/255, alpha: 0.3)
    view.isHidden = true
    view.alpha = 0
    view.isUserInteractionEnabled = true
    return view
  }()

  private(set) var isDrawerPresented = false

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    shadowView.frame = UIScreen.main.bounds
    view.addSubview(shadowView)
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapShadowView))
    shadowView.addGestureRecognizer(tap)

    drawerController.setDelegate(self)
    view.addSubview(drawerController.view)

    addChild(drawerController)
    drawerController.didMove(toParent: self)
    drawerController.view.translatesAutoresizingMaskIntoConstraints = false
    drawerLeadingConstraint = drawerController.view.leadingAnchor.constraint(
      equalTo: view.leadingAnchor,
      constant: -drawerWidth
    )
    NSLayoutConstraint.activate([
      drawerController.view.widthAnchor.constraint(equalToConstant: drawerWidth),
      drawerController.view.topAnchor.constraint(equalTo: view.topAnchor),
      drawerController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      drawerLeadingConstraint
    ])
  }

  @objc private func didTapShadowView() {
    hideDrawer()
  }

  @objc public func showDrawer() {
    view.bringSubviewToFront(shadowView)
    view.bringSubviewToFront(drawerController.view)
    drawerLeadingConstraint.constant = 0
    shadowView.isHidden = false
    UIView.animate(withDuration: 0.2) {
      self.view.layoutSubviews()
      self.shadowView.alpha = 1.0
    }
    isDrawerPresented = true
  }

  @objc public func hideDrawer() {
    drawerLeadingConstraint.constant = -drawerWidth
    shadowView.isHidden = true
    UIView.animate(withDuration: 0.2) {
      self.view.layoutSubviews()
      self.shadowView.alpha = 0
    }
    isDrawerPresented = false
  }

  public func setItems(_ items: [SelectorCellModel]) {
    drawerController.setItems(items)
  }

  public func highlightCell(atRow row: Int) {
    drawerController.highlightCell(atRow: row)
  }

  public func selectedCell(_ row: Int) {
    hideDrawer()
  }

  public func configureHeader(image: UIImage?, title: String) {
    drawerController.configureHeader(image: image, title: title)
  }
}

protocol DrawerTheme {
  var backgroundColor: UIColor { get }

  // Header
  var headerBackgroundColor: UIColor { get }
  var headerImageColor: UIColor  { get }
  var headerTextColor: UIColor  { get }
  var headerFont: UIFont  { get }

  // Cell
  var cellBackgroundColor: UIColor { get }
  var cellSelectedColor: UIColor  { get }
  var cellTextColor: UIColor  { get }
  var cellSelectedTextColor: UIColor  { get }
  var cellImageColor: UIColor  { get }
  var cellSelectedImageColor: UIColor  { get }
  var cellFont: UIFont  { get }
}

class DefaultDrawerTheme: DrawerTheme {
  public var backgroundColor: UIColor = .white

  // Header
  public var headerBackgroundColor: UIColor = .white
  public var headerImageColor: UIColor = .init(red: 29/255, green: 144/255, blue: 245/255, alpha: 1)
  public var headerTextColor: UIColor = .black
  public var headerFont: UIFont = .systemFont(ofSize: 16, weight: .semibold)

  // Cell
  public var cellBackgroundColor: UIColor = .white
  public var cellSelectedColor: UIColor = .init(red: 29/255, green: 144/255, blue: 245/255, alpha: 0.05)
  public var cellTextColor: UIColor = .black
  public var cellSelectedTextColor: UIColor = .init(red: 29/255, green: 144/255, blue: 245/255, alpha: 1)
  public var cellImageColor: UIColor = .init(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
  public var cellSelectedImageColor: UIColor = .init(red: 29/255, green: 144/255, blue: 245/255, alpha: 1)
  public var cellFont: UIFont = .systemFont(ofSize: 16, weight: .semibold)
}

protocol DrawerViewControllerDelegate: AnyObject {
  func selectedCell(_ row: Int)
}

class DrawerViewController: UIViewController, SelectorViewDelegate {
  private let theme: DrawerTheme

  private let padding: CGFloat = 16.0

  private lazy var header = DrawerHeaderView(theme: theme)
  private lazy var selectorView = SelectorView(theme: theme)

  private weak var delegate: DrawerViewControllerDelegate?

  init(theme: DrawerTheme) {
    self.theme = theme
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  private func setup() {
    view.backgroundColor = theme.backgroundColor
    setupHeader()
    setupSelectorView()
    selectorView.setDelegate(self)
  }

  private func setupHeader() {
    view.addSubview(header)
    NSLayoutConstraint.activate([
      header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      header.heightAnchor.constraint(equalToConstant: padding * 4)
    ])
  }

  private func setupSelectorView() {
    view.addSubview(selectorView)
    NSLayoutConstraint.activate([
      selectorView.topAnchor.constraint(equalTo: header.bottomAnchor),
      selectorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      selectorView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }

  public func setDelegate(_ delegate: DrawerViewControllerDelegate?) {
    self.delegate = delegate
  }

  public func setItems(_ items: [SelectorCellModel]) {
    selectorView.setItems(items)
  }

  public func selectedCell(_ row: Int) {
    delegate?.selectedCell(row)
  }

  public func highlightCell(atRow row: Int) {
    selectorView.highlightCell(atRow: row)
  }

  public func configureHeader(image: UIImage?, title: String) {
    header.configure(image: image, title: title)
  }
}

class DrawerHeaderView: UIView {
  let theme: DrawerTheme

  private let padding: CGFloat = 16.0

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  private lazy var label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = theme.headerFont
    label.textColor = theme.headerTextColor
    return label
  }()

  init(theme: DrawerTheme) {
    self.theme = theme
    super.init(frame: .zero)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = theme.headerBackgroundColor
    setupImageView()
    setupLabel()
  }

  private func setupImageView() {
    addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.heightAnchor.constraint(equalToConstant: padding * 2),
      imageView.widthAnchor.constraint(equalToConstant: padding * 2),
      imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding)
    ])
  }

  private func setupLabel() {
    addSubview(label)
    NSLayoutConstraint.activate([
      label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
      label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: padding),
      label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
    ])
  }

  public func configure(image: UIImage?, title: String) {
    imageView.image = image
    label.text = title
  }
}

protocol SelectorViewDelegate: AnyObject {
  func selectedCell(_ row: Int)
}

class SelectorView: UIView, UITableViewDelegate, UITableViewDataSource {
  private let theme: DrawerTheme

  private let padding: CGFloat = 16.0

  private lazy var tableView: SelfSizedTableView = {
    let table = SelfSizedTableView()
    table.translatesAutoresizingMaskIntoConstraints = false
    table.register(SelectorTableViewCell.self, forCellReuseIdentifier: SelectorTableViewCell.reuseIdentifier)
    table.delegate = self
    table.dataSource = self
    table.rowHeight = padding * 4
    table.estimatedRowHeight = padding * 4
    table.isScrollEnabled = false
    table.separatorStyle = .none
    return table
  }()
  private var tableHeightConstraint: NSLayoutConstraint!

  private var items: [SelectorCellModel] = []

  private weak var delegate: SelectorViewDelegate?

  init(theme: DrawerTheme) {
    self.theme = theme
    super.init(frame: .zero)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    translatesAutoresizingMaskIntoConstraints = false
    setupTableView()
  }

  private func setupTableView() {
    addSubview(tableView)
    tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: topAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
      tableHeightConstraint
    ])
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectorTableViewCell.reuseIdentifier, for: indexPath) as? SelectorTableViewCell else {
      return UITableViewCell()
    }
    cell.configure(items[indexPath.row], theme: theme)
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.selectedCell(indexPath.row)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return padding * 4
  }

  public func highlightCell(atRow row: Int) {
    guard items.count > row else { return }
    tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
  }

  public func setItems(_ items: [SelectorCellModel]) {
    self.items = items
    tableView.reloadData()
    tableHeightConstraint.constant = tableView.intrinsicContentSize.height
  }

  public func setDelegate(_ delegate: SelectorViewDelegate?) {
    self.delegate = delegate
  }
}


class SelfSizedTableView: UITableView {
  var maxHeight: CGFloat = UIScreen.main.bounds.size.height

  override func reloadData() {
    super.reloadData()
    self.invalidateIntrinsicContentSize()
    self.layoutIfNeeded()
  }

  override var intrinsicContentSize: CGSize {
    setNeedsLayout()
    layoutIfNeeded()
    let height = min(contentSize.height, maxHeight)
    return CGSize(width: contentSize.width, height: height)
  }
}

public protocol SelectorCellModel {
  var image: UIImage? { get }
  var title: String { get }
}

struct SelectorItem: SelectorCellModel {
  let image: UIImage?
  let title: String
}

class SelectorTableViewCell: UITableViewCell, ReusableView {
  private var theme: DrawerTheme = DefaultDrawerTheme()

  private let padding: CGFloat = 16.0

  private let iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  private let label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 16)
    return label
  }()

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(false, animated: animated)
    label.textColor = selected ? theme.cellSelectedTextColor : theme.cellTextColor
    iconImageView.tintColor = selected ? theme.cellSelectedImageColor : theme.cellImageColor
    contentView.backgroundColor = selected ? theme.cellSelectedColor : theme.cellBackgroundColor
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    setupImageView()
    setupLabel()
  }

  private func setupImageView() {
    contentView.addSubview(iconImageView)
    NSLayoutConstraint.activate([
      iconImageView.heightAnchor.constraint(equalToConstant: padding * 1.5),
      iconImageView.widthAnchor.constraint(equalToConstant: padding * 2),
      iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding)
    ])
  }

  private func setupLabel() {
    contentView.addSubview(label)
    NSLayoutConstraint.activate([
      label.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
      label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: padding),
      label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
    ])
  }

  public func configure(_ item: SelectorCellModel, theme: DrawerTheme = DefaultDrawerTheme()) {
    self.theme = theme
    label.font = theme.cellFont
    label.textColor = theme.cellTextColor
    iconImageView.image = item.image?.withRenderingMode(.alwaysTemplate)
    iconImageView.tintColor = theme.cellImageColor
    label.text = item.title
  }
}
