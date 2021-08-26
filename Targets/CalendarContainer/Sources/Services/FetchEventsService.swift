//
//  FetchEventsService.swift
//  CalendarContainer
//
//  Created by Volodymyr Kravchenko on 24.08.2021.
//  Copyright © 2021 Anywhere. All rights reserved.
//

import Foundation
import PromiseKit

public final class FetchEventsService {
  public init() { }

  public func fetchEvents() -> Promise<[EventModel]> {
    return provider.fetchEventsTest()
  }

  private let provider = SchedulingEngineAdapter()
}
