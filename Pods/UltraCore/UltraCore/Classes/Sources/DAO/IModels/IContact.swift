//
//  IContact.swift
//  UltraCore
//
//  Created by Slam on 5/19/23.
//

import Foundation

public protocol IContact {
    var phone: String { get set }
    var firstname: String { get set }
}

public typealias UserIDCallback = (IContact) -> Void
public typealias ContactsCallback = ([IContact]) -> Void
