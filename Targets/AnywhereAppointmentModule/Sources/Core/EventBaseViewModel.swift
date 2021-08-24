//
//  EventBaseViewModel.swift
//  Anytime
//
//  Created by Vignesh on 07/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import EventKit
import Foundation
import PromiseKit

protocol EventBaseVMProtocol {
    var event: Event? { get set }
    var originalEventModel: EventModel? { get set }
    var editedEventModel: EventModel? { get set }
    var mode: EventActionType? { get set }
    var view: EventBaseVCProtocol? { get set }
    var delegate: EventBaseVMDelegateProtocol? { get set }

    func viewDidLoad()
    func updateResponseStatus(_ responseStatus: ResponseStatus)
    func deleteEvent(with type: RemoveEventActionType)
    func saveEvent(with actionType: EventActionType, _ displayedEvent: EventDisplayModel, shouldCheckSlot: Bool)
}

protocol EventBaseVMDelegateProtocol: class {
    func didCompleteAction(_ result: Swift.Result<String, Error>)
    func didUpdateResponseStatus(_ result: Swift.Result<Bool, Error>)
}

class EventBaseViewModel: EventBaseVMProtocol {
    var view: EventBaseVCProtocol?
    var user: User?
    var event: Event?
    var originalEventModel: EventModel?
    internal var editedEventModel: EventModel?

    weak var delegate: EventBaseVMDelegateProtocol?

    var mode: EventActionType?

    init() {
        user = EventViewSDKConfiguration.current.user
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

        guard let event = event else {
            return nil
        }

        let eventModel = EventModel(fromEvent: event)
        originalEventModel = eventModel
        editedEventModel = originalEventModel

        var rRule: String?
//        if let parentId = eventModel.parentId {
//            let predicate = CoreDataHelper.getEventFetchPredicate(forKey: parentId)
//            if let parrentRrule = EventParrentConfiguration.mr_findFirst(with: predicate)?.rRule {
//                rRule = parrentRrule
//            }
//        }

        var eventDisplayModel = EventDisplayModel(withEvent: eventModel)
        if let rule = rRule {
            eventDisplayModel.rRule = rule
            eventDisplayModel.repeatMode = .init(rule: rule, startDate: eventDisplayModel.startDate)
        }

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

        let defaultEvent = EventModel(id: "", parentId: nil, merchant: accountId, calendar: accountId, startTime: startTime, endTime: endTime, maxSeats: 1, service: [], consumer: [], provider: [appUser.id], resource: [], bookingId: nil, title: "", createdBy: appUser.id, location: nil, createdTime: startTime, updatedTime: startTime, startDateTime: Date(milliseconds: Int(startTime)).zuluString, endDateTime: Date(milliseconds: Int(endTime)).zuluString)

        originalEventModel = defaultEvent
        editedEventModel = originalEventModel
        let eventToDisplay = EventDisplayModel(withEvent: defaultEvent)

        return eventToDisplay
    }

    private func processDataToView(_ data: EventDisplayModel) {
        view?.loadEventData(data)
    }

    // MARK: - HANDLE EVENT CRUD METHODS TASK

    func updateResponseStatus(_: ResponseStatus) {}

    func deleteEvent(with _: RemoveEventActionType) {}

    func saveEvent(with _: EventActionType, _: EventDisplayModel, shouldCheckSlot _: Bool) {}
}

enum RemoveEventActionType {
    case child
    case tail
    case whole
}
