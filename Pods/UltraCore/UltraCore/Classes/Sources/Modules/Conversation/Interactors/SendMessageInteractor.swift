//
//  SendMessageInteractor.swift
//  UltraCore
//
//  Created by Slam on 4/26/23.
//

import Foundation
import RxSwift

class SendMessageInteractor: UseCase<MessageSendRequest, MessageSendResponse> {
    final let messageService: MessageServiceClientProtocol

    init(messageService: MessageServiceClientProtocol) {
        self.messageService = messageService
    }

    override func executeSingle(params: MessageSendRequest) -> Single<MessageSendResponse> {
        return Single.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }

            self.messageService.send(params, callOptions: .default()).response.whenComplete { result in
                switch result {
                case let .success(response):
                    observer(.success(response))
                case let .failure(error):
                    print(error.localizedDescription)
                    observer(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}

class ReadMessageInteractor: UseCase<Message, MessagesReadResponse> {
    final let messageService: MessageServiceClientProtocol

    init(messageService: MessageServiceClientProtocol) {
        self.messageService = messageService
    }

    override func executeSingle(params: Message) -> Single<MessagesReadResponse> {
        return Single.create { [weak self] observer -> Disposable in
            
            guard let `self` = self else { return Disposables.create() }
            self.messageService.read(params.readRequest, callOptions: .default()).response.whenComplete { result in
                switch result {
                case let .success(response):
                    observer(.success(response))
                case let .failure(error):
                    observer(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}

class DeliveredMessageInteractor: UseCase<Message, MessagesDeliveredResponse> {
    final let messageService: MessageServiceClientProtocol

    init(messageService: MessageServiceClientProtocol) {
        self.messageService = messageService
    }

    override func executeSingle(params: Message) -> Single<MessagesDeliveredResponse> {
        return Single.create { [weak self] observer -> Disposable in
            
            guard let `self` = self else { return Disposables.create() }
            self.messageService.delivered(params.deliveredRequest, callOptions: .default())
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
    }
}

private extension Message {
    var readRequest: MessagesReadRequest {
        return .with({
            $0.chatID = receiver.chatID
            $0.readTime = Date().nanosec
            $0.maxSeqNumber = UInt64.init(self.seqNumber)
        })
    }
    
    var deliveredRequest:MessagesDeliveredRequest {
        return .with({
            $0.chatID = receiver.chatID
            $0.maxSeqNumber = UInt64.init(self.seqNumber)
        })
    }
}
