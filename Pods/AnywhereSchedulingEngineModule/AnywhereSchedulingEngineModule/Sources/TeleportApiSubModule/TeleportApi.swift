//
//  TeleportApi.swift
//  AnywhereSchedulingEngineModule
//
//  Created by Artem Grebinik on 16.08.2021.
//

import Foundation
import Moya
import PromiseKit

enum TeleportApi {
    case createMeeting(_ param: [String: Any])
}

extension TeleportApi: TargetType {
    
    var baseURL: URL { TeleportApiConfiguration.current.baseURL }
    
    var path: String {
        switch self {
        case .createMeeting:
            return "/meeting"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createMeeting:
            return .post
        }
    }
    
    var sampleData: Data {
        switch self {
        case .createMeeting(_):
             let jsonData = MeetingApiResponse<MeetingDataDTO>(
                status: "success",
                message: "success message",
                data: MeetingDataDTO(meetingUrl: UUID().uuidString,
                                     meetingId: UUID().uuidString))
             
             return jsonData.toJsonData!
        }
    }
    
    var parameters: [String: Any] {
        return [:]
    }
    
    var task: Task {
        switch self {
        case .createMeeting(let param):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        default:
            guard let accessToken = TeleportApiConfiguration.current.accessToken else { return nil }
            return ["Authorization": "Bearer \(accessToken)"]
        }
    }
}

public protocol TeleportApiProtocol {
    func createMeeting(withParameters params: [String: Any]) -> Promise<Data>
}

class TeleportApiService: BaseApiProvider, TeleportApiProtocol {
    private(set) var provider: MoyaProvider<TeleportApi>
    
    init(provider: MoyaProvider<TeleportApi> = MoyaProvider<TeleportApi>()) {
        self.provider = provider
    }
    
    func createMeeting(withParameters params: [String: Any]) -> Promise<Data> {
        return Promise<Data> { promise in
            provider.request(.createMeeting(params)) {
                let response = self.handleResponse($0)
                guard let data = self.handleResponse($0).data else {
                    promise.reject(response.error ?? APIError.unknown)
                    return
                }
                promise.fulfill(data)
            }
        }
    }
}

