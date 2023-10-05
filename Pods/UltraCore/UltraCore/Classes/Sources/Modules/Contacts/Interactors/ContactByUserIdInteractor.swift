//
//  ContactByUserIdInteractor.swift
//  UltraCore
//
//  Created by Slam on 5/4/23.
//
import RxSwift
import Foundation

class ContactByUserIdInteractor: UseCase<String, Contact> {
    fileprivate let contactsService: ContactServiceClientProtocol
    
    
    init(contactsService: ContactServiceClientProtocol) {
        self.contactsService = contactsService
    }
        
    override func executeSingle(params: String) -> Single<Contact> {
        return Single.create { [weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            let requestParam = ContactByUserIdRequest.with({ $0.userID = params })
            self.contactsService.getContactByUserId(requestParam, callOptions: .default())
                .response
                .whenComplete { result in
                    switch result {
                    case let .success(userByContact):
                        if userByContact.hasUser {
                            observer(.success(.with({
                                $0.userID = userByContact.user.id
                                $0.lastname = userByContact.user.lastname
                                $0.firstname = userByContact.user.firstname
                                $0.phone = userByContact.user.phone
                                $0.photo = userByContact.user.photo
                            })))
                        } else if userByContact.hasContact {
                            observer(.success(.with({
                                $0.userID = userByContact.contact.userID
                                $0.lastname = userByContact.contact.lastname
                                $0.firstname = userByContact.contact.firstname
                                $0.phone = userByContact.contact.phone
                                $0.photo = userByContact.contact.photo
                            })))
                        } else {
                            observer(.failure(NSError.objectsIsNill))
                        }
                    case let .failure(error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}
