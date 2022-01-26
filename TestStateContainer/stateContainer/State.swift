//
// Created by antony on 19.01.2018.
//

import Foundation
import Dispatch

public class State<Type> {
    let key: String
    fileprivate var _value: Type?
    fileprivate var locQueue: DispatchQueue

    init(_ defaultValue: Type?, key: String) {
        self._value = defaultValue
        self.key = key
//        self.locQueue = DispatchQueue(__label: "com.telemed.\(key)", attributes: .concurrent)
        self.locQueue = DispatchQueue(label: "com.telemed.\(key)")
    }

    func didModify() {
        log.info("State for key \(key) modified \(value)")
    }
}

extension State {
    var value: Type? {
        var retValue: Type!
        self.locQueue.sync {
            retValue = self._value
        }
        return retValue
    }

    func modify(_ newValue: Type) {
        self.locQueue.async(flags: .barrier) {
            self._value = newValue
        }
        self.didModify()
    }

    func clear() {
        self.locQueue.async(flags: .barrier) {
            self._value = nil
        }
        self.didModify()
    }

    static func ~> <Type>(lhs: State<Type>, rhs: Type) {
        lhs.modify(rhs)
    }
}
