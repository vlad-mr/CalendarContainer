//
//  EventBaseViewController.swift
//  Anytime
//
//  Created by Vignesh on 06/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit
import MBProgressHUD
import CustomViewPresenter

protocol EventBaseVCProtocol: class {
    var eventToDisplay: EventDisplayModel? { get set }
    var selectedDate: Date? { get set }
    var eventBaseTableView: EventBaseTableViewController? { get set }
    func loadEventData(_ event: EventDisplayModel)
}

enum EventViewMode {
    case host
    case nonHost
}

enum EventBaseCells {
    case name, dateTime, startDate, startDatePicker, endDate, endDatePicker, timeZone, repeatMode, guest, notifications, location, notes
    
    var indexPath: IndexPath {
        
        switch self {
        case .name:
            return IndexPath(row: 0, section: 0)
        case .dateTime:
            return IndexPath(row: 0, section: 1)
        case .startDate:
            return IndexPath(row: 0, section: 2)
        case .startDatePicker:
            return IndexPath(row: 1, section: 2)
        case .endDate:
            return IndexPath(row: 2, section: 2)
        case .endDatePicker:
            return IndexPath(row: 3, section: 2)
        case .timeZone:
            return IndexPath(row: 4, section: 2)
        case .guest:
            return IndexPath(row: 0, section: 3)
        case .location:
            return IndexPath(row: 0, section: 4)
        case .repeatMode:
            return IndexPath(row: 0, section: 5)
        case .notifications:
            return IndexPath(row: 0, section: 6)
        case .notes:
            return IndexPath(row: 0, section: 7)
        }
    }
}

public enum ViewMode {
    case mini, full
}

public class EventBaseNavigationController: UINavigationController {
    
}

class EventBaseViewController: UIViewController {
    
    @IBOutlet weak var buttonView: EventDetailButtonView!
    @IBOutlet weak var tableContainerView: UIView!
    var currentTimezone: String?
    var selectedDate: Date?
    lazy var eventBaseTableView: EventBaseTableViewController? = AnytimeNibs.eventBaseTableView
    var viewModel: EventBaseVMProtocol? = EventBaseViewModel()
    
    var eventActionType: EventActionType = .create
    var router = EventRouter()
    var heightForMiniMode: CGFloat? = 342
    var viewMode: ViewMode = .mini
    
    lazy var alertHUD: MBProgressHUD = getAlertHud(srcView: self.view)
    var keyboardHeight: CGFloat = 0
    var eventViewMode: EventViewMode = .host
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupViewModel()
        buttonView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        eventBaseTableView?.tableView.endEditing(true)
        self.view.endEditing(true)
        removeObservers()
    }
    
    private func setupViewModel() {
        viewModel?.view = self
        viewModel?.mode = eventActionType
        viewModel?.delegate = self
        viewModel?.viewDidLoad()
    }
    
    private func setupObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeObservers() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupTableView() {
        
        guard let eventBaseTableView = self.eventBaseTableView else {
            assertionFailure("Events Table View missing")
            return
        }
        eventBaseTableView.eventActionType = eventActionType
        eventBaseTableView.selectedDate = selectedDate
        eventBaseTableView.delegate = self
        eventBaseTableView.frequencyVCDelegate = self
        eventBaseTableView.viewMode = self.viewMode
        eventActionType == .update ? eventBaseTableView.setScrollEnabled(true) : eventBaseTableView.setScrollEnabled(false)
        embedViewController(eventBaseTableView, toContainerView: tableContainerView)
    }
    
    func saveButtonAction(shouldCheckSlot: Bool = false) {
        guard let event = eventBaseTableView?.editedEvent else {
            return
        }
        
        self.view.endEditing(true)
        
        if eventActionType == .create {
            let condition = event.rRule != nil
            condition ?
                self.viewModel?.saveEvent(with: .recurringCreate, event, shouldCheckSlot: shouldCheckSlot) :
                self.viewModel?.saveEvent(with: .create, event, shouldCheckSlot: shouldCheckSlot)
            
        } else {
            
            guard event.parentId != nil else {
                let condition = eventToDisplay?.rRule == nil && event.rRule != nil
                condition ?
                    self.viewModel?.saveEvent(with: .eventToRecurring, event, shouldCheckSlot: shouldCheckSlot) :
                    self.viewModel?.saveEvent(with: .update, event, shouldCheckSlot: shouldCheckSlot)
                return
            }

            switch event.repeatMode {
            case .doNotRepeat:
                self.viewModel?.saveEvent(with: .recurringToEvent, event, shouldCheckSlot: shouldCheckSlot)
            default:
                
                guard event.rRule != eventToDisplay?.rRule else {
                    let cancelActionText = "Cancel"
                    let tailUpdateActionText = "Update This End All Futute"
                    let childUpdateActionText = "Update This Event Only"
                    let alertTitleText = "Are you sure you want to update this event?"
                    
                    let alertButtons: [UIAlertControllerCommonInputData.Button] = [
                        .init(title: childUpdateActionText, action: {
                            self.viewModel?.saveEvent(with: .update, event, shouldCheckSlot: shouldCheckSlot)
                        }),
                        .init(title: tailUpdateActionText, action: {
                            self.viewModel?.saveEvent(with: .tail, event, shouldCheckSlot: shouldCheckSlot)
                        }),
                        .init(title: cancelActionText, action: nil)
                    ]
                    
                    let commonInputData = UIAlertControllerCommonInputData(
                        title: alertTitleText,
                        message: String(),
                        buttons: alertButtons)
                    
                    showDeletionAlert(with: commonInputData)
                    return
                }
                self.viewModel?.saveEvent(with: .tail, event, shouldCheckSlot: shouldCheckSlot)
            }
        }
    }
    
    @objc
    private func keyboardWillShow(notification: Notification) {
    }
    
    @objc
    private func keyboardWillHide(notification: Notification) {
    }
    
    private func toggleToFullView() {
        if viewMode == .mini {
            maximizeToFullScreen()
            self.viewMode = .full
            eventBaseTableView?.viewMode = .full
        }
        self.viewMode = .full
        eventBaseTableView?.setScrollEnabled(true)
    }
    
    func didChangeToMaxMode() {
        toggleToFullView()
    }
    
}

extension EventBaseViewController: CustomViewPresentable {
    
    func didChangeToFullScreen() {
        viewMode = .full
        eventBaseTableView?.viewMode = .full
        toggleToFullView()
    }
}

extension EventBaseViewController: EventBaseTableViewDelegateProtocol {
    
    func didTapFrequency() {
        let info = eventBaseTableView?.editedEvent
        
        if viewMode == .mini {
            maximizeToFullScreen()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.router.route(to: .selectFrequency, from: self, info: info)
            }
        } else {
            router.route(to: .selectFrequency, from: self, info: info)
        }
    }
    
    func didTapDeleteButton() {
        let isRecurringMeeting = viewModel?.originalEventModel?.parentId != nil
        
        let deleteEventActionText = isRecurringMeeting ? "Delete This Event Only" : "Yes"
        let cancelActionText = isRecurringMeeting ? "Cancel" : "No"
        let deleteAllActionText = "Delete All Future Events"
        let wholeDelete = "Delete Whole"
        let additionalTitleText = isRecurringMeeting ? "This is repeating event." : ""
        let alertTitleText = "Are you sure you want to delete this event? \(additionalTitleText)"
        
        var alertButtons: [UIAlertControllerCommonInputData.Button] = [
            .init(title: deleteEventActionText, action: {
                self.viewModel?.deleteEvent(with: .event)
            }),
            .init(title: cancelActionText, action: nil)
        ]
        
        if isRecurringMeeting {
            alertButtons.insert(
                .init(title: deleteAllActionText, action: {                    
                    self.viewModel?.deleteEvent(with: .tail)
                }),
                at: 1)
            alertButtons.insert(
                .init(title: wholeDelete, action: {
                    self.viewModel?.deleteEvent(with: .recurring)
                }),
                at: 2)
        }
        let commonInputData = UIAlertControllerCommonInputData(
            title: alertTitleText,
            message: String(),
            buttons: alertButtons)
        
        showDeletionAlert(with: commonInputData)
    }
    
    func didTapTimezone() {
        if viewMode == .mini {
            toggleToFullView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.router.route(to: .timezone, from: self, info: nil)
            }
        } else {
            router.route(to: .timezone, from: self, info: nil)
        }
    }
    
    func didTapLink(_ link: String) {
        openLink(link)
    }
    
    func didBeginEditing() {
        maximizeToFullScreen()
    }
    
    func didUpdate(shouldSave: Bool) {
        buttonView.didUpdate(shouldSave: shouldSave)
    }
    
    func didCopyLink() {
        self.alertHUD.showText(msg: "Link Copied", detailMsg: "", duration: 1)
    }
    
    func changeTimezone(newTimezone: String) {
        eventBaseTableView?.timezoneCell.setDescription(newTimezone)
    }
    
    func saveEventInfo() {
        saveButtonAction()
    }
}

extension EventBaseViewController: EventBaseVCProtocol {
    
    var eventToDisplay: EventDisplayModel? {
        get {
            eventBaseTableView?.eventToDisplay
        }
        set {
            eventBaseTableView?.eventToDisplay = newValue
        }
    }
    
    func loadEventData(_ event: EventDisplayModel) {
        var isHost = event.isHost
        if event.source == .setmore {
            isHost = false
        }
        eventBaseTableView?.editingEnabled = isHost
        eventBaseTableView?.loadEventData(event, actionType: self.eventActionType)
        currentTimezone = EventViewSDKConfiguration.current.accountTimezoneId
        eventViewMode = isHost ? .host : .nonHost
        buttonView.setResponseStatus(event.responseStatus)
        guard event.isExternal else {
            buttonView.mode = eventViewMode
            return
        }
        eventViewMode = .host
        buttonView.mode = eventViewMode
        buttonView.didUpdate(shouldSave: false)
    }
}

extension EventBaseViewController: EventBaseVMDelegateProtocol {
    
    func didUpdateResponseStatus(_ result: Result<Bool, Error>) {
        alertHUD.hideHud()
        switch result {
        
        case .success(true):
            buttonView.setResponseStatus(.accepted)
        case .success(false):
            buttonView.setResponseStatus(.declined)
        case .failure(let error):
            alertHUD.showText(msg: "", detailMsg: error.localizedDescription, duration: 1)
        }
        alertHUD.hide(animated: true, afterDelay: 2)
    }
    
    func didStartAction(_ loaderText: String) {
        alertHUD.hideHud()
        alertHUD.showLoader(msg: loaderText)
    }
    
    func didCompleteAction(_ result: Result<String, Error>) {
        alertHUD.hideHud()
        switch result {
        case .success(let message):
            alertHUD.showText(msg: message, duration: 2)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.dismiss(animated: true, completion: nil)
            }
            
        case .failure(let error):
            if let error = error as? AppError, error == AppError.slotNotAvailable {
                showConflictAlert()
            } else {
                alertHUD.showText(msg: error.localizedDescription, duration: 2)
            }
        }
        alertHUD.hide(animated: true, afterDelay: 2)
    }
    
    private func showConflictAlert() {
        let conflictAlertController: UIAlertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let message = NSMutableAttributedString(string: "Looks like you’re double-booked. Would you like to continue?", attributes: [ .font: AppDecor.Fonts.medium.withSize(15)])
        conflictAlertController.setValue(message, forKey: "attributedMessage")
        
        conflictAlertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            self.saveButtonAction(shouldCheckSlot: false)
        }))
        conflictAlertController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(conflictAlertController, animated: true, completion: nil)
    }
    
}

extension EventBaseViewController: EventDetailActionsDelegate {
    
    func didTapAcceptButton() {
        alertHUD.showLoader(msg: "Accepting Invite...")
        viewModel?.updateResponseStatus(.accepted)
    }
    
    func didTapDeclineButton() {
        alertHUD.showLoader(msg: "Declining Invite...")
        viewModel?.updateResponseStatus(.declined)
    }
    
    func didTapSaveButton() {
        saveButtonAction()
    }
}

extension EventBaseViewController: FrequencyVCDelegate {
    func didUpdateFrequency(_ frequency: Frequency) {
        let date = eventBaseTableView?.editedEvent?.startDate
        eventBaseTableView?.repeatCell.setDescription(Frequency.cellDynamicTitle(for: frequency, date))
        eventBaseTableView?.editedEvent?.repeatMode = frequency
        eventBaseTableView?.eventToDisplay?.repeatMode = frequency
        eventBaseTableView?.editedEvent?.rRule = frequency.getStaticRule(date)
    }
}
