//
//  EventBaseTableViewController.swift
//  Anytime
//
//  Created by Vignesh on 11/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

protocol EventBaseTableViewDelegateProtocol: class {
    func didTapLink(_ link: String)
    func didCopyLink()
    func didBeginEditing()
    func didTapTimezone()
    func didUpdate(shouldSave: Bool)
    func didTapDeleteButton()
    func saveEventInfo()
    func didTapFrequency()
}

protocol EventBaseTableViewProtocol {
}

class EventBaseTableViewController: UITableViewController {
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    private var isStartDatePickerOpen = false
    private var isEndDatePickerOpen = false
    var editingEnabled: Bool = true
    var noOfContacts = 0 {
        didSet {
            editedEvent?.consumerCount = noOfContacts
            tableView.reloadData()
        }
    }
    
    var viewMode: ViewMode = .mini {
        didSet {
            guard viewMode != oldValue else {
                return
            }
            UIView.animate(withDuration: 0.3) {
                self.tableView.reloadSections(IndexSet(integersIn: 1...2), with: .fade)
            }
        }
    }
    var eventActionType: EventActionType = .create
    var eventToDisplay: EventDisplayModel?
    
    var editedEvent: EventDisplayModel? {
        didSet {
            let isEdited = (eventToDisplay != editedEvent) || eventActionType == .create
            delegate?.didUpdate(shouldSave: isEdited)
        }
    }
    var selectedDate: Date?
    
    var isEditingTextField: Bool {
        self.eventNameCell.textField.isFirstResponder || self.notesCell.textView.isFirstResponder
    }
    
    weak var delegate: EventBaseTableViewDelegateProtocol?
    weak var frequencyVCDelegate: FrequencyVCDelegate?
    
    // Event Table Cells
    
    lazy var eventNameCell: TextFieldWithImageCell = configure(AnytimeNibs.textFieldWithImage, using: {
        $0.configureCell(withPlaceHolder: "Add Event Name", icon: AppDecor.Icons.textFieldIcon, shouldShowSeparator: true, sourceIcon: nil)
        $0.textField.delegate = self
        $0.textField.addTarget(self, action: #selector(textFieldDidChangeContent), for: .editingChanged)
    })
    
    lazy var dateTimeCell: EventDateCell = {
        let cell = AnytimeNibs.eventDateCell
        cell.configureCell(withTitle: nil, icon: AppDecor.Icons.dateTime)
        return cell
    }()
    
    lazy var startTimeCell: EventDateCell = {
        let cell = AnytimeNibs.eventDateCell
        cell.configureCell(withTitle: "Start", icon: AppDecor.Icons.startTime)
        return cell
    }()
    
    lazy var endTimeCell: EventDateCell = {
        let cell = AnytimeNibs.eventDateCell
        cell.configureCell(withTitle: "End", icon: AppDecor.Icons.endTime, shouldShowSeparator: true)
        return cell
    }()
    
    lazy var timezoneCell: EventTitleDescriptionCell = {
        let cell = AnytimeNibs.eventTitleCell
        cell.configureCell(withTitle: "Time Zone", icon: AppDecor.Icons.timezone)
        cell.isHidden = true
        cell.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        return cell
    }()
    
    lazy var repeatCell: EventTitleDescriptionCell = {
        let cell = AnytimeNibs.eventTitleCell
        cell.configureCell(withTitle: "Repeat", icon: AppDecor.Icons.repeatIcon, shouldShowSeparator: false)
        return cell
    }()
    
    lazy var addGuestsCell: UITableViewCell = {
        return AnytimeNibs.guestCell
    }()
    
    lazy var addNotificationsCell: EventTitleDescriptionCell = {
        let cell = AnytimeNibs.eventTitleCell
        cell.configureCell(withTitle: "Notifications", titleForEmptyState: "Add Notifications", icon: AppDecor.Icons.addNotifications_inactive, mode: .disabled, shouldShowSeparator: false)
        return cell
    }()
    
    lazy var locationCell: EventLinkCell = {
        
        let cell = AnytimeNibs.eventLinkCell
        let mode: EventLinkCell.CellMode = self.eventActionType == .create ? .noShare : .shouldShare
        cell.configureCell(forMode: mode, withTitle: "Location", description: "Anywhere - Teleport call", icon: AppDecor.Icons.locationIcon, shouldShowSeparator: true)
        cell.delegate = self
        return cell
    }()
    
    lazy var notesCell: TextViewCell = {
        let cell = AnytimeNibs.textViewCell
        cell.configureCell(withPlaceHolder: "Add notes", icon: AppDecor.Icons.textFieldIcon, shouldShowSeparator: false)
        cell.textViewDelegate = self
        return cell
    }()
    
    lazy var tableFooterView = configure(UIView()) {
        $0.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 55))
        let deleteButton = RoundedButton.getButton(forAction: .delete(), target: self, handler: #selector(self.didTapDeleteButton), frame: CGRect(x: 20, y: $0.bounds.origin.y + 5, width: $0.bounds.width - 40, height: 45))
        $0.addSubview(deleteButton)
    }
    
    /// This enum denotes the type of date picker that has to be toggled
    enum TimePickerMode {
        case start, end
    }
    
    override func viewDidLoad() {
        setupDatePickers()
    }
    
    private func setupTable(forActionType actionType: EventActionType) {
        let event = eventToDisplay.require(hint: "Missing event to display!")
        guard actionType == .update, !event.isExternal, event.isHost else {
            return
        }
        tableView.tableFooterView = tableFooterView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        super.viewWillAppear(animated)
        if viewMode == .mini {
            setScrollEnabled(false)
        }
    }
    
    func setupView() {
        guard let event = eventToDisplay else {
            return
        }
        let isExternalEvent = event.isExternal
        event.eventName.isEmpty && isExternalEvent ? eventNameCell.setText("No Title") : eventNameCell.setText(event.eventName)
        event.notes.isEmpty && isExternalEvent  ? notesCell.setText("No Notes") : notesCell.setText(event.notes)
        eventNameCell.isEnabled = editingEnabled && !isExternalEvent
        notesCell.isEnabled = editingEnabled && !isExternalEvent
        startTimeCell.isUserInteractionEnabled = editingEnabled && !isExternalEvent
        endTimeCell.isUserInteractionEnabled = editingEnabled && !isExternalEvent
    }
    
    func setScrollEnabled(_ isEnabled: Bool) {
        self.tableView.isScrollEnabled = isEnabled
    }
    
    /// This method adds target actions for any change the value of both the pickers
    func setupDatePickers() {
        
        startDatePicker.addTarget(self, action: #selector(eventStartDatePickerDidChange), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(eventEndDatePickerDidChange), for: .valueChanged)
        if #available(iOS 13.4, *) {
            startDatePicker.preferredDatePickerStyle = .wheels
            endDatePicker.preferredDatePickerStyle = .wheels
        }
        ///getting the timezone from the user setting and globally applying it to all events
        guard let timezone = TimeZone(identifier: EventViewSDKConfiguration.current.accountTimezoneId) else {
            assertionFailure("user has invalid timezone")
            return
        }
        startDatePicker.timeZone = timezone
        endDatePicker.timeZone = timezone
    }
    
    func beginEditing() {
        delegate?.didBeginEditing()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
        case EventBaseCells.name.indexPath:
            eventNameCell.textField.becomeFirstResponder()
        case EventBaseCells.dateTime.indexPath:
            var duration: DispatchTime = .now()
            if viewMode == .mini {
                beginEditing()
                duration = .now() + 0.75
            }
            DispatchQueue.main.asyncAfter(deadline: duration) {
                self.viewMode = .full
                self.toggleDatePicker(for: .start)
            }
        case EventBaseCells.startDate.indexPath:
            toggleDatePicker(for: .start)
        case EventBaseCells.endDate.indexPath:
            toggleDatePicker(for: .end)
        case EventBaseCells.location.indexPath:
            guard let link = editedEvent?.location else {
                return
            }
            delegate?.didTapLink(link)
        case EventBaseCells.repeatMode.indexPath:
            delegate?.didTapFrequency()
            
        case EventBaseCells.timeZone.indexPath:
            Logger.info("TimeZone cell is hidden")
//            delegate?.didTapTimezone()
        case EventBaseCells.guest.indexPath:
            Logger.info("TimeZone cell is hidden")
        default:
            break
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
            
        case EventBaseCells.name.indexPath:
            return eventNameCell
            
        case EventBaseCells.dateTime.indexPath:
            return dateTimeCell
            
        case EventBaseCells.startDate.indexPath:
            return startTimeCell
            
        case EventBaseCells.endDate.indexPath:
            return endTimeCell
            
        case EventBaseCells.timeZone.indexPath:
            return timezoneCell
            
        case EventBaseCells.repeatMode.indexPath:
            return repeatCell
            
        case EventBaseCells.guest.indexPath:
            return addGuestsCell
            
        case EventBaseCells.notifications.indexPath:
            return addNotificationsCell
            
        case EventBaseCells.location.indexPath:
            return locationCell
            
        case EventBaseCells.notes.indexPath:
            return notesCell
            
        default:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let eventToDisplay = self.eventToDisplay else { return 0 }
        switch section {
        case 1 where viewMode == .full:
            return 0
        case 2 where viewMode == .mini:
            return 0
        case 4...6 where eventToDisplay.isExternal:
            return 0
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath {
            
        case EventBaseCells.startDatePicker.indexPath:
            return isStartDatePickerOpen ? 180 : 0
        case EventBaseCells.endDatePicker.indexPath:
            return isEndDatePickerOpen ? 180 : 0
        case EventBaseCells.location.indexPath:
            return self.eventActionType == .create ? 74 : 160
        case EventBaseCells.guest.indexPath:
            return 0
        case EventBaseCells.timeZone.indexPath:
            return 0
        case EventBaseCells.notes.indexPath:
            return UITableView.automaticDimension
        default:
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    /// This method toggles the state of the specified picker
    /// - Parameter mode: The type of picker to toggle
    func toggleDatePicker(for mode: TimePickerMode) {
        
        beginEditing()
        switch mode {
        case .start:
            self.isStartDatePickerOpen.toggle()
            if isEndDatePickerOpen {
                self.isEndDatePickerOpen.toggle()
            }
        case .end:
            self.isEndDatePickerOpen.toggle()
            if isStartDatePickerOpen {
                self.isStartDatePickerOpen.toggle()
            }
        }
        tableView.beginUpdates()
        tableView.reloadData()
        tableView.endUpdates()
    }

    private var tempStartDate: Date?
    private var tempEndDate: Date?
    /// This methods handles any changes in the start date picker
    @objc func eventStartDatePickerDidChange() {
        let seccondsDiff = Int(tempStartDate!.timeIntervalSince(startDatePicker.date))
        let startDateString = startDatePicker.date.dateString()
        let startTimeString = startDatePicker.date.timeString()
        editedEvent?.startDate = startDatePicker.date
        startTimeCell.set(date: startDateString, time: startTimeString)
        
        if endDatePicker.date <= startDatePicker.date {
            endDatePicker.date = endDatePicker.date.dateByAdding(-seccondsDiff, .second).date
            tempEndDate = endDatePicker.date
            editedEvent?.endDate = endDatePicker.date
            endTimeCell.set(date: endDatePicker.date.dateString(), time: endDatePicker.date.timeString())
        } else if let updatedEndDate = tempEndDate?.dateByAdding(-seccondsDiff, .second).date {
            endDatePicker.date = updatedEndDate
            editedEvent?.endDate = updatedEndDate
            tempEndDate = updatedEndDate
            endTimeCell.set(date: updatedEndDate.dateString(), time: updatedEndDate.timeString())
        }

        tempStartDate = startDatePicker.date
        endDatePicker.minimumDate = startDatePicker.date.dateByAdding(15, .minute).date
        
        if let event = editedEvent, event.repeatMode != .doNotRepeat {
            let newDate = event.startDate
            let newRrule = event.repeatMode?.getStaticRule(newDate) ?? ""
            let newFrequency = Frequency(rule: newRrule, startDate: newDate)
            frequencyVCDelegate?.didUpdateFrequency(newFrequency)
        }
    }
    
    // This methods handles any changes in the end date picker
    @objc func eventEndDatePickerDidChange() {
        endDatePicker.minimumDate = startDatePicker.date.dateByAdding(15, .minute).date
        let endDateString = endDatePicker.date.dateString()
        let endTimeString = endDatePicker.date.timeString()
        editedEvent?.endDate = endDatePicker.date
        endTimeCell.set(date: endDateString, time: endTimeString)
        tempEndDate = endDatePicker.date
    }
}

extension EventBaseTableViewController {
    
    func loadEventData(_ event: EventDisplayModel, actionType: EventActionType = .create) {
        
        eventToDisplay = event
        editedEvent = eventToDisplay
        eventNameCell.setText(event.eventName)
        if event.isExternal {
//            eventNameCell.setSourceIcon(event.source?.image)
            //get image from AnywhereSchedulingEngineModule eventModel
        }
        dateTimeCell.set(date: event.startDate.dateString(), time: "\(event.startDate.timeString()) - \(event.endDate.timeString())")
        startTimeCell.set(date: event.startDate.dateString(), time: event.startDate.timeString())
        endTimeCell.set(date: event.endDate.dateString(), time: event.endDate.timeString())
        notesCell.setText(event.notes)
        timezoneCell.setDescription(event.timezone)
        
        let description = Frequency.cellDynamicTitle(for: event.repeatMode!, event.startDate)
        repeatCell.setDescription(description)
        locationCell.setLink(event.location)
    
        noOfContacts = event.consumerCount
        startDatePicker.date = event.startDate
        tempStartDate = event.startDate
        tempEndDate = event.endDate
        endDatePicker.minimumDate = event.startDate
        endDatePicker.date = event.endDate
        setupView()
        setupTable(forActionType: actionType)
        tableView.reloadData()
    }
    
    @objc func didTapDeleteButton() {
        delegate?.didTapDeleteButton()
    }
}

extension EventBaseTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case eventNameCell.textField:
            eventNameCell.textField.resignFirstResponder()
            if viewMode == .mini {
                delegate?.saveEventInfo()
            }
        default:
            view.endEditing(true)
        }
        return true
    }
    
    @objc func textFieldDidChangeContent(_ textField: UITextField) {
        switch textField {
        case eventNameCell.textField:
            editedEvent?.eventName = textField.text ?? ""
        default:
            break
        }
    }
}

extension EventBaseTableViewController: EventLinkCellDelegateProtocol {
    
    func share(link: String) {
        let shareSheet = UIActivityViewController(activityItems: [link as String], applicationActivities: [])
        self.present(shareSheet, animated: true, completion: nil)
    }
    
    func didCopyLink() {
        
        delegate?.didCopyLink()
    }
    
    func actionForLink(_ link: String) {
        delegate?.didTapLink(link)
    }
}

extension EventBaseTableViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        notesCell.becomeFirstResponder()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        notesCell.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        editedEvent?.notes = textView.text
        updateTableView()
    }
    
    // To increase the height of the cell, and positioning the cursor at the correct position.
    func updateTableView() {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
}
