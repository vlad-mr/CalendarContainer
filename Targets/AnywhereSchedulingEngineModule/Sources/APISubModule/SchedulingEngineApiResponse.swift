//
//  AnytimeApiResponse.swift
//  AnytimeAPI
//
//  Created by Vignesh on 04/12/19.
//  Copyright © 2019 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation

public struct SchedulingEngineApiResponse<Response: Codable>: Codable {
    public let status: Bool
    public let data: Response?
    public let error: String?
    public let msg: String?
}

public enum APIError: String, Error {
    case noNetwork = "No Internet Connection", invalidData = "Invalid Data", apiFailed = "API Failed", unknown = "Unknown"
    case missingData

    func getErrorType(forString string: String) -> APIError {
        guard let errorType = APIError(rawValue: string) else {
            return .unknown
        }
        return errorType
    }
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid Data from API"
        case .missingData:
            return "Missing Data in API"
        default:
            return "Something went wrong"
        }
    }
}
