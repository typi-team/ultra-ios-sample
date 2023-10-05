//
//  DBContact.swift
//  _NIODataStructures
//
//  Created by Slam on 4/24/23.
//

import RealmSwift

class DBContact: Object {
    
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var phone = ""
    @objc dynamic var userID = ""
    @objc dynamic var lastseen: Int64 = 0
    @objc dynamic var statusValue: Int = 0
    
    @objc dynamic var photo: DBPhoto?
    
    convenience init(from contact: Contact) {
        self.init()
        self.phone = contact.phone
        self.userID = contact.userID
        self.lastName = contact.lastname
        self.firstName = contact.firstname
        self.photo = .init(from: contact.photo)
        self.lastseen = contact.status.lastSeen
        self.statusValue = contact.status.status.rawValue
    }
    
    override static func primaryKey() -> String? {
        return "userID"
    }
    
    func toProto() -> Contact {
        return .with({
            $0.firstname = firstName
            $0.lastname = lastName
            $0.phone = phone
            $0.userID = userID
//            $0.photo = nil
            $0.status = .with({ stat in
                stat.userID = userID
                stat.status = statusEnum
                stat.lastSeen = lastseen
            })
        })
    }
}
