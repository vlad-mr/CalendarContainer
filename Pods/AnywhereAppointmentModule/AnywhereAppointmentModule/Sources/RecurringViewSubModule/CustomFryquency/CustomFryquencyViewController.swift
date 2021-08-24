//
//  CustomFryquencyViewController.swift
//  Anytime
//
//  Created by Artem Grebinik on 11.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit
import EventKit
import SwiftDate

protocol CustomFryquencyVCProtocol: class {
    func toggleCell(for mode: RecurrenceFrequency)
    func updateIntervalPicker()
    func updateWeekControl(with: [Int])
    func updateMonthControl(with: [Int])
    func updateYearControl(with: [Int])
    func updateRepeatCell(with description: String)
    func updateEndReccurrenceCell(with description: String)
    func routeToTheEndFrequency()
}

public class CustomFryquencyViewController: UITableViewController {
    public weak var delegate: FrequencyVCDelegate?
    public var router: FrequencyRouter?
    private lazy var viewModel = CustomFryquencyViewModel(view: self)
    
    lazy private var isWeekCellAcctive: Bool = false
    lazy private var isMonthCellAcctive: Bool = false
    lazy private var isYearCellAcctive: Bool = false
    
    public lazy var originalRule = RecurrenceRule(frequency: .daily) {
        didSet {
            //We need to handle event date for controlls if we use creat flow
            if let weekday = EKWeekday(rawValue: Date().weekday) {
                viewModel.view.updateWeekControl(with: [weekday.toNumberSymbol()])
            }
            viewModel.view.updateMonthControl(with: [Date().day])
            
            if let month = EKReccurrenceMonth(rawValue: Date().month) {
                viewModel.view.updateYearControl(with: [month.rawValue])
            }
            
            viewModel.view.updateIntervalPicker()
            
            switch originalRule.frequency {
            case .weekly:
                let weekdaysArray = originalRule.byweekday.map({ $0.toNumberSymbol() })
                viewModel.view.updateWeekControl(with: weekdaysArray)
            case .monthly:
                let days = originalRule.bymonthday
                viewModel.view.updateMonthControl(with: days)
            case .yearly:
                let months = originalRule.bymonth
                viewModel.view.updateYearControl(with: months)
            default:
                break
            }
        }
    }
    
    // MARK: - Life cycle
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shouldShowNavBar = true
        setNavBar()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        viewModel.editedRule = originalRule
        viewModel.viewDidLoad()
    }
    
    // MARK: - Set up functions
    func setupTableView() {
        tableView.separatorStyle = .none
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = .white
        }
    }
    
    private func setNavBar() {
        setupNavBar(title: "Custom")
        addNavBarButton(title: "Done")
    }
    
    // MARK: - Handle Actions
    private func didTapDoneButton() {
        delegate?.didUpdateFrequency(.custom(viewModel.editedRule))
        router?.route(to: .backToRoot, from: self, info: nil)
    }
    
    // MARK: - Pickers
    lazy private var weekControl: WeekControl = configure(AnytimeNibs.weekControl) {
        $0.onSelectAction = { [weak self] tags in
            let weekdays = tags.compactMap({ EKWeekday.weekdayFromSymbol(String($0)) })
            self?.viewModel.editedRule.byweekday = weekdays
        }
    }
    
    lazy private var monthlyControl = configure(AnytimeNibs.monthlyControl) {
        $0.onSelectAction = { [weak self] tags in
            self?.viewModel.editedRule.bymonthday = tags
        }
    }
    
    lazy private var yearlyControl = configure(AnytimeNibs.yearControl) {
        $0.onSelectAction = { [weak self] tags in
            self?.viewModel.editedRule.bymonth = tags
        }
    }
    
    lazy private var intervalPicker: UIPickerView = configure(UIPickerView()) {
        $0.dataSource = self
        $0.delegate = self
    }
    
    // MARK: - Table view cells
    lazy private var repeatEveryCell = configure(AnytimeNibs.titleSubtitleIndicatorCell) {
        $0.configureCell(withTitle: "Repeat Every",
                         icon: AppDecor.Icons.startTime,
                         shouldShowSeparator: false)
    }
    
    lazy private var repeatEveryWeekCell = configure(AnytimeNibs.customRepeatCell) {
        $0.configure(with: "On", shouldShowSeparator: true)
        let weekControl = self.weekControl
        weekControl.translatesAutoresizingMaskIntoConstraints = false
        $0.containerView.addSubview(weekControl)
        weekControl.fillSuperview()
    }
    
    lazy private var repeatEveryMonthCell = configure(AnytimeNibs.customRepeatCell) {
        $0.configure(with: "Each", shouldShowSeparator: true)
        let monthlyControl = self.monthlyControl
        monthlyControl.translatesAutoresizingMaskIntoConstraints = false
        $0.containerView.addSubview(monthlyControl)
        monthlyControl.fillSuperview()
    }
    
    lazy private var repeatEveryYearCell = configure(AnytimeNibs.customRepeatCell) {
        $0.configure(with: "Repeat Every Year")
        let yearlyControl = self.yearlyControl
        yearlyControl.translatesAutoresizingMaskIntoConstraints = false
        $0.containerView.addSubview(yearlyControl)
        yearlyControl.fillSuperview()
    }
    
    lazy private var pickerCell = configure(UITableViewCell()) {
        let picker = self.intervalPicker
        picker.translatesAutoresizingMaskIntoConstraints = false
        $0.contentView.addSubview(picker)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                picker.leadingAnchor.constraint(
                    equalTo: $0.contentView.safeAreaLayoutGuide.leadingAnchor),
                picker.trailingAnchor.constraint(
                    equalTo: $0.contentView.safeAreaLayoutGuide.trailingAnchor),
                picker.bottomAnchor.constraint(
                    equalTo: $0.contentView.safeAreaLayoutGuide.bottomAnchor)
            ])
        } else {
            // Fallback on earlier versions
        }
        $0.separatorInset.right = .greatestFiniteMagnitude
    }
    
    lazy private var endCell = configure(AnytimeNibs.titleSubtitleIndicatorCell) {
        $0.configureCell(withTitle: "End Date",
                         icon: AppDecor.Icons.endTime,
                         indicatorIcon: AppDecor.Icons.grayRightArrow,
                         shouldShowSeparator: false)
        $0.selectionStyle = .none
    }
}

// MARK: - Table view data source
public extension CustomFryquencyViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellModels = viewModel.cellForRowAt(indexPath: indexPath)
        
        switch cellModels {
        case .repeatCell: return repeatEveryCell
        case .repeatPickerCell: return pickerCell
        case .onWeekRepeatCell: return repeatEveryWeekCell
        case .onMonthRepeatCell: return repeatEveryMonthCell
        case .onYearRepeatCell: return repeatEveryYearCell
        case .endRepeatCell: return endCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellModels = viewModel.cellForRowAt(indexPath: indexPath)
        
        switch cellModels {
        case .repeatCell,
             .repeatPickerCell,
             .onWeekRepeatCell,
             .onMonthRepeatCell,
             .onYearRepeatCell:
            break
        case .endRepeatCell:
            viewModel.view.routeToTheEndFrequency()
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellModels = viewModel.cellForRowAt(indexPath: indexPath)
        
        switch cellModels {
        case .repeatPickerCell: return 180
        case .onWeekRepeatCell: return isWeekCellAcctive ? 120 : 0
        case .onMonthRepeatCell: return isMonthCellAcctive ? 320 : 0
        case .onYearRepeatCell: return isYearCellAcctive ? 190 : 0
        default: return 60
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
}

// MARK: - UIPickerViewDataSource/UIPickerViewDelegate

extension CustomFryquencyViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView,
                           numberOfRowsInComponent component: Int) -> Int {
        return viewModel.numberOfRowsInComponent(component)
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return viewModel.numberOfComponents()
    }
    
    public func pickerView(_ pickerView: UIPickerView,
                           titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.titleForRow(row, forComponent: component)
    }
    
    public func pickerView(_ pickerView: UIPickerView,
                           widthForComponent component: Int) -> CGFloat {
        return  pickerView.frame.width / 4
    }
    
    public func pickerView(_ pickerView: UIPickerView,
                           didSelectRow row: Int, inComponent component: Int) {
        viewModel.didSelectRow(row, inComponent: component)
    }
}

// MARK: - NavigationBarButtonDelegate

extension CustomFryquencyViewController: NavBarActionDelegate {
    func didTapNavBarButton() {
        didTapDoneButton()
    }
}

// MARK: - CustomFryquencyVCProtocol

extension CustomFryquencyViewController: CustomFryquencyVCProtocol {
    
    func toggleCell(for mode: RecurrenceFrequency) {
        
        switch mode {
        case .daily:
            isWeekCellAcctive = false
            isMonthCellAcctive = false
            isYearCellAcctive = false
        case .weekly:
            let weekdays = weekControl.selectedCells
                .compactMap({ EKWeekday.weekdayFromSymbol(String($0)) })
            self.viewModel.editedRule.byweekday = weekdays
            isWeekCellAcctive = true
            isMonthCellAcctive = false
            isYearCellAcctive = false
        case .monthly:
            let days = yearlyControl.selectedCells
            self.viewModel.editedRule.bymonthday = days
            isWeekCellAcctive = false
            isMonthCellAcctive = true
            isYearCellAcctive = false
        case .yearly:
            let months = yearlyControl.selectedCells
            self.viewModel.editedRule.bymonth = months
            isWeekCellAcctive = false
            isMonthCellAcctive = false
            isYearCellAcctive = true
        case .minutely, .secondly, .hourly:
            break
        }
        
        tableView.beginUpdates()
        tableView.reloadData()
        tableView.endUpdates()
    }
    
    func updateRepeatCell(with description: String) {
        repeatEveryCell.setDescription(description)
    }
    
    func updateEndReccurrenceCell(with description: String) {
        endCell.setDescription(description)
    }
    
    func routeToTheEndFrequency() {
        router?.route(to: .endFrequency, from: self, info: viewModel.editedRule)
    }
    
    func updateWeekControl(with weekdays: [Int]) {
        weekControl.configure(with: weekdays)
    }
    func updateMonthControl(with daysOfMonth: [Int]) {
        monthlyControl.configure(with: daysOfMonth)
    }
    func updateYearControl(with months: [Int]) {
        yearlyControl.configure(with: months)
    }
    
    func updateIntervalPicker() {
        let fComponentIndex = viewModel.pickerData[0].firstIndex(where: {
            $0 == String(originalRule.interval)
        })
        let sComponentIndex = viewModel.pickerData[1].firstIndex(where: {
            $0 == String(originalRule.frequency.toPickerTitleStyleString())
        })
        
        self.intervalPicker.selectRow(fComponentIndex ?? 0, inComponent: 0, animated: true)
        self.intervalPicker.selectRow(sComponentIndex ?? 0, inComponent: 1, animated: true)
        pickerView(intervalPicker, didSelectRow: sComponentIndex ?? 0, inComponent: 1)
        pickerCell.layoutIfNeeded()
    }
}
