//
//  RetrieveContactStatusesInteractor.swift
//  UltraCore
//
//  Created by Slam on 6/20/23.
//

import RxSwift

class RetrieveContactStatusesInteractor: UseCase<Void, Void> {
    final let appStore: AppSettingsStore
    final let contactDBService: ContactDBService
    final let contactService: ContactServiceClientProtocol
    
     init(appStore: AppSettingsStore,
          contactDBService: ContactDBService,
          contactService: ContactServiceClientProtocol) {
         self.appStore = appStore
         self.contactService = contactService
         self.contactDBService = contactDBService
    }
    
    override func execute(params: Void) -> Observable<Void> {
        return Single<GetStatusesResponse>
            .create { [weak self] observer -> Disposable in
                guard let `self` = self else { return Disposables.create() }
                self.contactService.getStatuses(.init(), callOptions: .default())
                    .response
                    .whenComplete { result in
                        switch result {
                        case let .success(response):
                            observer(.success(response))
                        case let .failure(error):
                            observer(.failure(error))
                        }
                    }

                return Disposables.create()
            }
            .asObservable()
            .flatMap { user -> Observable<Void> in
                
                return Observable<UserStatus>
                    .from(user.statuses)
                    .flatMap { userStatus -> Single<Void> in
                        if var contact = self.contactDBService.contact(id: userStatus.userID)?.toProto() {
                            contact.status = userStatus
                            fatalError()
//                            return self.contactDBService.save(contact: DBContact(from: contact, chatId: ))
                        } else {
                            return Single.just(())
                        }
                    }
            }
    }

}
