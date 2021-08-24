//
//  NonStickyDateHeaderView.swift
//  AnywhereCalendarView
//
//  Created by Deepika on 04/07/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol HeaderProtocol: class {
    func didTapAddButton(at section: Int)
}

class NonStickyDateHeaderView: UITableViewHeaderFooterView {
    var section: Int = 0
    weak var actionDelegate: CalendarActionDelegate?

    lazy var addNewButton: CalendarHeaderButton = {
        let addNewBtn = CalendarHeaderButton(withFrame: CGRect(x: 0, y: 0, width: 40, height: self.bounds.height), actionIdentifier:
            "AddNewCalendarItem")
        addNewBtn.setTitle("Add", for: .normal)
        let image = UIImage(named: "AddItem")
        addNewBtn.setImage(image, for: .normal)
        addNewBtn.setTitleColor(UIColor.black, for: .normal)
        addNewBtn.translatesAutoresizingMaskIntoConstraints = false
        return addNewBtn
    }()

    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: 60, height: self.bounds.height))
        label.backgroundColor = UIColor.clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NonStickyDateHeaderView: ConfigurableView {
    func configure(_ date: Date, at section: Int) {
        self.section = section

        backgroundView?.backgroundColor = UIColor(red: 242 / 255.0, green: 246 / 255.0, blue: 246 / 255.0, alpha: 1)
        clipsToBounds = true

        let titleString = date.toFormat("E MMM d")
        if date.isToday {
            titleLabel.text = "Today, \(titleString)"
        } else if date.isYesterday {
            titleLabel.text = "Yesterday, \(titleString)"
        } else if date.isTomorrow {
            titleLabel.text = "Tomorrow, \(titleString)"
        } else {
            titleLabel.text = titleString
        }
        titleLabel.textColor = titleString.contains("Today") ? AnywhereCalendarView.mainSDK.theme.currentDateText : AnywhereCalendarView.mainSDK.theme.defaultDateText
        addSubview(titleLabel)
        addSubview(addNewButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 200),
            titleLabel.heightAnchor.constraint(equalTo: heightAnchor),
            addNewButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20),
            addNewButton.widthAnchor.constraint(equalToConstant: 100),
            addNewButton.heightAnchor.constraint(equalTo: heightAnchor),
        ])
    }
}
