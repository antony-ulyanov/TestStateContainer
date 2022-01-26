//
// Created by antony on 22.01.2018.
//

import Foundation
import Gloss

public class UserDefaultsState<Type>: MonitoredState<Type> {
    // Loads existing value from `UserDefaults.standard` if it exists, otherwise falls back to the `defaultValue`.
//    public override init(_ defaultValue: Type, key: String) {
//        let existingValue = UserDefaults.standard.object(forKey: key)
//        if let existing = existingValue as? Type {
//            log.info("Loaded \(key) from UserDefaults")
//            super.init(existing, key: key)
//        } else if let data = existingValue as? Data, let decoded = NSKeyedUnarchiver.unarchiveObject(with: data) as? Type {
//            log.info("Loaded \(key) from UserDefaults")
//            super.init(decoded, key: key)
//        } else {
//            super.init(defaultValue, key: key)
//        }
//    }

    public override init(_ defaultValue: Type?, key: String) {
        let existingValue = UserDefaults.standard.object(forKey: key)
        if let existing = existingValue as? Type {
            log.info("Loaded \(key) from UserDefaults value = \(existing)")
            super.init(existing, key: key)
        } else if let data = existingValue as? Data, let decoded = NSKeyedUnarchiver.unarchiveObject(with: data) as? Type {
            log.info("Loaded \(key) from UserDefaults value = \(decoded)")
            super.init(decoded, key: key)
        } else {
            super.init(defaultValue, key: key)
        }
    }

    // Persists any changes to `UserDefaults.standard`.
    public override func didModify() {
        super.didModify()

        let val = self.value
        if let val = val as? OptionalType, val.isNil {
            UserDefaults.standard.removeObject(forKey: self.key)
            log.info("Removed \(self.key) from UserDefaults")
        } else if let val = val as? NSCoding {
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: val), forKey: self.key)
            log.info("Saved \(self.key) to UserDefaults")
        } else {
            UserDefaults.standard.set(val, forKey: self.key)
            log.info("Saved \(self.key) to UserDefaults")
        }

        UserDefaults.standard.synchronize()
    }
}

protocol OptionalType {

    /// Whether the receiver is `nil`.
    var isNil: Bool { get }
}

extension Optional : OptionalType {

    public var isNil: Bool {
        return self == nil
    }
}