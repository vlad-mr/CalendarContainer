//
//  TeleportApiInterface.swift
//  AnywhereSchedulingEngineModule
//
//  Created by Artem Grebinik on 23.08.2021.
//

import Foundation

public enum TeleportApiBuilder {
    
    public static func buildService() -> MeetingServiceProtocol {
        let service = TeleportApiService()
        return MeetingService(api: service)
    }
    
    public static func configurePlugIn(withURL url: URL, accessToken: String) {
        TeleportApiConfiguration.current.baseURL = url
        TeleportApiConfiguration.current.accessToken = accessToken
    }
}

public struct TeleportApiConfiguration {
    var baseURL: URL = URL(string: "https://staging.teleport.video/v1")!
    var accessToken: String? = ""
    let isLiveEnvironment: Bool = false
    static var current: TeleportApiConfiguration = TeleportApiConfiguration()
}
