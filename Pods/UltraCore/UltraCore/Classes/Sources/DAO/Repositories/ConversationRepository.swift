//
//  ConversationRepository.swift
//  UltraCore
//
//  Created by Slam on 5/2/23.
//

import RxSwift
import RealmSwift

protocol ConversationRepository {
    func createIfNotExist(from message: Message) -> Single<Void>
    func conversations() -> Observable<[Conversation]>
}

class ConversationRepositoryImpl {
    
    fileprivate let conversationService: ConversationDBService
    
    init(conversationService: ConversationDBService) {
        self.conversationService = conversationService
        
        let realm = Realm.myRealm()
        print(realm.configuration.fileURL?.absoluteString)
//        try! realm.write({ realm.deleteAll() })
    }
}

extension ConversationRepositoryImpl: ConversationRepository {
    func createIfNotExist(from message: Message) -> Single<Void> {
        return self.conversationService.createIfNotExist(from: message)
    }
    
    func conversations() -> Observable<[Conversation]> {
        return self.conversationService.conversations()
    }
}
