//
//  ScheduleEventCellTableViewCell.swift
//  Anytime
//
//  Created by Vignesh on 19/12/19.
//  Copyright © 2019 FullCreative Pvt Ltd. All rights reserved.
//

import SwiftDate
import UIKit

class ScheduleEventCellOld: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var eventTypeLabel: UILabel!
    @IBOutlet var sourceIcon: UIImageView!
    @IBOutlet var timeAndLocationLabel: UILabel!
    @IBOutlet var eventCell: UIView!

    @IBInspectable var eventColor: UIColor = .systemBlue

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = AnywhereCalendarView.mainSDK.theme.backgroundColor
        titleLabel.font = AnywhereCalendarView.mainSDK.font.header
        eventTypeLabel.font = AnywhereCalendarView.mainSDK.font.subHeader
        timeAndLocationLabel.font = AnywhereCalendarView.mainSDK.font.subHeader

        titleLabel.textColor = UIColor.white
        eventTypeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        timeAndLocationLabel.textColor = UIColor.white.withAlphaComponent(0.7)
    }
}

extension ScheduleEventCellOld: ConfigurableCell {
    func configure(_ item: CalendarItem, at _: IndexPath) {
        let title = item.title ?? ""
        titleLabel.text = title.isEmpty ? "No Title" : title
        eventTypeLabel.text = ""
        let startTime = item.startDate.timeString()
        let endTime = item.endDate.timeString()
        timeAndLocationLabel.text = "\(startTime) - \(endTime)"
        eventCell.backgroundColor = item.color
        eventCell.layer.borderWidth = 1
        eventCell.layer.borderColor = item.color?.cgColor
        titleLabel.textColor = .white
        eventTypeLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        timeAndLocationLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        eventCell.dropShadow(offset: CGSize(width: 0, height: 1))
    }
}

extension ScheduleEventCellOld: CalendarCellNib {
    static func getNib() -> UINib? {
        #if SWIFT_PACKAGE
            return UINib(nibName: nibName, bundle: .module)
        #else
            return UINib(nibName: nibName, bundle: Bundle(for: self))
        #endif
    }
}

func timeStringFromMins(_ minutes: Int) -> String {
    let hourTxt = String(format: "%d", minutes / 60)
    let minsTxt = String(format: "%02d", minutes % 60)
    return "\(hourTxt):\(minsTxt)"
}

func calendarWeekDay(day: Int) -> String {
    switch day - 1 {
    case 0:
        return "SUN"
    case 1:
        return "MON"
    case 2:
        return "TUE"
    case 3:
        return "WED"
    case 4:
        return "THU"
    case 5:
        return "FRI"
    case 6:
        return "SAT"
    default:
        return ""
    }
}

public class ScheduleEventCell: UITableViewCell {
    private let padding: CGFloat = 16.0

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()

    private let sourceView = EventSourceView()
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .white
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .equalSpacing
        return stack
    }()

    private let eventLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AnywhereCalendarView.mainSDK.font.normal.withSize(18)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AnywhereCalendarView.mainSDK.font.normal
        label.textColor = .gray
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AnywhereCalendarView.mainSDK.font.normal
        label.textColor = .lightGray
        return label
    }()

    private let sourceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureCell()
    }

    private func configureCell() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupContainerView()
        setupSourceView()
        setupStackView()
        setupSourceImageView()
    }

    private func setupContainerView() {
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding / 2),
        ])
    }

    private func setupSourceView() {
        containerView.addSubview(sourceView)
        NSLayoutConstraint.activate([
            sourceView.widthAnchor.constraint(equalToConstant: 3),
            sourceView.topAnchor.constraint(equalTo: containerView.topAnchor),
            sourceView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            sourceView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }

    private func setupStackView() {
        containerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding / 2),
            stackView.leadingAnchor.constraint(equalTo: sourceView.trailingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding * 1.5),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding / 2),
        ])
        stackView.addArrangedSubview(eventLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(timeLabel)
    }

    private func setupSourceImageView() {
        containerView.addSubview(sourceImageView)
        NSLayoutConstraint.activate([
            sourceImageView.heightAnchor.constraint(equalToConstant: padding),
            sourceImageView.widthAnchor.constraint(equalToConstant: padding),
            sourceImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding / 2),
            sourceImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding / 2),
        ])
    }

    private func setSourceImage(source: EventSource) {
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
}

extension ScheduleEventCell: ConfigurableCell {
    public func configure(_ item: CalendarItem, at _: IndexPath) {
        let title = item.title ?? ""
        eventLabel.text = title.isEmpty ? "No Title" : title
        descriptionLabel.text = "Google Calendar Event"
        let startTime = item.startDate.timeString()
        let endTime = item.endDate.timeString()
        timeLabel.text = "\(startTime) - \(endTime)"
        setSourceImage(source: item.source)
        if item.source == .local {
            sourceView.configure(withColor: item.color)
        } else {
            sourceView.configure(withSource: item.source)
        }
    }
}
