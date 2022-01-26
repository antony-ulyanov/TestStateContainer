//
// Created by antony on 19.01.2018.
//

import Foundation

struct AppState {
    public static let isAppStarted = MonitoredState<Bool>.init(false, key: "isAppStarted")
    public static let isFirstLaunch = UserDefaultsState<Bool>.init(true, key: "isFirstLaunch")
    public static let isLoggedIn = UserDefaultsState<Bool>.init(false, key: "isLoggedIn")

    static func clearState() {
        FamilyState.clearState()        
    }
}
