//
//  EventModel.swift
//  CalendarContainer
//
//  Created by Volodymyr Kravchenko on 24.08.2021.
//  Copyright © 2021 Anywhere. All rights reserved.
//

import Foundation

public struct EventModel {
  public let id: String
  public let calendar: String
  public let merchant: String
  public var brand: AppBrand
  public var type: FetchEventType?

  public var provider: [String]
  public let service: [String]
  public var consumer: [String]
  public let resource: [String]

  public var startDateTime: String?
  public var endDateTime: String?

  public var startTime: Double // milliseconds value for start and end time
  public var endTime: Double // milliseconds value for start and end time
  public let maxSeats: Int
  public var cost = 0
  public var isExternal: Bool = false
  public var isDeleted: Bool = false
  public var rRule: String?
  public var paymentStatus: String?
  public var label: String?
  public let bookingId: String?     // for user reference
  public var source: String?
  public var parentId: String?
  public var title: String? = ""

  public let location: String?

  public var notes: String?
  public let createdBy: String? // The user who created the event
  public let createdTime: Double?
  public let updatedTime: Double?
}

public enum AppBrand {
  case anytime
  case yoco
  case setmore
  case id(String)
}

public enum FetchEventType: String {
  case appointment = "APPOINTMENT"
  case event = "EVENT"
  case group = "GROUP"
  case offhours = "OFFHOURS"
  case session = "SESSION"
  case reminder = "REMINDER"
}
