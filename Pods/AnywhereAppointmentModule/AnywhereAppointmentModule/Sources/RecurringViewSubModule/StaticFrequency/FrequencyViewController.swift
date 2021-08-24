//
//  FrequenceViewController.swift
//  Anytime
//
//  Created by Artem Grebinik on 27.04.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

public protocol FrequencyVCDelegate: class {
    func didUpdateFrequency(_ frequency: Frequency)
}

public class FrequencyViewController: UIViewController {
    // MARK: Properties
    public var router: FrequencyRouter?
    public weak var delegate: FrequencyVCDelegate?
    public var originalFrequencyMode: Frequency = .doNotRepeat
    public var startEventDate: Date?
    
    // MARK: Private
    private var currentFrequencyMode: Frequency = .doNotRepeat {
        didSet {
            markSelectedCell()
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.reloadData()
            })
        }
    }

    private let models: [FrequencyHeaderModel] = [.customFrequencyCells, .staticFrequencyCells, .anotherCells]
    private let tableView = UITableView()
    
    // MARK: CELLS

    lazy private var doNotRepeatCell: FrequencySelectionCell = configure(AnytimeNibs.frequencySelectionCell) {
        $0.configureCell(
            withTitle: Frequency.cellDynamicTitle(for: .doNotRepeat, startEventDate),
            shouldShowSeparator: true)
    }
    
    lazy private var dailyRepeatCell: FrequencySelectionCell = configure(AnytimeNibs.frequencySelectionCell) {
        $0.configureCell(
            withTitle: Frequency.cellDynamicTitle(for: .daily(), startEventDate),
            shouldShowSeparator: true)
    }
    
    lazy private var weeklyRepeatCell: FrequencySelectionCell = configure(AnytimeNibs.frequencySelectionCell) {
        $0.configureCell(
            withTitle: Frequency.cellDynamicTitle(for: .weekly(), startEventDate),
            shouldShowSeparator: true)
    }
    
    lazy private var monthlyRepeatCell: FrequencySelectionCell = configure(AnytimeNibs.frequencySelectionCell) {
        $0.configureCell(
            withTitle: Frequency.cellDynamicTitle(for: .monthly(), startEventDate),
            shouldShowSeparator: true)
    }
    
    lazy private var yearlyRepeatCell: FrequencySelectionCell = configure(AnytimeNibs.frequencySelectionCell) {
        $0.configureCell(
            withTitle: Frequency.cellDynamicTitle(for: .yearly(), startEventDate),
            shouldShowSeparator: true)
    }
    
    lazy private var customRepeatCell: FrequencySelectionCell = configure(AnytimeNibs.frequencySelectionCell) {
        $0.configureCell(
            withTitle: Frequency.cellDynamicTitle(for: .custom(originalFrequencyMode.getRecurrenceRule()), startEventDate),
            shouldShowSeparator: true)
    }

    lazy var createCustomFrequencyCell = configure(AnytimeNibs.iconIndicatorTableViewCell) {
        $0.configure(
            withLabelTitle: "Custom",
            icon: AppDecor.Icons.textFieldIcon,
            color: .lightGray,
            indicatorImage: AppDecor.Icons.grayRightArrow,
            shouldShowSeparator: false)
    }
    
    private var editedFrequencyMode: Frequency = .doNotRepeat {
        didSet {
            switch editedFrequencyMode {
            case .custom(let reccurrenceRule):
                guard let reccurrence = reccurrenceRule else { return }
                customRepeatCell.configureCell(withTitle: reccurrence.getTitle(),
                                               shouldShowSeparator: true)
            default: break
            }
            self.currentFrequencyMode = editedFrequencyMode
            updateDoneButton(shouldSave: self.originalFrequencyMode != self.editedFrequencyMode)
        }
    }
    
    // MARK: Life cycle
    
    public override func loadView() {
        super.loadView()
        view = tableView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        markSelectedCell()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shouldShowNavBar = true
        setNavBar()
        editedFrequencyMode = originalFrequencyMode
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shouldShowNavBar = false
    }
    
    // MARK: Set Up views
    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }
    
    private func setNavBar() {
        setupNavBar(title: "Repeat")
        addNavBarButton(title: "Done")
    }
    
    // MARK: Handle actions
    private func markSelectedCell() {

        doNotRepeatCell.isDurationSelected = currentFrequencyMode == .doNotRepeat
        dailyRepeatCell.isDurationSelected = currentFrequencyMode == .daily()
        weeklyRepeatCell.isDurationSelected = currentFrequencyMode == .weekly()
        monthlyRepeatCell.isDurationSelected = currentFrequencyMode == .monthly()
        yearlyRepeatCell.isDurationSelected = currentFrequencyMode == .yearly()
        customRepeatCell.isDurationSelected = currentFrequencyMode == .custom()
    }
    
    func updateDoneButton(shouldSave: Bool) {
        setNavBarButtonEnabled(shouldSave)
    }
    
    func didTapDoneButton() {
        delegate?.didUpdateFrequency(currentFrequencyMode)
        router?.route(to: .back, from: self, info: nil)
    }
}

extension FrequencyViewController: NavBarActionDelegate {
    func didTapNavBarButton() {
        didTapDoneButton()
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension FrequencyViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].cellModels.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModels = models[indexPath.section].cellModels[indexPath.row]
        
        switch cellModels {
        case .doNotRepeat: return doNotRepeatCell
        case .daily: return dailyRepeatCell
        case .weekly: return weeklyRepeatCell
        case .monthly: return monthlyRepeatCell
        case .yearly: return yearlyRepeatCell
        case .customRepeat: return customRepeatCell
        case .customFrequencyEdit: return createCustomFrequencyCell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellModels = models[indexPath.section].cellModels[indexPath.row]
        
        switch cellModels {
        case .doNotRepeat:
            editedFrequencyMode = .doNotRepeat
        case .daily:
            editedFrequencyMode = .daily(.init(frequency: .daily))
        case .weekly:
            editedFrequencyMode = .weekly(.init(frequency: .weekly))
        case .monthly:
            editedFrequencyMode = .monthly(.init(frequency: .monthly))
        case .yearly:
            editedFrequencyMode = .yearly(.init(frequency: .yearly))
        case .customRepeat:
            let rrule = originalFrequencyMode.getStaticRule(startEventDate) ?? ""
            editedFrequencyMode = .custom(RecurrenceRule(rruleString: rrule))
        case .customFrequencyEdit:
            let recurrence = originalFrequencyMode.getRecurrenceRule() ?? .init(frequency: .daily)
            let info = currentFrequencyMode == .custom() ? recurrence : nil
            router?.route(to: .customFrequency, from: self, info: info)
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellModels = models[indexPath.section].cellModels[indexPath.row]
        
        switch cellModels {
        case .customRepeat:
            return originalFrequencyMode == .custom() ? 66 : 0

        case .daily, .weekly, .monthly, .yearly, .doNotRepeat, .customFrequencyEdit:
            return 66
        }
    }
}
