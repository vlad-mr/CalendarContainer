//
//  Extensions.swift
//  AnywhereDataStack
//
//  Created by Volodymyr Kravchenko on 13.07.2021.
//

import Foundation
import SwiftDate

public class Utilities {
  public class func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
}

public extension String {
  var isNotEmpty: Bool {
    return !isEmpty
  }
}

public extension Encodable {

  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }

  ///To use it locally
  var toData: Data? {
    return try? PropertyListEncoder()
      .encode(self)
  }
  
  var toJsonData: Data? {
    return try? JSONEncoder().encode(self)
  }
}

public extension Decodable {
  static func decode(fromJsonData data: Data) -> Self? {
    let decoder = JSONDecoder()
    guard let object = try? decoder.decode(self.self, from: data) else {
      return nil
    }
    return object
  }

  ///To use it locally
  static func decode(fromPlistData data: Data) -> Self? {
    return try? PropertyListDecoder().decode(self.self, from: data)
  }

  static func decode(from jsonString: String) -> Self? {
    guard let jsonData = jsonString.data(using: .utf8) else {
      return nil
    }
    return Self.decode(fromJsonData: jsonData)
  }
}

public extension Decodable {
  static func initialize(withData data: Data) -> Self? {
    let decoder = JSONDecoder()
    guard let object = try? decoder.decode(self.self, from: data) else {
      return nil
    }
    return object
  }

  static func initialize(withDict dict: [String: Any]) -> Self? {

    guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
      return nil
    }
    return initialize(withData: data)
  }
    
    static func initialize(fromJsonString string: String) -> Self? {

        guard let data = try? JSONSerialization.data(withJSONObject: string, options: .fragmentsAllowed) else {
        return nil
      }
      return initialize(withData: data)
    }
}

public extension Double {

  var inSeconds: Double {
    return self / 1000
  }

  var date: Date {
    return Date(milliseconds: Int(self))
  }
}

public extension Date {
  var milliSec: Double {
    return Double(milliSeconds)
  }

  var milliSeconds: Int {
    return Int(self.timeIntervalSince1970 * 1000)
  }

  var toMinutes: Int {
    return (self.hour * 60) + self.minute
  }
}

public extension Int {

  var toDate: Date {
    return Date(milliseconds: self)
  }

  var nsNumber: NSNumber {
    return NSNumber(value: self)
  }
}
