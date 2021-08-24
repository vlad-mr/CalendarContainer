//
//  EventDisplayModel.swift
//  Anytime
//
//  Created by Vignesh on 11/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation

struct EventDisplayModel: Equatable {
    var eventName: String
    var startDate: Date
    var endDate: Date
    let timezone: String
    var repeatMode: Frequency?
    var rRule: String?

    /* // not needed currently but will be used later
     let notification: String
     */
    let location: String
    var notes: String
    var consumerCount: Int = 0
    var isExternal: Bool
    var createdBy: String?
    var isHost: Bool = true
    var responseStatus: ResponseStatus = .pending
    var source: EventSource?
    var parentId: String?
}

extension EventDisplayModel {
    
    init(withEvent event: EventModel) {
        self.parentId = event.parentId
        self.eventName = event.title ?? ""
        let startDate = Date(timeIntervalSince1970: event.startTime.inSeconds)
        self.startDate = startDate
        let endDate = Date(timeIntervalSince1970: event.endTime.inSeconds)
        self.endDate = endDate
        self.repeatMode = .init(rule: event.rRule, startDate: startDate)
        self.rRule = event.rRule
        self.location = event.location?.teleport ?? ""
        let currentTimeZone = TimeZone(identifier: EventViewSDKConfiguration.current.accountTimezoneId) ?? TimeZone.current
        
        let offset = currentTimeZone.displayStringFromGMT(forDate: Date())
        let localizedName = currentTimeZone.localizedName(for: .standard, locale: .current) ?? ""
        let cityName = currentTimeZone.identifier.split(separator: "/").last ?? ""
        
        let displayName = "\(localizedName),\n\(cityName), (\(offset))"
        self.timezone = displayName
        self.notes = event.notes ?? ""
        self.isExternal = event.isExternal
        if let source = event.source {
            self.source = EventSource(rawValue: source)
        }
        if event.brand == .SetMore {
            self.source = .setmore
        }
        self.createdBy = event.createdBy
        self.consumerCount = event.consumer.count
    }
}

