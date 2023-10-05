//
//  MessageStrings.swift
//  UltraCore
//
//  Created by Slam on 8/7/23.
//

import Foundation

enum MessageStrings: String, StringLocalizable {
    
    case audio
    case voice
    case photo
    case video
    case money
    case location
    case file
    case contact
    case moneyTransfer
    case uploadingInProgress
    case fileWithoutSmile

    var prefixOfTemplate: String { "message" }
    var localizableValue: String { rawValue }
}
