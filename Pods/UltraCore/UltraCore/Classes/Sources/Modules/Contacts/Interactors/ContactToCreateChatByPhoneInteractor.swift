//
//  ContactToCreateChatByPhoneInteractor.swift
//  UltraCore
//
//  Created by Slam on 9/28/23.
//
import RxSwift
import Foundation

class ContactToCreateChatByPhoneInteractor: UseCase<IContact, CreateChatByPhoneResponse> {
    final let integrateService: IntegrationServiceClientProtocol
    
     init(integrateService: IntegrationServiceClientProtocol) {
         self.integrateService = integrateService
    }
    
    override func executeSingle(params: IContact) -> Single<CreateChatByPhoneResponse> {
        Single.create(subscribe: { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }

            self.integrateService.createChatByPhone(.with({
                $0.firstname = params.firstname
                $0.phone = params.phone
            }))
            .response
            .whenComplete({ result in
                switch result {
                case let .success(response):
                    observer(.success(response))
                case let .failure(error):
                    observer(.failure(error))
                }

            })

            return Disposables.create()
        })
    }
}
