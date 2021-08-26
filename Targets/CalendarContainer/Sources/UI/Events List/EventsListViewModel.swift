//
//  EventsListViewModel.swift
//  CalendarContainer
//
//  Created by Volodymyr Kravchenko on 24.08.2021.
//  Copyright © 2021 Anywhere. All rights reserved.
//

import PromiseKit

public final class EventsListViewModel {
  let service = FetchEventsService()
  lazy var events = service.fetchEvents()  
}
