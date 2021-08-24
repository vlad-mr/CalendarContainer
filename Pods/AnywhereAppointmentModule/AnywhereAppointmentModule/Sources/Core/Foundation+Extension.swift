//
//  Foundation+Extension.swift
//  EventViewSDK
//
//  Created by Artem Grebinik on 10.08.2021.
//

import UIKit

func openLink(_ link: String) {
    
    guard let url = URL(string: link) else {
        return
    }
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:])
    }
}

func configure<T>(
    _ value: T,
    using closure: (inout T) throws -> Void
) rethrows -> T {
    var value = value
    try closure(&value)
    return value
}

extension String {
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
        
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

extension Array {
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension CGRect {
    
    func liesWithin(_ rect: CGRect) -> Bool {
        
        let result = minY >= rect.minY && maxY <= rect.maxY
        return result
    }
}

public extension Optional {
    /**
     *  Require this optional to contain a non-nil value
     *
     *  This method will either return the value that this optional contains, or trigger
     *  a `preconditionFailure` with an error message containing debug information.
     *
     *  - parameter hint: Optionally pass a hint that will get included in any error
     *                    message generated in case nil was found.
     *
     *  - return: The value this optional contains.
     */
    func require(hint hintExpression: @autoclosure () -> String? = nil,
                 file: StaticString = #file,
                 line: UInt = #line) -> Wrapped {
        guard let unwrapped = self else {
            var message = "Required value was nil in \(file), at line \(line)"
            
            if let hint = hintExpression() {
                message.append(". Debugging hint: \(hint)")
            }
            
            preconditionFailure(message)
        }
        
        return unwrapped
    }
}

extension Encodable {
    
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }

    ///To use it locally
    var toData: Data? {
        return try? PropertyListEncoder()
        .encode(self)
    }
}

extension Decodable {
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

extension Double {
    
    var inSeconds: Double {
        return self / 1000
    }
    
    var date: Date {
        return Date(milliseconds: Int(self))
    }
}
