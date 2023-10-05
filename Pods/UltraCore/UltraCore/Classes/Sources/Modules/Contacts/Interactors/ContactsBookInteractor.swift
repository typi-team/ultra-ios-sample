//
//  ContactsBookInteractor.swift
//  UltraCore
//
//  Created by Slam on 4/21/23.
//

import RxSwift
import Contacts
import Foundation

class ContactsBookInteractor: UseCase<Void, ContactsBookInteractor.Contacts> {

    override func executeSingle(params: Void) -> Single<Contacts> {
        return Single.create { [weak self] observer -> Disposable in

            guard let `self` = self else { return Disposables.create() }
            let store = CNContactStore()
            self.checkPermissons(contact: store) { granted, error in
                if granted {
                    do {
                        observer(.success(.authorized(contacts: try self.contacts(contact: store))))
                    } catch let exception {
                        observer(.failure(exception))
                    }
                } else if let error = error {
                    observer(.failure(error))
                } else {
                    observer(.success(.denied))
                }
            }
            return Disposables.create()
        }
    }
}

private extension ContactsBookInteractor {
    
    func contacts(contact store: CNContactStore) throws -> [Contact] {
        var contacts: [Contact] = []
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])

        try store.enumerateContacts(with: request) { contact, stop in
            contact.phoneNumbers.forEach { value in
                var temp = Contact()
                temp.firstname = contact.givenName
                temp.lastname = contact.familyName
                temp.phone = value.value.stringValue.trimNumber
                
                if temp.phone.starts(with: "87"), let range = temp.phone.range(of: "87") {
                    temp.phone = temp.phone.replacingCharacters(in: range, with: "+77")
                }
                
                contacts.append(temp)
            }
        }
        return contacts
    }

    func checkPermissons(contact store: CNContactStore, completion: @escaping (Bool, Error?) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completion(true, nil)
        case .denied:
            completion(false, nil)
        case .notDetermined:
            store.requestAccess(for: .contacts, completionHandler: completion)
        case .restricted:
            completion(false, nil)
        @unknown default:
            completion(false, nil)
        }
    }
}

extension ContactsBookInteractor {
    
    enum Contacts {
        case denied
        case authorized(contacts: [Contact])
        
        var contacts: [Contact] {
            switch self {
            case .authorized(contacts: let data): return data
            case .denied: return []
            }
        }
    }
}

extension String {
    var trimNumber: String {
        return trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "[^+\\d]", with: "", options: .regularExpression, range: nil)
    }
}
