//
//  SendMoneyInterface.swift
//  UltraCore
//
//  Created by Slam on 7/4/23.
//
import RxSwift
import Foundation

struct TransferPayload: Codable {
    let sender: String
    let receiver: String
    let amount: Double
    let currency: String
}

struct TransferResponse: Codable {
    let status: String
    let transaction_id: String
}

class SendMoneyInteractor: UseCase<TransferPayload, TransferResponse> {
    
    override func executeSingle(params: TransferPayload) -> Single<TransferResponse> {
        return Single.create(subscribe: { observer -> Disposable in

            guard let jsonData = try? JSONEncoder().encode(params) else {
                observer(.failure(NSError.objectsIsNill))
                return Disposables.create()
            }
            let url = URL(string: "https://ultra-dev.typi.team/mock/v1/transfer")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    observer(.failure(error))
                } else if let data = data,
                          let response = try? JSONDecoder().decode(TransferResponse.self, from: data) {
                    observer(.success(response))
                } else {
                    observer(.failure(NSError.objectsIsNill))
                }
            }

            task.resume()

            return Disposables.create()
        })
    }
}
