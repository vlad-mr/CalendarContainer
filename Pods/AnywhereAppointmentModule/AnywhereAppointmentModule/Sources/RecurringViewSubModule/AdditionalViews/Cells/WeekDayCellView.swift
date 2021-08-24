//
//  WeekDayCellView.swift
//  Anytime
//
//  Created by Artem Grebinik on 17.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

// MARK: - WeekDayCell

enum WeekDayCellMode {
    case unselected, selected
}

class WeekDayCell: UIView {
    private(set) var mode: WeekDayCellMode = .unselected

    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.font = AppDecor.Fonts.medium
        label.textColor = .lightGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    private func setUp() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.fillSuperview()
        configureBy(mode: .unselected)
    }
        
    let color = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1) // change to system anytime color
    
    func toggleMode() {
        self.mode = mode == .selected ? .unselected : .selected
        
        self.backgroundColor = mode == .selected ? AppDecor.MainColors.anytimeLightBlue : color
        self.label.textColor = mode == .selected ? AppDecor.MainColors.anytimeWhite : .black
    }
    
    func configureBy(mode: WeekDayCellMode) {
        self.mode = mode
        
        self.backgroundColor = mode == .selected ? AppDecor.MainColors.anytimeLightBlue : color
        self.label.textColor = mode == .selected ? AppDecor.MainColors.anytimeWhite : .black
    }
    
    func setTitle(_ title: String) {
        label.text = title
    }
}
