//
//  ConversationsStrings.swift
//  _NIODataStructures
//
//  Created by Slam on 8/7/23.
//

import Foundation

enum ConversationsStrings:  String {
    case chats
}

extension ConversationsStrings: StringLocalizable {
    var prefixOfTemplate: String { "conversations" }
    var localizableValue: String { rawValue }
}
