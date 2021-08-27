//
//  EventBaseViewModel.swift
//  Anytime
//
//  Created by Vignesh on 07/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import PromiseKit
import EventKit

protocol EventBaseVMProtocol {
    
    var originalEventModel: EventModel? { get set }
    var editedEventModel: EventModel? { get set }
    var mode: EventActionType? { get set }
    var view: EventBaseVCProtocol? { get set }
    var delegate: EventBaseVMDelegateProtocol? { get set }
    var appointmentDelegate: AppointmentDelegate? { get set }
    func viewDidLoad()
    func updateResponseStatus(_ responseStatus: ResponseStatus)
    func deleteEvent(with type: EventDeleteActionType)
    func saveEvent(with actionType: EventActionType, _ displayedEvent: EventDisplayModel, shouldCheckSlot: Bool)
}

protocol EventBaseVMDelegateProtocol: class {
    func didStartAction(_ loaderText: String)
    func didCompleteAction(_ result: Swift.Result<String, Error>)
    func didUpdateResponseStatus(_ result: Swift.Result<Bool, Error>)
}

class EventBaseViewModel: EventBaseVMProtocol {
    
    var view: EventBaseVCProtocol?
    var user: User?
    var originalEventModel: EventModel?
    internal var editedEventModel: EventModel?

    weak var delegate: EventBaseVMDelegateProtocol?
    var mode: EventActionType?
    var appointmentDelegate: AppointmentDelegate?
    
    init() {
        self.user = EventViewSDKConfiguration.current.user
    }
    
    func viewDidLoad() {
        guard let eventData = getDataForView() else {
            return
        }
        processDataToView(eventData)
    }
    
    private func getDataForView() -> EventDisplayModel? {
        
        guard mode == .update else {
            return createNewEvent()
        }
        
        guard let event = originalEventModel else {
            return nil
        }
        
        self.editedEventModel = originalEventModel
        var eventDisplayModel = EventDisplayModel(withEvent: event)
        
        if let createdBy = event.createdBy, let user = self.user {
            let isHost = createdBy == user.id
            eventDisplayModel.isHost = isHost
//            eventDisplayModel.responseStatus = originalEventModel?.getResponseStatus(forId: user.id) ?? .pending
        } 
        return eventDisplayModel
    }
    
    private func createNewEvent() -> EventDisplayModel? {
        guard let appUser = user, let accountId = appUser.account else {
            assertionFailure("User Data missing in Event Base Flow")
            return nil
        }
        
        let currentDate = view?.selectedDate ?? Date()
        let (startTime, endTime) = DateUtils.getUpcomingTimeRangeInMilliSec(forDate: currentDate)
        let startDateTime = Date(milliseconds: Int(startTime)).zuluString
        let endDateTime = Date(milliseconds: Int(endTime)).zuluString
        let brand = EventViewSDKConfiguration.current.appBrand ?? .Anytime
    
        let defaultEvent = EventModel(id: "", calendar: accountId, merchant: accountId, brand: brand, type: .event, provider: [appUser.id], service: [], consumer: [], resource: [], startDateTime: startDateTime, endDateTime: endDateTime, startTime: startTime, endTime: endTime, maxSeats: 1, cost: 0, isExternal: false, isDeleted: false, rRule: nil, paymentStatus: nil, label: "", bookingId: nil, source: "", parentId: nil, title: "", location: nil, notes: nil, createdBy: appUser.id, createdTime: startTime, updatedTime: startTime)

        originalEventModel = defaultEvent
        editedEventModel = originalEventModel
        let eventToDisplay = EventDisplayModel(withEvent: defaultEvent)
        
        return eventToDisplay
    }
    
    private func processDataToView(_ data: EventDisplayModel) {
        view?.loadEventData(data)
    }

    // MARK: - HANDLE EVENT CRUD METHODS TASK
    func updateResponseStatus(_ responseStatus: ResponseStatus) {
    }
    
    // MARK: - Delete event with type
    func deleteEvent(with type: EventDeleteActionType) {
        
        guard let event = originalEventModel else {
            Logger.error("Event id missing")
            return
        }
        
        switch type {
        case .event:
            delegate?.didStartAction(Constants.LoaderMessages.singleEventDeletedMessage)
            appointmentDelegate?.delete(event: event, forActionType: .event, completion: { result in
                self.delegate?.didCompleteAction(result)
            })
        case .recurring:
            delegate?.didStartAction(Constants.LoaderMessages.wholeEventDeletedMessage)
            appointmentDelegate?.delete(event: event, forActionType: .recurring, completion: { result in
                self.delegate?.didCompleteAction(result)
            })
        case .tail:
            delegate?.didStartAction(Constants.LoaderMessages.tailEventDeletedMessage)
            appointmentDelegate?.delete(event: event, forActionType: .tail, completion: { result in
                self.delegate?.didCompleteAction(result)
            })
        }
    }
    
    func saveEvent(with actionType: EventActionType, _ displayedEvent: EventDisplayModel, shouldCheckSlot: Bool) {
        editedEventModel?.title = displayedEvent.eventName
        editedEventModel?.notes = displayedEvent.notes
        editedEventModel?.startDateTime = displayedEvent.startDate.zuluString
        editedEventModel?.endDateTime = displayedEvent.endDate.zuluString
        editedEventModel?.rRule = displayedEvent.rRule
    
        guard let event = editedEventModel  else {
            self.delegate?.didCompleteAction(.failure(InternalError.missingData))
            return
        }
        switch actionType {
            
        case .create:
            delegate?.didStartAction(Constants.LoaderMessages.eventCreatedMessage)
            appointmentDelegate?.actionFor(event: event, withActionType: .create, completion: { result in
                self.delegate?.didCompleteAction(result)
            })

        case .update:
            delegate?.didStartAction(Constants.LoaderMessages.eventUpdatedMessage)
            appointmentDelegate?.actionFor(event: event, withActionType: .update, completion: { result in
                self.delegate?.didCompleteAction(result)
            })

        case .recurringCreate:
            guard displayedEvent.repeatMode != .doNotRepeat else {
                self.delegate?.didCompleteAction(.failure(InternalError.missingData))
                return
            }
            delegate?.didStartAction(Constants.LoaderMessages.recuringEventCreatedMessage)
            appointmentDelegate?.actionFor(event: event, withActionType: .recurringCreate, completion: { result in
                self.delegate?.didCompleteAction(result)
            })

        case .recurringUpdate:
            guard displayedEvent.repeatMode != .doNotRepeat else {
                self.delegate?.didCompleteAction(.failure(InternalError.missingData))
                return
            }

            guard editedEventModel?.parentId != nil else {
                self.delegate?.didCompleteAction(.failure(InternalError.missingData))
                return
            }
            delegate?.didStartAction(Constants.LoaderMessages.recuringEventUpdatedMessage)
            appointmentDelegate?.actionFor(event: event, withActionType: .recurringUpdate, completion: { result in
                self.delegate?.didCompleteAction(result)
            })
            
        case .tail:
            guard displayedEvent.repeatMode != .doNotRepeat else {
                self.delegate?.didCompleteAction(.failure(InternalError.missingData))
                return
            }
            delegate?.didStartAction(Constants.LoaderMessages.tailEventUpdatedMessage)
            appointmentDelegate?.actionFor(event: event, withActionType: .tail, completion: { result in
                self.delegate?.didCompleteAction(result)
            })
            
        case .recurringToEvent:
            delegate?.didStartAction(Constants.LoaderMessages.recuringEventUpdatedToSingleMessage)
            appointmentDelegate?.actionFor(event: event, withActionType: .recurringToEvent, completion: { result in
                self.delegate?.didCompleteAction(result)
            })
            
        case .eventToRecurring:
            guard displayedEvent.repeatMode != .doNotRepeat else {
                self.delegate?.didCompleteAction(.failure(InternalError.missingData))
                return
            }
            delegate?.didStartAction(Constants.LoaderMessages.singleEventUpdatedToRecuringMessage)
            appointmentDelegate?.actionFor(event: event, withActionType: .eventToRecurring, completion: { result in
                self.delegate?.didCompleteAction(result)
            })
        }
    }
}

enum Constants {
    enum LoaderMessages {
        static let eventCreatedMessage = "Creating Single Event..."
        static let eventUpdatedMessage = "Updating Single Event..."
        static let recuringEventCreatedMessage = "Creating Recurring Event..."
        static let recuringEventUpdatedMessage = "Updating Recurring Event..."
        static let tailEventUpdatedMessage = "Tail updating..."
        static let recuringEventUpdatedToSingleMessage = "Recurring Event -> SINGLE"
        static let singleEventUpdatedToRecuringMessage = "Single Event -> RECURRING..."
        static let singleEventDeletedMessage = "Deleting event.."
        static let tailEventDeletedMessage = "Deleting future events.."
        static let wholeEventDeletedMessage = "Deleting whole recurring event.."
    }
    
    enum AlertMessages {
        static let eventCreatedMessage = "Single Event created succesfully"
        static let eventUpdatedMessage = "Single Event updated succesfully"
        static let recuringEventCreatedMessage = "Recuring Event created succesfully"
        static let recuringEventUpdatedMessage = "Recurring Event updated succesfully"
        static let wholeEventUpdatedMessage = "Whole Event updated succesfully"
        static let tailEventUpdatedMessage = "Tail Recurring Event updated succesfully"
        static let recuringEventUpdatedToSingleMessage = "Recuring Event updated to single succesfully"
        static let singleEventUpdatedToRecuringMessage = "Single Event updated to recurring succesfully"
        
        static let childEventDeletedMessage = "Child recurring event deleted successfully"
        static let singleEventDeletedMessage = "Event deleted successfully"
        static let tailEventDeletedMessage = "Tail Recurring Event deleted successfully"
        static let wholeEventDeletedMessage = "Whole Event deleted successfully"
    }
}

enum InternalError: String {
    case missingData
}

extension InternalError: LocalizedError {
    
    var errorDescription: String? {
        return NSLocalizedString("Something went wrong. Please try again", comment: "")
    }
}
