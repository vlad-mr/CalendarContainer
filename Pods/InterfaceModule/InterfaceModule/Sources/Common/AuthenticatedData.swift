//
//  AuthenticatedData.swift
//  InterfaceModule
//
//  Created by Vignesh on 22/07/21.
//

import Foundation

/// An object that denotes the type of Authentication.
///
/// This includes SignIn, SignUp, Calendar or Contact based on the context
public enum AuthenticationType {
    case signIn
    case signUp
    case calendar
    case contact
}

/// An object that helps identify the Mode of Authentication.
///
///  These modes include Social Logins (Microsoft, Apple, Google, etc) and the traditional Email Login.
public enum AuthenticationMode: String {
    case Microsoft
    case Google
    case Email
    case Apple
    case Facebook
}

/// A constructed data that contains information regarding the Authentication
public struct AuthenticatedData {
    public let authMode: AuthenticationMode
    public let authType: AuthenticationType
    public let authenticatedUser: AuthenticatedUser?
    public let socialTokens: AuthenticatedSocialToken?
    
    public init(authMode: AuthenticationMode,
                authType: AuthenticationType,
                authenticatedUser: AuthenticatedUser?,
                socialTokens: AuthenticatedSocialToken?) {
        self.authMode = authMode
        self.authType = authType
        self.authenticatedUser = authenticatedUser
        self.socialTokens = socialTokens
    }
}

/// An object containing information of the User who has been Authenticated
public struct AuthenticatedUser {
    public var givenName: String?
    public var familyName: String?
    public var email: String
    public var imageURL: String?
    // password
    
    public init(givenName: String?,
                familyName: String?,
                email: String,
                imageURL: String?) {
        self.givenName = givenName
        self.familyName = familyName
        self.email = email
        self.imageURL = imageURL
    }
}

/// An object containing the tokens related to the Social Login
public protocol AuthenticatedSocialToken {
    var accessToken: String { get set }
    var refreshToken: String? { get set }
    var authCode: String? { get set }
}
