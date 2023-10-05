//
//  AppSettingsStore.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import Foundation

protocol AppSettingsStore {
    func token() -> String
    func userID() -> String
    func store(token: String)
    func store(userID: String)
    func store(last state: Int64)
    
    var lastState: Int64 { get }
    var isAuthed: Bool { get }
    var ssid: String { get set }
}

class AppSettingsStoreImpl {
    fileprivate let kToken = "kToken"
    fileprivate let kSID = "kSSID"
    fileprivate let kUserID = "kUserID"
    fileprivate let kLastState = "kLastState"
    fileprivate let userDefault = UserDefaults(suiteName: "com.ultaCore.messenger")
    
    var ssid: String {
        get {
            guard let sid = userDefault?.string(forKey: kSID) else {
                fatalError("don't call this methode without value")
            }
            return sid
        }
        
        set {
            userDefault?.set(newValue, forKey: kSID)
        }
    }
}

extension AppSettingsStoreImpl: AppSettingsStore {
    func store(last state: Int64) {
        self.userDefault?.set(state, forKey: kLastState)
    }
    
    var lastState: Int64 {
        return (self.userDefault?.value(forKey: kLastState) as? Int64) ?? 0
    }
    
    func userID() -> String {
        guard let token = self.userDefault?.string(forKey: kUserID) else {
            fatalError("call store(userID:) before call this function")
        }
        return token
    }
    
    func store(userID: String) {
        self.userDefault?.set(userID, forKey: kUserID)
    }
    
    
    var isAuthed: Bool { self.userDefault?.string(forKey: kToken) != nil }
    
    func store(token: String) {
        self.userDefault?.set(token, forKey: kToken)
    }
    
    func token() -> String {
        guard let token = self.userDefault?.string(forKey: kToken) else {
            fatalError("call store(token:) before call this function")
        }
        return token
    }
}
