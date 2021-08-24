//
//  SchedulingServiceBuilder.swift
//  ScheduleSDK
//
//  Created by Artem Grebinik on 26.07.2021.
//

import Foundation

public enum SchedulingServiceBuilder {
    
    public static func buildProvider(url: URL, token: String, accountTimezoneId: String = "") -> SheduleEventServiceProviderProtocol {
        Configuration.current = .init(baseURL: url, accessToken: token, accountTimezoneId: accountTimezoneId)
        
        let apiService = EventsApiService()
        let localStorageService = AnywhereDataStackBuilder.buildProvider()
        
        let service = SheduleEventService(api: apiService,
                                          dataStackProvider: localStorageService)
        
        return SheduleEventServiceProvider(service: service)
  }

  public static func applicationDidFinishLaunching() {
      // guard userSettings.isUserLoggedIn else { return }
      FetchedDatesInfo.shared.loadFetchedDates()
  }

  public static func applicationDidEnterBackground() {
      // guard userSettings.isUserLoggedIn else { return }
      FetchedDatesInfo.shared.saveFetchedDates()
  }

  public static func applicationWillTerminate() {
      // guard userSettings.isUserLoggedIn else { return }
      FetchedDatesInfo.shared.saveFetchedDates()
  }

  public static func updateAccessToken(_ accessToken: String) {
    Configuration.current.accessToken = accessToken
  }
}

struct Configuration {
    var baseURL: URL = URL(string: "google.com")!
    var accessToken: String? = ""
    let isLiveEnvironment: Bool = false
    var accountTimezoneId: String = ""
    static var current: Configuration = Configuration()
}
    
