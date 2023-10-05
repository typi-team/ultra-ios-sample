//
//  ViewController.swift
//  ExampleOfUltra
//
//  Created by Slam on 10/5/23.
//
import UltraCore

import UIKit

struct UserResponse: Codable {
    let sid: String
    let sidExpire: Int
    let firstname: String
    let lastname: String
    let phone: String
    
    private enum CodingKeys: String, CodingKey {
        case sid
        case sidExpire = "sid_expire"
        case firstname
        case lastname
        case phone
    }
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UltraCoreSettings.delegate = self
        
        self.login(lastName: "Salem", firstname: "Alem", phone: "+77756043100")
    }
    
    func login(lastName: String, firstname: String, phone number: String) {
        guard let url = URL(string: "https://ultra-dev.typi.team/mock/v1/auth"),
              let jsonData = try? JSONSerialization.data(withJSONObject: [
                  "phone": number,
                  "lastname": lastName,
                  "firstname": firstname,
                  "nickname": firstname,
              ]) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
             if let data = data,
                      let userResponse = try? JSONDecoder().decode(UserResponse.self, from: data) {
                 DispatchQueue.main.async {
                     if error != nil {
                         self.present(UltraCoreSettings.entrySignUpViewController(), animated: true)
                         UltraCoreSettings.printAllLocalizableStrings()
                     } else {
                         self.present(UltraCoreSettings.entryConversationsViewController(), animated: true)
                         
                     }
                 }
            }
        }
        
        task.resume()
    }
}


extension ViewController: UltraCoreSettingsDelegate {
    func serverConfig() -> UltraCore.ServerConfigurationProtocol? {
        return ServerConfig()
    }
    
    func moneyViewController(callback: @escaping UltraCore.MoneyCallback) -> UIViewController? {
        nil
    }
    
    func contactsViewController(contactsCallback: @escaping UltraCore.ContactsCallback, openConverationCallback: @escaping UltraCore.UserIDCallback) -> UIViewController? {
        nil
    }
}

struct ServerConfig: ServerConfigurationProtocol {
    var portOfServer: Int = 443
    var pathToServer: String = "ultra-dev.typi.team"
}



