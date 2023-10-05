//
//  ContactDisplayable.swift
//  UltraCore
//
//  Created by Slam on 5/19/23.
//

import Foundation


protocol ContactDisplayable: Any {
    var phone: String { get }
    var userID: String { get }
    var displaName: String { get }
    var status: UserStatus { get }
    
    var image: UIImage? { get }
    var imagePath: String { get }
}

extension DBContact : ContactDisplayable {
    var status: UserStatus {
        return .with({
            $0.lastSeen = lastseen
            $0.userID = userID
            $0.status = statusEnum
        })
    }
    
    var statusEnum: UserStatusEnum {
        return UserStatusEnum.init(rawValue: self.statusValue) ?? .UNRECOGNIZED(statusValue)
    }
    
    var displaName: String { [firstName, lastName].joined(separator: " ") }
    
    var image: UIImage? { UIImage(data: toProto().photo.preview) }
    
    var imagePath: String { self.toProto().imagePath }
}

extension Contact: ContactDisplayable {
    var imagePath: String { "\(self.previewKey).\(self.previewExtension)" }
    
    var chatID: String {
        let id = AppSettingsImpl.shared.appStore.userID()

        return "p\(id >= self.userID ? id + self.userID : self.userID + id)"
    }
    
    var image: UIImage? { UIImage(data: photo.preview) }
    
    var displaName: String { [firstname, lastname].joined(separator: " ") }
}
