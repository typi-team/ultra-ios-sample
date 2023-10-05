//
//  ContactDownloadInteractor.swift
//  UltraCore
//
//  Created by Slam on 6/19/23.
//
import RxSwift
import Foundation

class ContactDownloadInteractor: UseCase<Contact, Void> {
    
    fileprivate let mediaUtils: MediaUtils
    fileprivate let appStore: AppSettingsStore
    
    init(mediaUtils: MediaUtils,
         appStore: AppSettingsStore) {
        self.appStore = appStore
        self.mediaUtils = mediaUtils
    }
    
    override func executeSingle(params: Contact) -> Single<Void> {
        return Single<Void>.create(subscribe: { [weak self] observer -> Disposable in
            guard let `self` = self,
                  let url = URL(string: "https://ultra-dev.typi.team/mock/v1/profile/get-avatar?phone=\(params.phone)") else {
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue(self.appStore.ssid, forHTTPHeaderField: "SID")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let imageData = data, imageData.count > 0 {
                    _ = try? self.mediaUtils.write(imageData, file: params.previewKey, and: params.previewExtension)
                    PP.info("image saved for \(params.previewKey)")
                    observer(.success(()))
                } else if let error = error {
                    observer(.failure(error))
                } else {
                    observer(.failure(NSError.objectsIsNill))
                }
            }

            task.resume()
            return Disposables.create {
                task.cancel()
            }
        })
    }
}
