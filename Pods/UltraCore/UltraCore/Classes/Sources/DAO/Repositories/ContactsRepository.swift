//
//  ContactsRepository.swift
//  UltraCore
//
//  Created by Slam on 4/24/23.
//
import Realm
import RealmSwift
import RxSwift
import RxDataSources

import Foundation

protocol ContactsRepository {
    func contacts() -> Observable<[Contact]>
    func contact(id: String) -> DBContact?
    func save(contact: DBContact) -> Single<Void>
    func delete(contact: DBContact) -> Single<Void>
}


class ContactsRepositoryImpl: ContactsRepository {

    fileprivate let contactDBService: ContactDBService
    
    init(contactDBService: ContactDBService) {
        self.contactDBService = contactDBService
    }
    
    func contacts() -> Observable<[Contact]> {
        return self.contactDBService.contacts()
    }
    
    func contact(id: String) -> DBContact?{
        return self.contactDBService.contact(id: id)
    }
    
    func save(contact: DBContact) -> Single<Void> {
        return self.contactDBService.save(contact: contact)
    }
    
    func delete(contact: DBContact) -> Single<Void> {
        return self.contactDBService.delete(contact: contact)
    }
}

extension Realm {
    static func myRealm() -> Realm {
        let realmURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("UltraCore.realm")

        let config = Realm.Configuration(fileURL: realmURL)

        do {
            let realm = try Realm(configuration: config)
            return realm
        } catch let error as NSError {
            print("Error opening realm: \(error.localizedDescription)")
            return try! Realm() // если ошибка, то создаем объект Realm с настройками по умолчанию
        }
    }
}
