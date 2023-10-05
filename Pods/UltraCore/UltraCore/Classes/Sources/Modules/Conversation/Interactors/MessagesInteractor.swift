//
//  MessagesInteractor.swift
//  UltraCore
//
//  Created by Slam on 6/27/23.
//

import RxSwift

class MessagesInteractor: UseCase<GetChatMessagesRequest, [Message]> {
    
    fileprivate let messageDBService: MessageDBService
    fileprivate let messageService: MessageServiceClientProtocol
    
    init(messageDBService: MessageDBService,
         messageService: MessageServiceClientProtocol) {
        self.messageService = messageService
        self.messageDBService = messageDBService
    }
    
    override func executeSingle(params: GetChatMessagesRequest) -> Single<[Message]> {
        return Single<[Message]>.create { [weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            self.messageService.getChatMessages(params, callOptions: .default())
                .response
                .whenComplete { result in
                    switch result {
                    case let .success(response):
                        observer(.success(response.messages))
                    case let .failure(error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }
        .flatMap({ [weak self] messages in
            guard let `self` = self else { throw NSError.selfIsNill }
            return self.messageDBService
                .save(messages: messages)
                .map({ _ in messages })
        })
    }
}
