//
//  SchedulingEngineAdapter.swift
//  CalendarContainer
//
//  Created by Volodymyr Kravchenko on 24.08.2021.
//  Copyright © 2021 Anywhere. All rights reserved.
//

import Foundation
import AnywhereSchedulingEngineModule
import PromiseKit

public final class SchedulingEngineAdapter {

  // MARK: - Public

  public init(with url: URL? = nil, token: String? = nil) {
    if let url = url { baseUrl = url }
    if let token = token { self.token = token }
  }

  public func fetchEvents() -> Promise<[EventModel]> {
    let config = EventFetchConfig.byEventIds(ids: Array(repeating: 0, count: 500).map { String($0) })
    return apiProvider.fetchEvents(with: config, shouldRefresh: true, shouldLoadNext: false)
      .map { $0.events.map(self.mapEventModel) }
  }

  public func fetchEventsTest() -> Promise<[EventModel]> {
    let json = """
    {
      "calendarIds": [
        "63bcfeb0-5613-4998-85ba-559a548c75ca"
      ],
      "providerIds": [
        "r2a961627975885651"
      ],
      "startTime": 1627257652397,
      "endTime": 1635206452397,
      "limit": 200,
      "isGroup": true
    }
    """
    let params = EventFetchParam.initialize(withData: json.data(using: .utf8)!)
    let config = EventFetchConfig.byFetchParam(param: params!)
    return apiProvider.fetchEvents(with: config, shouldRefresh: true, shouldLoadNext: false)
      .map { $0.events.map(self.mapEventModel) }
  }

  // MARK: - Private

  private var baseUrl = URL(string: "https://alpha-dot-staging-schedulingengine.el.r.appspot.com")!
  private var token = "empty"
  private lazy var apiProvider = SchedulingServiceBuilder.buildProvider(url: baseUrl, token: token)
  private lazy var dataProvider = AnywhereDataStackBuilder.buildProvider()

  private func mapEventModel(_ dto: AnywhereSchedulingEngineModule.EventModel) -> EventModel {
    return EventModel(id: dto.id,
                      calendar: dto.calendar,
                      merchant: dto.merchant,
                      brand: dto.brand.map,
                      type: .init(rawValue: dto.type?.rawValue ?? "EVENT"),
                      provider: dto.provider,
                      service: dto.service,
                      consumer: dto.consumer,
                      resource: dto.resource,
                      startTime: dto.startTime,
                      endTime: dto.endTime,
                      maxSeats: dto.maxSeats,
                      bookingId: dto.bookingId,
                      location: dto.location?.teleport,
                      createdBy: dto.createdBy,
                      createdTime: dto.createdTime,
                      updatedTime: dto.updatedTime)
  }
}

extension AnywhereSchedulingEngineModule.AppBrand {
  var map: AppBrand {
    switch self {
    case .Anytime: return .anytime
    case .YoCoBoard: return .yoco
    case .SetMore: return .setmore
    }
  }
}
