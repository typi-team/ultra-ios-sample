//
//  SyncFreedomContactsInteractor.swift
//  UltraCore
//
//  Created by Slam on 9/28/23.
//
import RxSwift
import Foundation

class SyncFreedomContactsInteractor: UseCase<ContactsImportRequest, ContactImportResponse> {
    
    fileprivate let appStore: AppSettingsStore
    
    init(appStore: AppSettingsStore) {
        self.appStore = appStore
    }
    
    override func executeSingle(params: ContactsImportRequest) -> Single<ContactImportResponse> {
        return Single.create(subscribe: { [weak self] observer in
            guard let `self` = self,
                  let url = "https://ultra-dev.typi.team/mock/v1/contacts/import".url,
                  let httpBody = try? JSONEncoder().encode(params) else {
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue(self.appStore.ssid, forHTTPHeaderField: "SID")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.httpBody = httpBody

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data, let responseObject = try? JSONDecoder().decode(ContactImportResponse.self, from: data) {
                    observer(.success(responseObject))
                }else if let error = error {
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

extension ContactsImportRequest: Encodable {
    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(contacts, forKey: .contacts)
        }

        enum CodingKeys: String, CodingKey {
            case contacts
        }
    

}

extension ContactImportResponse: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        contacts = try container.decode([Contact].self, forKey: .contacts)
    }

    enum CodingKeys: String, CodingKey {
        case contacts
    }

}

extension Contact: Encodable, Decodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstname, forKey: .firstname)
        try container.encode(lastname, forKey: .lastname)
        try container.encode(phone, forKey: .phone)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstname = try container.decode(String.self, forKey: .nickname)
        lastname = try container.decode(String.self, forKey: .firstname)
        phone = try container.decode(String.self, forKey: .user_id)
    }

    enum CodingKeys: String, CodingKey {
        case firstname
        case lastname
        case phone
        case nickname
        case user_id
    }

}
