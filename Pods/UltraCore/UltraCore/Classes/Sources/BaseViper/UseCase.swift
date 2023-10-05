import Foundation
import RxSwift

class UseCase<P, R> {
    func execute(params: P) -> Observable<R> {
        fatalError("execute(params:) has not been implemented")
    }
    func executeCompletable(params: P) -> Completable {
        fatalError("executeCompletable(params:) has not been implemented")
    }
    func executeSingle(params: P) -> Single<R> {
        fatalError("executeSingle(params:) has not been implemented")
    }

    func executeMaybe(params: P) -> Maybe<R> {
        fatalError("executeMaybe(params:) has not been implemented")
    }
    
    deinit {
        PP.info("Deinit \(String.init(describing: self))")
    }
}
