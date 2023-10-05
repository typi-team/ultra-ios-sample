//
//  UploadFileInteractor.swift
//  UltraCore
//
//  Created by Slam on 6/6/23.
//

import RxSwift

class UploadFileInteractor: UseCase<[FileChunk], Void> {

     private let fileService: FileServiceClientProtocol

     init(fileService: FileServiceClientProtocol) {
         self.fileService = fileService
     }

    override func executeSingle(params: [FileChunk]) -> Single<Void> {
        return Single<Void>.create { observer -> Disposable in
            let call = self.fileService.upload(callOptions: .default())
            call.sendMessages(params, compression: .enabled)
                .whenComplete { result in
                    switch result {
                    case let .success(response):
                        call.sendEnd().whenSuccess { _ in
                            observer(.success(response))
                        }
                    case let .failure(error):
                        observer(.failure(error))
                    }
                }

            return Disposables.create()
        }
    }
}
