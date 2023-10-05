//
//  DeleteConversationInteractor.swift
//  UltraCore
//
//  Created by Slam on 7/17/23.
//

import RxSwift

class DeleteConversationInteractor: UseCase<(Conversation, Bool), Void> {
    fileprivate let conversationService: ChatServiceClientProtocol
    fileprivate let conversationDBService: ConversationDBService
    
    init(conversationDBService: ConversationDBService,
         conversationService: ChatServiceClientProtocol){
        self.conversationService = conversationService
        self.conversationDBService = conversationDBService
    }
    
    override func executeSingle(params: (Conversation, Bool)) -> Single<Void> {
        return Single.create(subscribe: {[weak self] observer in
            guard let `self` = self else { return Disposables.create() }
            self.conversationService.delete(.with({
                $0.forEveryone = params.1
                $0.chatID = params.0.idintification
            }), callOptions: .default())
            .response
            .whenComplete({ result in
                switch result {
                case .success:
                    observer(.success(()))
                case let .failure(error):
                    observer(.failure(error))
                }

            })
            return Disposables.create()
        })
        .flatMap({ self.conversationDBService.delete(conversation: params.0.idintification) })
    }
}
