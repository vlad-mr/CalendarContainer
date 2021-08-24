//
//  YearControl.swift
//  Anytime
//
//  Created by Artem Grebinik on 25.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

class YearlyControl: UIView, NibLoadable {
    var onSelectAction: (([Int]) -> Void)?
   
    @IBOutlet private var buttons: [UIView]!
    private let titles = EKReccurrenceMonth.wholeYear.map { $0.toSymbol() }
    
    private(set) var selectedCells: [Int] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    private var cells: [WeekDayCell] = []
    private func setUp() {
        buttons.forEach { (container) in
            let cell = WeekDayCell()
            cell.tag = container.tag
            cell.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(cell)
            cell.fillSuperview()
            cells.append(cell)
        }
        cells.forEach { (cell) in
            cell.setTitle(String(titles[cell.tag - 1]))
            cell.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
            )
        }
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        buttons.forEach({ $0.layer.cornerRadius = $0.frame.height / 2 })
        cells.forEach({ $0.layer.cornerRadius = $0.frame.height / 2 })
    }
    
    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? WeekDayCell else { return }
        
        let cellModeArray = cells
            .filter({ $0.mode == .selected })
            .map { $0.mode }
        
        if cellModeArray.count == 1, cell.mode == .selected {
            return
        }
        cell.toggleMode()
        
        let selectedCellTags = cells
            .filter { $0.mode == .selected }
            .map { $0.tag }
        self.selectedCells = selectedCellTags
        
        onSelectAction?(selectedCellTags)
    }
    
    private func clearCells() {
        cells.forEach({ $0.configureBy(mode: .unselected) })
        selectedCells = []
    }
    
    // MARK: - Public functions
    func configure(with weekdays: [Int]) {
        clearCells()
        for cell in cells {
            for weekDay in weekdays where weekDay == cell.tag {
                cell.configureBy(mode: .selected)
                selectedCells.append(weekDay)
            }
        }
    }
}
