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
    
    lazy var label: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        self.addSubview(label)
        self.backgroundColor = UIColor(red: 52/255, green: 216/255, blue: 235/255, alpha: 1)
        self.layer.cornerRadius = 5
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AnywhereCalendarView.mainSDK.font.subHeader.withSize(10)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.widthAnchor.constraint(equalTo: self.widthAnchor),
            label.heightAnchor.constraint(equalTo: self.heightAnchor)
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
            self.backgroundColor = color
        }
    }
    
    func configure(withTitle title: String) {
        label.text = title
    }
}
