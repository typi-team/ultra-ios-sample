//
//  MessageService.swift
//  UltraCore
//
//  Created by Slam on 5/3/23.
//

import RxSwift
import RealmSwift

class MessageDBService {
    fileprivate let userId: String
    
    init(userId: String) {
        self.userId = userId
    }

//  MARK: Обновление сообщения в базе данных
    func update(message: Message) -> Single<Bool> {
        return Single.create {[weak self ] completable in
            guard let `self` = self else { return Disposables.create() }
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    if let messageInDB = realm.object(ofType: DBMessage.self, forPrimaryKey: message.id) {
                        messageInDB.state?.read = message.state.read
                        messageInDB.state?.edited = message.state.edited
                        messageInDB.state?.delivered = message.state.delivered
                        messageInDB.seqNumber = Int64(message.seqNumber)
                    } else {
                        realm.create(DBMessage.self,
                                     value: DBMessage(from: message, user: self.userId), update: .all)
                    }
                    
                }

                completable(.success(true))
            } catch {
                completable(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    //  MARK: Обновить сообщения как доставлено в базе данных
    func delivered(message data: MessagesDelivered) -> Single<Bool> {
        return Single.create { completable in
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    let messagesInDB = realm.objects(DBMessage.self)
                        .where({ $0.receiver.chatID.equals(data.chatID) })
                        .where({ $0.seqNumber <= Int64(data.maxSeqNumber) })
                    messagesInDB.forEach { message in
                        message.state?.delivered = true
                    }
                }
                completable(.success(true))
            } catch {
                completable(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    //  MARK: Обновить сообщения как прочитанный в базе данных
    func readed(message data: MessagesRead) -> Single<Bool> {
        return Single.create { completable in
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    let messagesInDB = realm.objects(DBMessage.self)
                        .where({ $0.receiver.chatID.equals(data.chatID) })
                        .where({ $0.seqNumber <= Int64(data.maxSeqNumber) })
                    messagesInDB.forEach { message in
                        message.state?.read = true
                        message.state?.delivered = true
                    }
                }
                completable(.success(true))
            } catch {
                completable(.failure(error))
            }
            return Disposables.create()
        }
    }

//   MARK: Получение всех сообщений в чате
    func messages(chatID: String) -> Observable<[Message]> {
        return Observable.create { observer in
            let realm = Realm.myRealm()
            let messages = realm.objects(DBMessage.self).where { $0.receiver.chatID.equals(chatID) }
            let notificationKey = messages.observe(keyPaths: []) { changes in
                switch changes {
                case let .initial(collection):
                    observer.on(.next(collection.map({$0.toProto()})))
                case let .update(collection, _, _, _):
                    observer.on(.next(collection.map({$0.toProto()})))
                case let .error(error):
                    observer.on(.error(error))
                }
            }
            
            observer.onNext(messages.map({$0.toProto()}))
            return Disposables.create {
                notificationKey.invalidate()
            }
        }
    }
    
//    MARK: Сохранение сообщения в базу данных
    func save(message: Message) -> Single<Void> {
        return Single.create {[weak self] completable in
            guard let `self` = self else { return Disposables.create() }
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    realm.create(DBMessage.self,
                                 value: DBMessage(from: message, user: self.userId), update: .all)
                    
                }
                completable(.success(()))
            } catch {
                completable(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    /// Удаление сообщения
    /// - Parameter messages: Массив сообщений, важно: если сообщение последние в DBConversation то выставиться последнее что не удалено или пустота 
    /// - Returns: Void
    func delete(messages: [Message], in conversationID: String?) -> Single<Void> {
        return Single.create(subscribe: { observer -> Disposable in
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    messages.forEach { message in
                        let dbMessage = realm.object(ofType: DBMessage.self, forPrimaryKey: message.id)
                        if let dbMessage = dbMessage {
                            realm.delete(dbMessage)
                        }
                    }

                    self.updateLastMessage(in: conversationID, on: realm)
                }
                observer(.success(()))
            } catch {
                observer(.failure(error))
            }
            return Disposables.create()
        })
    }
    
    func updateLastMessage(in conversationID: String?, on realm: Realm) {
        if let conversationID = conversationID,
            let conversaiton = realm.object(ofType: DBConversation.self, forPrimaryKey: conversationID),
           conversaiton.message == nil {
            conversaiton.message = realm.objects(DBMessage.self).where({$0.receiver.chatID == conversationID}).last
        }
    }
    
    func deleteMessages(in conversationID: String, ranges: [ClosedRange<Int64>]) -> Single<Void> {
        return Single.create(subscribe: {[weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    let messages = realm.objects(DBMessage.self)
                        .filter({ $0.receiver?.chatID == conversationID })
                        .filter({ self.isInRanges(number: Int64($0.seqNumber), ranges: ranges) })
                    messages.forEach({ realm.delete($0) })
                    self.updateLastMessage(in: conversationID, on: realm)
                }
                observer(.success(()))
            } catch {
                observer(.failure(error))
            }

            return Disposables.create()
        })
    }
    
    func save(messages: [Message]) -> Single<Void> {
        return Single.create {[weak self] completable in
            guard let `self` = self else { return Disposables.create() }
            do {
                let realm = Realm.myRealm()
                try realm.write {
                    messages.forEach { message in
                        realm.create(DBMessage.self,
                                     value: DBMessage(from: message, user: self.userId), update: .all)
                    }
                    
                }
                completable(.success(()))
            } catch {
                completable(.failure(error))
            }
            return Disposables.create()
        }
    }
}

private extension MessageDBService {
    func isInRanges(number: Int64, ranges: [ClosedRange<Int64>]) -> Bool {
        for range in ranges {
            if range.contains(number) {
                return true
            }
        }
        return false
    }
}
