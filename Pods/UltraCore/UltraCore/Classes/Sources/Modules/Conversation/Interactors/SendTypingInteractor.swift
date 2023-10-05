//
//  SendTypingInteractor.swift
//  UltraCore
//
//  Created by Slam on 5/16/23.
//
import RxSwift
import Foundation

class SendTypingInteractor: UseCase<String, SendTypingResponse> {
    final let messageService: MessageServiceClientProtocol

    init(messageService: MessageServiceClientProtocol) {
        self.messageService = messageService
    }

    override func executeSingle(params: String) -> Single<SendTypingResponse> {
        return Single.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }

            self.messageService
                .sendTyping(.with({ $0.chatID = params }), callOptions: .default())
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

