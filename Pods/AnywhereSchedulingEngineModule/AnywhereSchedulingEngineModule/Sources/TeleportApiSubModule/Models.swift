//
//  Models.swift
//  AnywhereSchedulingEngineModule
//
//  Created by Artem Grebinik on 23.08.2021.
//

import Foundation

// MARK: - Welcome
public struct Meeting: Codable {
    var accountId: String?
    var brandId: String?
    var businessName: String?
    var ownerContactId: String?
    var startsAt: Int?
    var roomType: String?
    var hipaaCompliant: Bool?
    var appointmentId: String?
    var hostIds: [String]?
    var features: Features?
    
    enum CodingKeys: String, CodingKey {
        case accountId
        case brandId
        case businessName
        case ownerContactId
        case startsAt
        case roomType
        case hipaaCompliant
        case appointmentId
        case hostIds
        case features
    }
}

public struct MeetingApiResponse<Response: Codable>: Codable {
    public let status: String?
    public let message: String?
    public let data: Response?
}

// MARK: - DataClass
public struct MeetingDataDTO: Codable {
    var meetingUrl: String?
    var meetingId: String?
    
    enum CodingKeys: String, CodingKey {
        case meetingUrl
        case meetingId
    }
}

// MARK: - Features
public struct Features: Codable {
    var waitForHost, lockRoom, customization: Bool?
}
