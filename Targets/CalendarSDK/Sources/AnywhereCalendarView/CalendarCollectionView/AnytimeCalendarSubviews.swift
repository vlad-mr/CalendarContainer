//
//  AnytimeCalendarSubviews.swift
//  Anytime
//
//  Created by Vignesh on 20/02/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
#if canImport(CalendarUtils)
import CalendarUtils
#endif

enum FullCalendarDecorationViewKind: String {
    
    case currentDayLine
    case verticalSeparator
    case horizonalSeparator
    case workingHoursDivLine
    case offHoursGridLine
    case workingHoursView
    case outOfBoundsView
    case currentTimeIndicatorLine
    case currentTimeIndicatorCircle
    
    var identifier: String {
        self.rawValue
    }
}

enum FullCalendarSupplementaryViewKind: String {
    case rowHeader
    case columnHeader
    case monthHeader
    case hourLabel
    case currentTimeTriangle
    
    var identifier: String {
        self.rawValue
    }
}

class DrawerPresentableViewController: UIViewController, DrawerViewControllerDelegate {
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

    override func viewDidLoad() {
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

    public func showDrawer() {
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

    public func hideDrawer() {
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

protocol SelectorCellModel {
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


// MARK: Font Configuration
struct AnyCalFont {
    var font: UIFont
    
    init(font: UIFont) {
        self.font = font
    }
    
    private var headerSize: CGFloat = 15
    
    private var subheaderSize: CGFloat = 9
    
    private var defaultSize: CGFloat = 12
}

extension AnyCalFont {
    
    var header: UIFont {
        return font.withSize(headerSize)
    }
    
    var subHeader: UIFont {
        return font.withSize(subheaderSize)
    }
    
    var normal: UIFont {
        return font.withSize(defaultSize)
    }
}

// MARK: ReusableViews
class RowHeader: UICollectionReusableView {
    
    var timeLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        timeLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        timeLabel?.textAlignment = .center
        timeLabel?.backgroundColor = AnywhereCalendarView.mainSDK.theme.timeHeaderBackgroundColor
        timeLabel?.font = AnywhereCalendarView.mainSDK.font.normal
        timeLabel?.textColor = AnywhereCalendarView.mainSDK.theme.subHeading
        self.addSubview(timeLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class WorkingHoursDivLine: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = AnywhereCalendarView.mainSDK.theme.workingHoursDivLineColor
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class OffHourGridLine: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let stripe = DiagonalLinesView(frame: frame)
        stripe.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 0.5)
        
        self.addSubview(stripe)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// Header View on Top Left
class MonthHeader: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class VerticalGridLine: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = AnywhereCalendarView.mainSDK.theme.daySeparatorColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class HorizontalGridLine: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = AnywhereCalendarView.mainSDK.theme.hourSeparatorColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class DashedHorizontalGridLine: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let shape = CAShapeLayer()
        shape.strokeColor = AnywhereCalendarView.mainSDK.theme.daySeparatorColor.cgColor
        shape.lineWidth = 1
        shape.lineDashPattern = [8, 8]
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: 0), CGPoint(x: self.bounds.width, y: 0)])
        shape.path = path
        layer.addSublayer(shape)
    }
}

class WorkingHoursView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = AnywhereCalendarView.mainSDK.theme.workingHoursBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class OutOfBoundsView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = AnywhereCalendarView.mainSDK.theme.backgroundColor
        self.layer.addBorder(edge: .bottom, color: .lightGray, thickness: 0.75)
        self.layer.addBorder(edge: .top, color: .lightGray, thickness: 0.75)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Weakly calendar cell
public class AnytimeWeaklyEventCell: UICollectionViewCell, ConfigurableCell {
    private let padding: CGFloat = 16.0
    private var sourceViewWidthConstraint: NSLayoutConstraint!

    private let sourceView = EventSourceView()
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()
    private let eventLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AnywhereCalendarView.mainSDK.font.normal.withSize(10)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textColor = .black
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureCell()
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        eventLabel.isHidden = false
    }

    private func configureCell() {
        backgroundColor = .clear
        contentView.backgroundColor = UIColor.grey100
        contentView.layer.cornerRadius = 6
        contentView.clipsToBounds = true
        setupSourceView()
        setupContainerView()
        setupEventLabel()
    }

    private func setupSourceView() {
        contentView.addSubview(sourceView)
        sourceViewWidthConstraint = sourceView.widthAnchor.constraint(equalToConstant: 2)
        NSLayoutConstraint.activate([
            sourceViewWidthConstraint,
            sourceView.topAnchor.constraint(equalTo: contentView.topAnchor),
            sourceView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sourceView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func setupContainerView() {
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1)
        ])
    }

    private func setupEventLabel() {
        containerView.addSubview(eventLabel)
        NSLayoutConstraint.activate([
            eventLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            eventLabel.leadingAnchor.constraint(equalTo: sourceView.trailingAnchor, constant: 2),
            eventLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2),
            eventLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    override public func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        if layoutAttributes.size.width < UIScreen.main.bounds.width / 20 {
            eventLabel.isHidden = true
            sourceViewWidthConstraint.constant = layoutAttributes.size.width
        }
        eventLabel.numberOfLines = layoutAttributes.size.height > layoutAttributes.size.width ? 3 : 2
        if layoutAttributes.size.height <= 16 {
            eventLabel.font = AnywhereCalendarView.mainSDK.font.normal.withSize(layoutAttributes.size.height / 2)
        }
        if layoutAttributes.size.width < 50 {
            let fontSize = min(layoutAttributes.size.width / 4, layoutAttributes.size.height / 2)
            eventLabel.font = AnywhereCalendarView.mainSDK.font.normal.withSize(fontSize)
        }

        super.apply(layoutAttributes)
    }

    public func configure(_ item: CalendarItem, at indexPath: IndexPath) {
        if let eventTitle = item.title, !eventTitle.isEmpty {
            eventLabel.text = eventTitle
        } else {
            eventLabel.text = "No Title"
        }
        if item.source == .local {
            sourceView.configure(withColor: item.color)
        } else {
            sourceView.configure(withSource: item.source)
        }
        self.dropShadow()
    }
}

// MARK: - Daily calendar cell
public class AnytimeDailyEventCell: UICollectionViewCell, ConfigurableCell {
    private let padding: CGFloat = 16.0
    private var eventLabelTrailingConstraint: NSLayoutConstraint!

    private let eventLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AnywhereCalendarView.mainSDK.font.normal.withSize(18)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .black
        return label
    }()
    private let sourceView = EventSourceView()
    private let sourceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureCell()
    }

    private func configureCell() {
        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.grey100.cgColor
        contentView.clipsToBounds = true
        setupSourceView()
        setupEventLabel()
        setupSourceImageView()
    }

    private func setupSourceView() {
        contentView.addSubview(sourceView)
        NSLayoutConstraint.activate([
            sourceView.widthAnchor.constraint(equalToConstant: 3),
            sourceView.topAnchor.constraint(equalTo: contentView.topAnchor),
            sourceView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sourceView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func setupEventLabel() {
        contentView.addSubview(eventLabel)
        eventLabelTrailingConstraint = eventLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding * 3)
        NSLayoutConstraint.activate([
            eventLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding / 2),
            eventLabel.leadingAnchor.constraint(equalTo: sourceView.trailingAnchor, constant: padding),
            eventLabelTrailingConstraint,
            eventLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding / 2)
        ])
    }

    private func setupSourceImageView() {
        contentView.addSubview(sourceImageView)
        NSLayoutConstraint.activate([
            sourceImageView.heightAnchor.constraint(equalToConstant: padding),
            sourceImageView.widthAnchor.constraint(equalToConstant: padding),
            sourceImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding / 2),
            sourceImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding / 2)
        ])
    }

    override public func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        if layoutAttributes.size.height <= 16 {
            eventLabel.font = AnywhereCalendarView.mainSDK.font.normal.withSize(layoutAttributes.size.height / 2)
        }
        if layoutAttributes.size.width < 50 {
            let fontSize = min(layoutAttributes.size.width / 4, layoutAttributes.size.height / 2)
            eventLabel.font = AnywhereCalendarView.mainSDK.font.normal.withSize(fontSize)
        }
        if layoutAttributes.size.height < 12 {
            contentView.layer.cornerRadius = layoutAttributes.size.height / 2
        } else {
            contentView.layer.cornerRadius = 6
        }
        if layoutAttributes.size.width < UIScreen.main.bounds.width / 2 {
            sourceImageView.isHidden = true
            eventLabelTrailingConstraint.constant = -padding
        }
        super.apply(layoutAttributes)
    }

    private func setSourceImage(withSource source: EventSource) {
        let image: UIImage?
        switch source {
        case .google:
            image = UIImage(named: "google-logo")
        case .microsoft:
            image = UIImage(named: "microsoft-logo")
        case .setmore:
            image = UIImage(named: "setmore-logo")
        case .local:
            image = UIImage()
        }
        sourceImageView.image = image
    }

    public func configure(_ item: CalendarItem, at indexPath: IndexPath) {
        if let eventTitle = item.title, !eventTitle.isEmpty {
            eventLabel.text = eventTitle
        } else {
            eventLabel.text = "No Title"
        }
        if item.source == .local {
            sourceView.configure(withColor: item.color)
        } else {
            sourceView.configure(withSource: item.source)
        }
        setSourceImage(withSource: item.source)
        self.dropShadow()
    }
}

class EventSourceView: UIView {
    private let topBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    private let bottomBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    private let firstView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    private let secondView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()

    private let googleColors: [UIColor] = [
        UIColor(red: 219/255, green: 50/255, blue: 54/255, alpha: 1),
        UIColor(red: 244/255, green: 194/255, blue: 13/255, alpha: 1),
        UIColor(red: 60/255, green: 186/255, blue: 84/255, alpha: 1),
        UIColor(red: 72/255, green: 133/255, blue: 237/255, alpha: 1)
    ]
    private let microsoftColors: [UIColor] = [
        UIColor(red: 79/255, green: 217/255, blue: 255/255, alpha: 1),
        UIColor(red: 39/255, green: 168/255, blue: 234/255, alpha: 1),
        UIColor(red: 0/255, green: 120/255, blue: 212/255, alpha: 1),
        UIColor(red: 19/255, green: 59/255, blue: 109/255, alpha: 1)
    ]
    private let setmoreColors: [UIColor] = [
        UIColor(red: 176/255, green: 216/255, blue: 253/255, alpha: 1),
        UIColor(red: 176/255, green: 216/255, blue: 253/255, alpha: 1),
        UIColor(red: 66/255, green: 133/255, blue: 244/255, alpha: 1),
        UIColor(red: 66/255, green: 133/255, blue: 244/255, alpha: 1)
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        clipsToBounds = true
        setupView()
    }

    private func setupView() {
        addSubview(topBackgroundView)
        NSLayoutConstraint.activate([
            topBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            topBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topBackgroundView.bottomAnchor.constraint(equalTo: centerYAnchor)
        ])
        addSubview(bottomBackgroundView)
        NSLayoutConstraint.activate([
            bottomBackgroundView.topAnchor.constraint(equalTo: centerYAnchor),
            bottomBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        topBackgroundView.addSubview(firstView)
        NSLayoutConstraint.activate([
            firstView.topAnchor.constraint(equalTo: topBackgroundView.topAnchor),
            firstView.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor),
            firstView.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor),
            firstView.bottomAnchor.constraint(equalTo: topBackgroundView.centerYAnchor)
        ])
        bottomBackgroundView.addSubview(secondView)
        NSLayoutConstraint.activate([
            secondView.topAnchor.constraint(equalTo: bottomBackgroundView.centerYAnchor),
            secondView.leadingAnchor.constraint(equalTo: bottomBackgroundView.leadingAnchor),
            secondView.trailingAnchor.constraint(equalTo: bottomBackgroundView.trailingAnchor),
            secondView.bottomAnchor.constraint(equalTo: bottomBackgroundView.bottomAnchor)
        ])
    }

    private func setColors(forSource source: EventSource) {
        let views = [firstView, topBackgroundView, bottomBackgroundView, secondView]
        switch source {
        case .google, .microsoft, .setmore:
            let colors = source == .google ? googleColors : microsoftColors
            guard colors.count == views.count else { return }
            for (index, view) in (views.enumerated()) {
                view.backgroundColor = colors[index]
            }
        case .local:
            return
        }
    }

    public func configure(withSource source: EventSource) {
        setColors(forSource: source)
    }

    public func configure(withColor color: UIColor?) {
        for subview in subviews {
            subview.backgroundColor = .clear
        }
        backgroundColor = color
    }
}

public class AnytimeEventCell: UICollectionViewCell, ConfigurableCell {
    
    let shadowOffset = CGSize(width: -5, height: 2)
    var eventLabel = UILabel()
    var sourceIcon: UIImageView = UIImageView()
    var stackView: UIStackView = UIStackView()
    var sourceIconHeightConstraint: NSLayoutConstraint?
    var sourceIconWidthContraint: NSLayoutConstraint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureCell()
    }
    
    private func configureCell() {
        self.layer.cornerRadius = 10
        eventLabel.font = AnywhereCalendarView.mainSDK.font.normal
        eventLabel.textColor = UIColor.white
        eventLabel.text = "Event"
        sourceIconWidthContraint = sourceIcon.widthAnchor.constraint(equalToConstant: 16)
        sourceIconWidthContraint?.isActive = true
        sourceIconHeightConstraint = sourceIcon.heightAnchor.constraint(equalToConstant: 16)
        sourceIconHeightConstraint?.isActive = true
        sourceIcon.clipsToBounds = true
        stackView.addArrangedSubview(eventLabel)
        stackView.addArrangedSubview(sourceIcon)
        stackView.distribution = .fillProportionally
        stackView.clipsToBounds = true
        self.addSubview(stackView)
        self.dropShadow(withRadius: 5, offset: shadowOffset)
    }
    
    public func configure(_ item: CalendarItem, at indexPath: IndexPath) {
        
        if let eventTitle = item.title, !eventTitle.isEmpty {
            eventLabel.text = eventTitle
        } else {
            eventLabel.text = "No Title"
        }
        sourceIcon.image = nil
        self.backgroundColor = item.color
        eventLabel.textColor = UIColor.white
        self.layer.borderWidth = 0
        self.dropShadow()
    }
    
    override public func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        
        stackView.frame = CGRect(x: 10, y: 5, width: layoutAttributes.size.width - 20, height: 16)
        eventLabel.font = AnywhereCalendarView.mainSDK.font.normal
        sourceIconWidthContraint?.constant = 16
        sourceIconHeightConstraint?.constant = 16
        if layoutAttributes.size.height <= 16 {
            eventLabel.font = AnywhereCalendarView.mainSDK.font.normal.withSize(layoutAttributes.size.height / 2)
            stackView.frame = CGRect(x: 10, y: 4, width: layoutAttributes.size.width - 20, height: layoutAttributes.size.height - 8)
            sourceIconWidthContraint?.constant = layoutAttributes.size.height - 8
        }
        if layoutAttributes.size.width < 50 {
            let fontSize = min(layoutAttributes.size.width / 4, layoutAttributes.size.height / 2)
            eventLabel.font = AnywhereCalendarView.mainSDK.font.normal.withSize(fontSize)
        }
        if layoutAttributes.size.height < 20 {
            self.layer.cornerRadius = layoutAttributes.size.height/2
        } else {
            self.layer.cornerRadius = 10
        }
        if layoutAttributes.size.width < 100 {
            sourceIconWidthContraint?.constant = 0
        }
        
        self.dropShadow(withRadius: 5, offset: shadowOffset)
        super.apply(layoutAttributes)
    }
}

// MARK: Offhours View
class DiagonalLinesView: UIView {
    
    override func draw(_ rect: CGRect) {
        
        let thicknessOfLines: CGFloat = 1     // desired thickness of lines
        let gapBetweenTheLines: CGFloat = 10     // desired gap between lines
        let widthOfView = rect.size.width
        let heightOfView = rect.size.height
        
        guard let currentContext = UIGraphicsGetCurrentContext() else { return }
        currentContext.setStrokeColor(AnywhereCalendarView.mainSDK.theme.offHoursStripeColor.cgColor) // diagnolLineColor.cgColor)
        currentContext.setLineWidth(thicknessOfLines)
        
        var currentPosition = -(widthOfView > heightOfView ? widthOfView : heightOfView) - thicknessOfLines
        while currentPosition <= widthOfView {
            
            currentContext.move( to: CGPoint(x: currentPosition + thicknessOfLines + heightOfView, y: -thicknessOfLines) )
            currentContext.addLine( to: CGPoint(x: currentPosition - thicknessOfLines, y: thicknessOfLines + heightOfView) )
            currentContext.strokePath()
            currentPosition += gapBetweenTheLines + thicknessOfLines + thicknessOfLines
        }
    }
}


// MARK: Current Time Indicator
class CurrentTimeIndicatorLine: UICollectionReusableView {
    let offset = CGSize(width: -2, height: 1)
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = AnywhereCalendarView.mainSDK.theme.currentTimelineColor
        self.dropShadow(offset: offset)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        self.dropShadow(offset: offset)
        super.apply(layoutAttributes)
    }
}

class CurrentTimeIndicatorCircle: UICollectionReusableView {
    let offset = CGSize(width: -2, height: 2)
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = AnywhereCalendarView.mainSDK.theme.currentTimelineColor
        self.layer.cornerRadius = frame.width/2
        self.dropShadow(offset: offset)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        self.dropShadow(offset: offset)
        super.apply(layoutAttributes)
    }
}

class CurrentTimeIndicatorVerticalLine: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = AnywhereCalendarView.mainSDK.theme.currentTimelineColor
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
    }
}

class TimeHeader: UICollectionReusableView {
    
    var timeLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = AnywhereCalendarView.mainSDK.theme.timeHeaderBackgroundColor
        timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width - 5, height: 30))
        timeLabel?.textAlignment = .center
        timeLabel?.font = AnywhereCalendarView.mainSDK.font.normal
        timeLabel?.textColor = AnywhereCalendarView.mainSDK.theme.timeheaderTextColor
        self.addSubview(timeLabel!)
    }
    
    func setTimeText(with hour: Int) {
        guard hour > 0 else {
            return
        }
        let text = DateUtilities.getTimeString(hour)
        let textCount = text.count
        guard textCount >= 4 else {
            timeLabel?.text = text
            return
        }
        let resultText = NSMutableAttributedString.init(string: text)
        resultText.setAttributes([
            .font: AnywhereCalendarView.mainSDK.font.normal.withSize(10)
        ],
        range: NSMakeRange(textCount == 4 ? 2 : 3, 2))
        timeLabel?.attributedText = resultText
    }
    
    func setCurrentTimeText() {
        let attributedTimeText = NSAttributedString(string: getCurrentTimeString(), attributes: [.font: AnywhereCalendarView.mainSDK.font.normal, .strokeColor: UIColor.blue, .foregroundColor: UIColor.blue, .backgroundColor: UIColor.white])
        timeLabel?.attributedText = attributedTimeText
    }
    
    private func getCurrentTimeString() -> String {
        let today = Date()
        
        guard today.minute != 0 else {
            return ""
        }
        guard AnywhereCalendarView.mainSDK.calConfig.timeFormat.is12HourFormat else {
            return "\(today.hour):\(today.minute)"
        }
        
        if today.hour > 12 {
            return "\(today.hour-12):\(today.minute)PM"
        } else if today.hour < 12 {
            return "\(today.hour):\(today.minute)AM"
        } else {
            return "\(today.hour):\(today.minute)PM"
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class TimeHeaderTriangleView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let heightWidth: CGFloat = 16
        let triangleView = UIView(
            frame: CGRect(
                x: frame.width - heightWidth,
                y: ((frame.height / 2) - (frame.height - heightWidth) / 2) - 0.5,
                width: heightWidth,
                height: heightWidth
            )
        )
        addSubview(triangleView)
        backgroundColor = .clear

        let shape = CAShapeLayer()
        shape.path = roundedTriangle(widthHeight: heightWidth)
        shape.fillColor = AnywhereCalendarView.mainSDK.theme.currentTimelineColor.cgColor
        triangleView.layer.insertSublayer(shape, at: 0)
    }

    private func roundedTriangle(widthHeight: CGFloat) -> CGPath {
       let point1 = CGPoint(x: widthHeight, y: widthHeight/2)
       let point2 = CGPoint(x: widthHeight / 2, y: widthHeight)
       let point3 = CGPoint(x: widthHeight / 2, y: 0)

       let path = CGMutablePath()

       path.move(to: CGPoint(x: widthHeight / 2, y: 0))
       path.addArc(tangent1End: point1, tangent2End: point2, radius: 1)
       path.addArc(tangent1End: point2, tangent2End: point3, radius: 1)
       path.addArc(tangent1End: point3, tangent2End: point1, radius: 1)
       path.closeSubpath()
       return path
    }
}
