//
//  WeekControl.swift
//  Anytime
//
//  Created by Artem Grebinik on 17.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

// MARK: - WeekControl

class WeekControl: UIView {
    var onSelectAction: (([Int]) -> Void)?

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 5
        return stack
    }()

    private var cells: [WeekDayCell] = []
    private(set) var selectedCells: [Int] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.fillSuperview()
        stackView.addArrangedSubviews(generateSubviews())
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cells.forEach { $0.layer.cornerRadius = $0.frame.width / 2 }
    }

    private func generateSubviews() -> [UIView] {
        var views: [UIView] = []
        let titles = ["M", "T", "W", "T", "F", "S", "S"]
        for i in 0 ... 6 {
            let weekDayContainerView = UIView()
            let cell = WeekDayCell()
            cell.setTitle(titles[i])
            cell.translatesAutoresizingMaskIntoConstraints = false
            weekDayContainerView.addSubview(cell)

            NSLayoutConstraint.activate([
                cell.widthAnchor.constraint(equalTo: weekDayContainerView.widthAnchor),
                cell.heightAnchor.constraint(equalTo: cell.widthAnchor),
                cell.centerXAnchor.constraint(equalTo: weekDayContainerView.centerXAnchor),
                cell.centerYAnchor.constraint(equalTo: weekDayContainerView.centerYAnchor),
            ])

            cell.layer.cornerRadius = cell.frame.width / 2
            cells.append(cell)

            weekDayContainerView.tag = i
            cell.tag = i

            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
            views.append(weekDayContainerView)
        }
        return views
    }

    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? WeekDayCell else { return }

        let cellModeArray = cells
            .filter { $0.mode == .selected }
            .map { $0.mode }

        if cellModeArray.count == 1, cell.mode == .selected {
            return
        }
        cell.toggleMode()

        let selectedCellTags = cells
            .filter { $0.mode == .selected }
            .map { $0.tag }
        selectedCells = selectedCellTags

        onSelectAction?(selectedCellTags)
    }

    private func clearCells() {
        cells.forEach { $0.configureBy(mode: .unselected) }
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
