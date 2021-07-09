//
//  JSONCodingKey.swift
//  StubPlay
//
// https://stackoverflow.com/questions/44603248/how-to-decode-a-property-with-type-of-json-dictionary-in-swift-45-decodable-pr
//
//  Created by Yoo-Jin Lee on 26/6/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

/*
 
 Examples:
 let dictionary: [String: Any] = try container.decode([String: Any].self, forKey: key)
 
 let array: [Any] = try container.decode([Any].self, forKey: key)
 
 let items: [[String: Any]] = try container.decode(Array<Any>.self, forKey: .items) as! [[String: Any]]
 
 If you simply want to convert an entire file to a dictionary, you are better off sticking with api from JSONSerialization as I have not figured out a way to extend JSONDecoder itself to directly decode a dictionary.
 
 guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
   // appropriate error handling
   return
 }
 */

struct JSONCodingKey: CodingKey {
    var stringValue: String
    var hashableValue: AnyHashable
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.hashableValue = stringValue
    }

    init?(hashableValue: AnyHashable) {
        self.hashableValue = hashableValue
        self.stringValue = "\(hashableValue)"
    }

    init?(intValue: Int) {
        self.init(hashableValue: "\(intValue)")
        self.intValue = intValue
    }
}

extension KeyedEncodingContainerProtocol where Key == JSONCodingKey {
    mutating func encodeJSONDictionary(_ value: [AnyHashable: Any]) throws {
        try value.forEach({ (key, value) in
            guard let key = JSONCodingKey(hashableValue: key) else { return }
            switch value {
            case let value as Bool:
                try encode(value, forKey: key)
            case let value as Int:
                try encode(value, forKey: key)
            case let value as String:
                try encode(value, forKey: key)
            case let value as Double:
                try encode(value, forKey: key)
            case let value as [AnyHashable: Any]:
                try encode(value, forKey: key)
            case let value as Array<Any>:
                try encode(value, forKey: key)
            case Optional<Any>.none:
                try encodeNil(forKey: key)
            default:
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + [key], debugDescription: "Invalid JSON value"))
            }
        })
    }
}

extension KeyedEncodingContainerProtocol  {
//    mutating func encode(_ value: [AnyHashable: Any], forKey key: Key) throws {
//        var container = self.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
//        try container.encodeJSONDictionary(value)
//    }
    
    mutating func encode(_ value: [AnyHashable: Any]?, forKey key: Key) throws {
        guard let value = value else { return }
        var container = self.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
        try container.encodeJSONDictionary(value)
    }

//    mutating func encodeIfPresent(_ value: [AnyHashable: Any], forKey key: Key) throws {
//        try encode(value, forKey: key)
//    }
    
    mutating func encodeIfPresent(_ value: [AnyHashable: Any]?, forKey key: Key) throws {
        if let value = value {
            try encode(value, forKey: key)
        }
    }

    mutating func encode(_ value: Array<Any>, forKey key: Key) throws {
        var container = self.nestedUnkeyedContainer(forKey: key)
        try container.encodeJSONArray(value)
    }

    mutating func encodeIfPresent(_ value: Array<Any>?, forKey key: Key) throws {
        if let value = value {
            try encode(value, forKey: key)
        }
    }
}

extension UnkeyedEncodingContainer {
    
//    mutating func encode(_ value: [AnyHashable: Any]) throws {
//
//    }
//    mutating func encode(_ value: [AnyHashable: Any], forKey key: JSONCodingKey) throws {
//        var container = self.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
//        try container.encodeJSONDictionary(value)
//    }
     
    
//    public mutating func encode(_ value: T, forKey key: KeyedEncodingContainer<K>.Key) throws where T : Encodable {
//
//    }
}

extension UnkeyedEncodingContainer {
    mutating func encodeJSONArray(_ value: Array<Any>) throws {
        try value.enumerated().forEach({ (index, value) in
            switch value {
            case let value as Bool:
                try encode(value)
            case let value as Int:
                try encode(value)
            case let value as String:
                try encode(value)
            case let value as Double:
                try encode(value)
            case let value as [AnyHashable: Any]:
                try encode(value)
            case let value as Array<Any>:
                try encode(value)
            case Optional<Any>.none:
                try encodeNil()
            default:
                let keys = JSONCodingKey(intValue: index).map({ [ $0 ] }) ?? []
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + keys, debugDescription: "Invalid JSON value"))
            }
        })
    }

    mutating func encode(_ value: [AnyHashable: Any]?) throws {
        guard let value = value else { return }
        var container = self.nestedUnkeyedContainer()
        try container.encodeJSONDictionary(value)
    }
    
    mutating func encode(_ value: [AnyHashable: Any]) throws {
        var container = self.nestedUnkeyedContainer()
        try container.encodeJSONDictionary(value)
    }
    
    mutating func encode(_ value: Array<Any>) throws {
        var container = self.nestedUnkeyedContainer()
        try container.encodeJSONArray(value)
    }

    mutating func encodeJSONDictionary(_ value: [AnyHashable: Any]) throws {
        var nestedContainer = self.nestedContainer(keyedBy: JSONCodingKey.self)
        try nestedContainer.encodeJSONDictionary(value)
    }
}

extension KeyedDecodingContainer {
    func decode(_ type: [AnyHashable: Any].Type, forKey key: K) throws -> [AnyHashable: Any] {
        let container = try self.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: [AnyHashable: Any].Type, forKey key: K) throws -> [AnyHashable: Any] {
        guard contains(key) else {
            return [:]
        }
        guard try decodeNil(forKey: key) == false else {
            return [:]
        }
        return try decode(type, forKey: key)
    }

    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }

    func decode(_ type: [AnyHashable: Any].Type) throws -> [AnyHashable: Any] {
        var dictionary = [AnyHashable: Any]()

        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let hashableValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = hashableValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode([AnyHashable: Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        
        return dictionary
    }
    
    func decoded(_ type: [AnyHashable: Any].Type) throws -> [AnyHashable: Any] {
        var dictionary = [AnyHashable: Any]()

        for key in allKeys {
            let keyValue: AnyHashable = {
                guard let jsonKey = key as? JSONCodingKey else {
                    return key.stringValue
                }
                return jsonKey.hashableValue
            }()
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[keyValue] = boolValue
            } else if let hashableValue = try? decode(String.self, forKey: key) {
                dictionary[keyValue] = hashableValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[keyValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[keyValue] = doubleValue
            } else if let nestedDictionary = try? decode([AnyHashable: Any].self, forKey: key) {
                dictionary[keyValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[keyValue] = nestedArray
            }
        }
        
        return dictionary
    }
}

extension UnkeyedDecodingContainer {

    mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            // See if the current value in the JSON array is `null` first and prevent infite recursion with nested arrays.
            if try decodeNil() {
                continue
            } else if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode([AnyHashable: Any].self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self) {
                array.append(nestedArray)
            }
        }
        return array
    }

    mutating func decode(_ type: [AnyHashable: Any].Type) throws -> [AnyHashable: Any] {
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKey.self)
        return try nestedContainer.decode(type)
    }
}
