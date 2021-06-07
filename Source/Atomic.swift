//
//  Atomic.swift
//  StubPlay
//
//  Created by Yoo-Jin Lee on 25/5/21.
//  Copyright © 2021 Mokten Pty Ltd. All rights reserved.
//

import Foundation

@propertyWrapper
final class Atomic<Value> {
    private let queue: DispatchQueue
    private var value: Value

    var wrappedValue: Value {
        get { return queue.sync { self.value } }
        set { queue.async(flags: .barrier) { self.value = newValue } }
    }

    convenience init(wrappedValue: Value) {
        self.init(wrappedValue)
    }

    init(_ value: Value, queue: DispatchQueue = DispatchQueue(label: "Atomic", qos: .default)) {
        self.value = value
        self.queue = queue
    }

    func mutate(_ transform: (inout Value) -> Void) {
        return queue.sync {
            transform(&value)
        }
    }
}
