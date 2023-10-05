//
//  UpdateOnlineInteractor.swift
//  UltraCore
//
//  Created by Slam on 6/20/23.
//
import RxSwift

class UpdateOnlineInteractor: UseCase<Bool, UpdateStatusResponse> {
    
    fileprivate let userService: UserServiceClientProtocol
    
    init(userService: UserServiceClientProtocol) {
        self.userService = userService
    }
    
    override func executeSingle(params: Bool) -> Single<UpdateStatusResponse> {
        return Single.create { [weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            self.userService.setStatus(.with({ $0.status = params ? .online : .away }), callOptions: .default()).response.whenComplete { result in
                switch result {
                case let .failure(error):
                    observer(.failure(error))
                case let .success(response):
                    observer(.success(response))
                }
            }

            return Disposables.create()
        }
    }
}
