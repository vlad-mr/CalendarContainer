//
//  AllDayEvent.swift
//  AnywhereCalendarSDK
//
//  Created by Deepika on 07/08/20.
//

import UIKit

class DayOffView: UIView, ConfigurableAllDayEventView {
    var item: CalendarItem?
    lazy var label = UILabel()
    weak var actionDelegate: CalendarActionDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView() {
        addSubview(label)
        backgroundColor = UIColor(red: 52 / 255, green: 216 / 255, blue: 235 / 255, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AnywhereCalendarView.mainSDK.font.subHeader.withSize(10)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.widthAnchor.constraint(equalTo: widthAnchor),
            label.heightAnchor.constraint(equalTo: heightAnchor),
        ])
    }

    func configure(withEvent item: CalendarItem) {
        self.item = item
        label.text = item.title
        if let color = item.color {
            backgroundColor = color
        }
    }

    func configure(withTitle title: String) {
        label.text = title
    }
}
