//
//  AppError.swift
//  Anytime
//
//  Created by Vignesh on 04/12/19.
//  Copyright © 2019 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation

//TODO: Have to check and update
enum AppError: String {
    case apiFailed
    case userNotFound
    case noInternet
    case unknown
    case slotNotAvailable = "slot_not_available"
}

extension AppError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .noInternet:
            return NSLocalizedString("Poor or No Internet Connection", comment: "")
        case .slotNotAvailable:
            return NSLocalizedString("Slot not available", comment: "")
        case .userNotFound:
            return NSLocalizedString("Invalid User. Please try again", comment: "")
        default:
            return NSLocalizedString("Something went wrong. Please try again", comment: "")
        }
    }
}
