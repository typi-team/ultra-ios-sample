//
//  SendMoneyMessageInteractor.swift
//  UltraCore
//
//  Created by Slam on 7/4/23.
//

import RxSwift

class SendMoneyMessageInteractor: UseCase<Int, Int> {
    fileprivate let messageService: MessageServiceClientProtocol
    
    init(messageService: MessageServiceClientProtocol) {
        self.messageService = messageService
    }
    
    override func executeSingle(params: Int) -> Single<Int> {
        return Single.create(subscribe: {[weak self] observer in
            guard let `self` = self else { return Disposables.create()}
            
            return Disposables.create()
        })
    }
}
