//
//  MeetingService.swift
//  AnywhereSchedulingEngineModule
//
//  Created by Artem Grebinik on 23.08.2021.
//

import Foundation
import PromiseKit

public protocol MeetingServiceProtocol {
    func createMeeting(withParameters params: [String: Any]) -> Promise<MeetingDataDTO>
}

public final class MeetingService: MeetingServiceProtocol {
    
    let api: TeleportApiProtocol
    
    init(api: TeleportApiProtocol) { self.api = api }
    
    public func createMeeting(withParameters params: [String: Any]) -> Promise<MeetingDataDTO> {
        return Promise<MeetingDataDTO> { promise in
            firstly {
                self.api.createMeeting(withParameters: params)
            }.compactMap {
                MeetingApiResponse<MeetingDataDTO>.decode(fromJsonData: $0)
            }.then {
                self.validateResponse($0)
            }.done { meeting in
                Logger.info("Create event successful and saved in core data pod=)")
                promise.fulfill(meeting)
            }.catch {
                promise.reject($0)
            }
        }
    }
    
    private func validateResponse(_ response: MeetingApiResponse<MeetingDataDTO>) -> Promise<MeetingDataDTO> {
        return Promise<MeetingDataDTO> { promise in
            guard let meetingData = response.data else {
                if let status = response.status, status != "success" {
                    promise.reject(AppError.apiFailed)
                }
                return
            }
            promise.fulfill(meetingData)
        }
    }
}
