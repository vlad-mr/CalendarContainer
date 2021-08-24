//
//  EventRouter.swift
//  Anytime
//
//  Created by Vignesh on 09/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit.UIViewController

enum EventRoute {
    case timezone
    case selectContacts
    case displayContacts
    case selectFrequency
    case dismiss
    case back
}

class EventRouter: Router {
    
    typealias AppRoute = EventRoute

    init() {}
        
    public static var initialViewController: EventBaseNavigationController {
        let eventBaseNavigation = AnytimeNibs.eventBaseNavigation
        return eventBaseNavigation
    }
    
    func route(to destination: EventRoute, from source: UIViewController, info: Any?) {
        
        switch destination {
            
        case .selectContacts: break
//            let guestView = ContactListViewController()
//            guestView.delegate = source as? ContactListDelegate
//            // Have to check if the delegate is satisfied else, asserion Error!
//            let addContactView = SelectContactsViewController()
//            addContactView.delegate = source as? SelectContactsViewDelegate
//            if let contactList = info as? ContactIdList {
//                let viewModel = SelectContactsViewModel(withContactIdList: contactList)
//                addContactView.viewModel = viewModel
//                /* if let invitedGuests = guest.0 {
//                    selectedGuests = selectedGuests.filter { !invitedGuests.contains($0) }
//                 }
//                 */
//            }
//            source.navigationController?.pushViewController(addContactView, animated: true)
        case .timezone: break
//            let timezoneVC = TimeZoneViewController()
//            timezoneVC.delegate = source as? TimeZoneViewControllerDelegateProtocol
//            timezoneVC.currentTimeZone = timezoneVC.delegate?.currentTimezone
//            source.navigationController?.pushViewController(timezoneVC, animated: true)
        case .dismiss:
            source.dismiss(animated: true, completion: nil)
        case .displayContacts: break
//            guard let participantsList = info as? [ContactDisplayModel] else { return }
//            let staticContactView = StaticContactListViewController()
//            staticContactView.participantsList = participantsList
//            source.navigationController?.pushViewController(staticContactView, animated: true)

        case .selectFrequency: 
            let event = info as? EventDisplayModel
            let recurringView = AnywhereRecurringView.getRecurringView(
                forInitialFrequency: event?.repeatMode ?? .doNotRepeat,
                eventStartDate: event?.startDate ?? Date(),
                delegate: source as? FrequencyVCDelegate)

            source.navigationController?.pushViewController(recurringView, animated: true)
            
        case .back:
            source.navigationController?.popViewController(animated: true)
        }
    }
}
