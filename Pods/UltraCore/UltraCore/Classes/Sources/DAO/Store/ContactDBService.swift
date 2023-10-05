//
//  ContactDBService.swift
//  UltraCore
//
//  Created by Slam on 5/4/23.
//
import RxSwift
import RealmSwift

class ContactDBService {
    fileprivate let userID: String
    
    init(userID: String) {
        self.userID = userID
    }
    
    func contacts() -> Observable<[Contact]> {
        return Observable.create { observer in
            let realm = Realm.myRealm()
            let contacts = realm.objects(DBContact.self)
            let notificationKey = contacts.observe(keyPaths: []) { changes in
                switch changes {
                case let .initial(collection):
                    observer.on(.next(collection.map({$0.toProto()})))
                case let .update(collection, _, _, _):
                    observer.on(.next(collection.map({$0.toProto()})))
                case let .error(error):
                    observer.on(.error(error))
                }
            }
            return Disposables.create {
                notificationKey.invalidate()
            }
        }
    }
    
    func contact(id: String) -> DBContact? {
        if let contact = Realm.myRealm().object(ofType: DBContact.self, forPrimaryKey: id) {
            return DBContact(value: contact)
        }
        return nil
    }
    
    func save( contact: DBContact) -> Single<Void> {
        return Single.create { completable in
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    realm.add(contact, update: .all)
                }
                completable(.success(()))
            } catch {
                completable(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func delete( contact: DBContact) -> Single<Void> {
        return Single.create { completable in
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    realm.delete(contact)
                }
                completable(.success(()))
            } catch {
                completable(.failure(error))
            }
            return Disposables.create()
        }
    }
}
