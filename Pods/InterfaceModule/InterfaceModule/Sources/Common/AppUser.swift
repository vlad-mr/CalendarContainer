//
//  AppUser.swift
//  InterfaceModule
//
//  Created by Vignesh on 23/07/21.
//

import Foundation

// This can be used to get appbased objects using Codable ease
public protocol AppUser: Codable {
    var id: String { get set }
    var firstName: String? { get set }
    var lastName: String? { get set }
    var emailID: String { get set }
    var avatarURL: URL? { get set }
    var accountID: String? { get set }
    
}
