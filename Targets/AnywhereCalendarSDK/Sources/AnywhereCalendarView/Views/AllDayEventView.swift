//
//  TappableAllDayEventView.swift
//  AnywhereCalendarSDK
//
//  Created by Deepika on 17/08/20.
//

import UIKit

class AllDayEventView: TappableAllDayEventView {
    var item: CalendarItem?
    weak var actionDelegate: CalendarActionDelegate?

    lazy var label = UILabel()

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
        layer.cornerRadius = 5
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
        if let eventTitle = item.title, !eventTitle.isEmpty {
            label.text = eventTitle
        } else {
            label.text = "No Title"
        }
        if let color = item.color {
            backgroundColor = color
        }
    }

    func configure(withTitle title: String) {
        label.text = title
    }
}
