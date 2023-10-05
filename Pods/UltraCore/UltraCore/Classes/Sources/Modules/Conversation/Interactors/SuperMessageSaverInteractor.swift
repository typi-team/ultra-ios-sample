//
//  SuperMessageSaverInteractor.swift
//  UltraCore
//
//  Created by Slam on 7/1/23.
//
import RxSwift
import Foundation

typealias MessageData = [AnyHashable: Any]

class SuperMessageSaverInteractor: UseCase<MessageData, Conversation?> {
    
    fileprivate let appStore: AppSettingsStore
    fileprivate let messageDBService: MessageDBService
    fileprivate let messageService: MessageServiceClientProtocol
    
    fileprivate let contactDBService: ContactDBService
    fileprivate let contactsService: ContactServiceClientProtocol
    
    fileprivate let conversationDBService: ConversationDBService
    
    
    fileprivate let contactByUserIdInteractor: ContactByUserIdInteractor
    
    init(appStore: AppSettingsStore,
         contactDBService: ContactDBService,
         messageDBService: MessageDBService,
         conversationDBService: ConversationDBService,
         messageService: MessageServiceClientProtocol,
         contactsService: ContactServiceClientProtocol) {
        self.appStore = appStore
        self.messageService = messageService
        self.contactsService = contactsService
        self.contactDBService = contactDBService
        self.messageDBService = messageDBService
        self.conversationDBService = conversationDBService
        
        self.contactByUserIdInteractor = .init(contactsService: contactsService)
    }
    
    override func executeSingle(params: MessageData) -> Single<Conversation?> {
        guard let messageID = params["msg_id"] as? String,
              let conversationID = params["chat_id"] as? String,
              let peerID = params["sender_id"] as? String else { return Single.error(NSError.objectsIsNill) }
        
    
        let contact = self.contactDBService.contact(id: peerID)
        if contact == nil {
            return self.contactByUserIdInteractor
                .executeSingle(params: peerID)
                .flatMap({ self.contactDBService.save(contact: DBContact(from: $0)) })
                .flatMap({_ in  self.message(by: messageID)})
                .flatMap({ message in self.conversationDBService.createIfNotExist(from: message).map({message}) })
                .flatMap({ message in self.messageDBService.update(message: message) })
                .flatMap({_ in self.conversationDBService.conversation(by: conversationID)})
                
                
        } else {
            return self.message(by: messageID)
                .flatMap({ message in self.conversationDBService.createIfNotExist(from: message).map({message}) })
                .flatMap({ message in self.messageDBService.update(message: message) })
                .flatMap({_ in self.conversationDBService.conversation(by: conversationID)})
        }
    }
}

extension SuperMessageSaverInteractor {
    func message(by id: String) -> Single<Message>{
        return Single<Message>.create(subscribe: { [weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            self.messageService.getMessage(.with({ $0.messageID = id }), callOptions: .default())
                .response.whenComplete { result in
                    switch result {
                    case let .success(response):
                        observer(.success(response.message))
                    case let .failure(error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        })
    }
}
