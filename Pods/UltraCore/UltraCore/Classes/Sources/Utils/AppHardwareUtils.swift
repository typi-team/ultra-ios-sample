//
//  AppHardwareUtils.swift
//  UltraCore
//
//  Created by Slam on 5/31/23.
//
import Contacts
import Foundation

class AppHardwareUtils {
    static func checkPermissons() -> Bool {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized, .notDetermined: return true
        default: return false
        }
    }
}
