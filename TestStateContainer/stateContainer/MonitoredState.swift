//
// Created by antony on 22.01.2018.
//

import Foundation
import Dispatch

public class MonitoredState<Type>: State<Type> {

    // weak reference to all stateListeners
    fileprivate let listeners: NSHashTable<AnyObject>

    fileprivate let listenersLockQueue: DispatchQueue

    override init(_ defaultValue: Type?, key: String) {
        self.listeners = NSHashTable<AnyObject>.weakObjects()
        self.listenersLockQueue = DispatchQueue(label: "com.telemed.listeners.\(key)")
        super.init(defaultValue, key:key)
    }

    // all listeners associated with receiver
    var allListeners: [StateListener] {
        var retValue: [StateListener] = []
        self.listenersLockQueue.sync {
            // remove all nils
            retValue = self.listeners.allObjects.map({$0 as? StateListener}).compactMap({$0})
        }
        return retValue
    }

    // notify all listeners that something changed
    override func didModify() {
        super.didModify()

        let allListeners = self.allListeners
        let state = self
        for l in allListeners {
            l.stateListenerQueue.async {
                l.stateModified(state)
            }
        }
    }
}

extension MonitoredState {
    public func attach(listener: StateListener) {
        self.listenersLockQueue.sync {
            self.listeners.add(listener as AnyObject)
        }
    }
}
