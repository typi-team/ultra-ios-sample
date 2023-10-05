//
//  DeleteMessageInteractor.swift
//  UltraCore
//
//  Created by Slam on 7/13/23.
//

import RxSwift

class DeleteMessageInteractor: UseCase<([Message], Bool), Void> {
    
    fileprivate let messageDBService: MessageDBService
    fileprivate let messageService: MessageServiceClientProtocol
    
    
    init(messageDBService: MessageDBService,
         messageService: MessageServiceClientProtocol) {
        self.messageService = messageService
        self.messageDBService = messageDBService
    }
    
    override func executeSingle(params: ([Message], Bool)) -> Single<Void> {
        return Single.create(subscribe: { observer -> Disposable in
            let range = MessagesDeleteRequest.with({ request in
                request.forEveryone = params.1
                request.chatID = params.0.first?.receiver.chatID ?? ""
                request.range = self.splitToRanges(numbers: params.0.map({ $0.seqNumber }).sorted(by: { $0 < $1 }))
                    .map({ range in
                        MessagesRange.with({
                            $0.maxSeqNumber = range.upperBound
                            $0.minSeqNumber = range.lowerBound
                        }) })
            })
            self.messageService.delete(range, callOptions: .default())
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
        .flatMap({ [weak self] in
            guard let `self` = self else { throw NSError.selfIsNill }
            return self.messageDBService.delete(messages: params.0, in: params.0.last?.receiver.chatID)
        })
    }

    func splitToRanges(numbers: [UInt64]) -> [ClosedRange<UInt64>] {
        var ranges: [ClosedRange<UInt64>] = []

        var start = numbers.first ?? 0
        var end = numbers.first ?? 0

        for i in 0 ..< numbers.count {
            if numbers[i] == end + 1 {
                end = numbers[i]
            } else {
                let range = ClosedRange(uncheckedBounds: (start, end))
                ranges.append(range)
                start = numbers[i]
                end = numbers[i]
            }
        }
        let range = ClosedRange(uncheckedBounds: (start, end))
        ranges.append(range)

        return ranges
    }
}
