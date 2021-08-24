//
//  EndReccurringViewController.swift
//  Anytime
//
//  Created by Artem Grebinik on 11.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import EventKit
import UIKit

// MARK: - EndReccurringViewController

protocol EndReccurringVCProtocol: class {}

extension EndReccurringViewController: EndReccurringVCProtocol {}

class EndReccurringViewController: UITableViewController {
    weak var delegate: FrequencyVCDelegate?
    var router: FrequencyRouter?
    private lazy var viewModel = EndReccurringViewModel(view: self)

    private lazy var currentFrequencyMode: EndReccurringMode = .never {
        didSet {
            switch currentFrequencyMode {
            case let .date(date):
                if let value = date {
                    onDateCell.setTitle(value.dateString())
                    editedRule.recurrenceEnd = EKRecurrenceEnd(end: value)
                }
            case let .occurence(count):
                if let value = count {
                    editedRule.recurrenceEnd = EKRecurrenceEnd(occurrenceCount: value)
                }
            case .never:
                editedRule.recurrenceEnd = nil
            }
        }
    }

    private lazy var originalFrequencyMode: EndReccurringMode = .never
    private lazy var editedFrequencyMode: EndReccurringMode = .never {
        didSet {
            currentFrequencyMode = editedFrequencyMode
        }
    }

    private lazy var currentRule: RecurrenceRule = .init(frequency: .daily)
    lazy var originalRule: RecurrenceRule = .init(frequency: .daily) {
        didSet {
            if let date = originalRule.recurrenceEnd?.endDate {
                originalFrequencyMode = .date(date: date)
                datePicker.setDate(date, animated: true)
                onDateCell.setTitle(date.dateString())

            } else if let occurrenceCount = originalRule.recurrenceEnd?.occurrenceCount {
                guard occurrenceCount != 0 else {
                    originalFrequencyMode = .never
                    return
                }

                originalFrequencyMode = .occurence(count: occurrenceCount)
                let index = viewModel.pickerData.firstIndex(where: { $0 == String(occurrenceCount) }) ?? 0
                occorrencePicker.selectRow(index, inComponent: 0, animated: true)
            } else {
                originalFrequencyMode = .never
            }
        }
    }

    private lazy var editedRule: RecurrenceRule = .init(frequency: .daily) {
        didSet {
            self.currentRule = editedRule
        }
    }

    // MARK: - Life cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shouldShowNavBar = true
        setNavBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        viewModel.viewDidLoad()

        editedFrequencyMode = originalFrequencyMode
        editedRule = originalRule
        markSelectedCell()
    }

    // MARK: - Set up functions

    private func setupTableView() {
        tableView.separatorStyle = .none
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = .white
        }
    }

    private func setNavBar() {
        setupNavBar(title: "End Date")
        addNavBarButton(title: "Done")
    }

    // MARK: - Pickers

    private lazy var datePicker: UIDatePicker = configure(UIDatePicker()) {
        $0.minimumDate = Date()
        $0.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        if #available(iOS 13.4, *) {
            $0.preferredDatePickerStyle = .wheels
        }
        $0.datePickerMode = .date
        $0.timeZone = TimeZone.current
    }

    private lazy var occorrencePicker: UIPickerView = configure(UIPickerView()) {
        $0.dataSource = self
        $0.delegate = self
    }

    // MARK: Table View Cells

    private lazy var neverCell: FrequencySelectionCell = configure(AnytimeNibs.frequencySelectionCell) {
        $0.configureCell(
            withTitle: "Never",
            shouldShowSeparator: true
        )
    }

    private lazy var onDateCell: FrequencySelectionCell = configure(AnytimeNibs.frequencySelectionCell) {
        $0.configureCell(
            withTitle: "On a date",
            shouldShowSeparator: true
        )
    }

    lazy var datePickerCell = configure(UITableViewCell()) {
        let picker = self.datePicker
        picker.translatesAutoresizingMaskIntoConstraints = false
        $0.contentView.addSubview(picker)

        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                picker.leadingAnchor.constraint(equalTo: $0.contentView.safeAreaLayoutGuide.leadingAnchor),
                picker.trailingAnchor.constraint(equalTo: $0.contentView.safeAreaLayoutGuide.trailingAnchor),
                picker.bottomAnchor.constraint(equalTo: $0.contentView.safeAreaLayoutGuide.bottomAnchor),
            ])
        } else {
            // Fallback on earlier versions
        }
        $0.separatorInset.right = .greatestFiniteMagnitude
    }

    private lazy var occurrencesCell: FrequencySelectionCell = configure(AnytimeNibs.frequencySelectionCell) {
        $0.configureCell(
            withTitle: "After 1 occurrences",
            shouldShowSeparator: true
        )
    }

    private lazy var pickerCell = configure(UITableViewCell()) {
        let picker = self.occorrencePicker
        picker.translatesAutoresizingMaskIntoConstraints = false
        $0.contentView.addSubview(picker)

        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                picker.leadingAnchor.constraint(equalTo: $0.contentView.safeAreaLayoutGuide.leadingAnchor),
                picker.trailingAnchor.constraint(equalTo: $0.contentView.safeAreaLayoutGuide.trailingAnchor),
                picker.bottomAnchor.constraint(equalTo: $0.contentView.safeAreaLayoutGuide.bottomAnchor),
            ])
        } else {
            // Fallback on earlier versions
        }
        $0.separatorInset.right = .greatestFiniteMagnitude
    }

    // MARK: - Targets

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        editedFrequencyMode = .date(date: sender.date)
    }

    // MARK: - Help Functions

    private func didTapDoneButton() {
        delegate?.didUpdateFrequency(.custom(editedRule))
        router?.route(to: .backToRoot, from: self, info: nil)
    }

    private func updateOccurrencesCell() {
        let currentCellPickerData = viewModel.pickerData[occorrencePicker.selectedRow(inComponent: 0)]
        occurrencesCell.setTitle("After \(currentCellPickerData) occurrences")
    }

    private func markSelectedCell() {
        neverCell.isDurationSelected = currentFrequencyMode == .never
        onDateCell.isDurationSelected = currentFrequencyMode == .date(date: currentRule.recurrenceEnd?.endDate)
        occurrencesCell.isDurationSelected = currentFrequencyMode == .occurence(count: currentRule.recurrenceEnd?.occurrenceCount)
    }
}

// MARK: - Table view data source

extension EndReccurringViewController {
    override func numberOfSections(in _: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModels = viewModel.cellForRowAt(indexPath: indexPath)

        switch cellModels {
        case .never: return neverCell
        case .onDate: return onDateCell
        case .occurrences: return occurrencesCell
        case .onDatePicker: return datePickerCell
        case .occurrencesPicker: return pickerCell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let cellModels = viewModel.tableViewData[indexPath.section].cellModels[indexPath.row]

        switch cellModels {
        case .never:
            editedFrequencyMode = .never

        case .onDate:
            datePickerValueChanged(datePicker)
            editedFrequencyMode = .date(date: currentRule.recurrenceEnd?.endDate)

        case .occurrences:
            editedFrequencyMode = .occurence(count: 1)

        case .onDatePicker: break
        case .occurrencesPicker: break
        }
        markSelectedCell()

        UIView.animate(withDuration: 0.5, animations: {
            self.tableView.reloadData()
        })
    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellModels = viewModel.tableViewData[indexPath.section].cellModels[indexPath.row]

        switch cellModels {
        case .occurrences, .onDate, .never:
            return 60

        case .onDatePicker:
            return editedFrequencyMode == .date(date: currentRule.recurrenceEnd?.endDate) ? 180 : 0

        case .occurrencesPicker:
            return editedFrequencyMode == .occurence(count: currentRule.recurrenceEnd?.occurrenceCount) ? 180 : 0
        }
    }
}

// MARK: - NavigationBarButtonDelegate

extension EndReccurringViewController: NavBarActionDelegate {
    func didTapNavBarButton() {
        didTapDoneButton()
    }
}

// MARK: - UIPickerViewDataSource / UIPickerViewDelegate

extension EndReccurringViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return viewModel.numberOfComponents()
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.numberOfRowsInComponent(component)
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.titleForRow(row, forComponent: component)
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent _: Int) -> CGFloat {
        return pickerView.frame.width
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        let dataForComponent = viewModel.pickerData[row]

        if let value = Int(dataForComponent) {
            editedFrequencyMode = .occurence(count: value)
            updateOccurrencesCell()
        }
    }
}
