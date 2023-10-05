//
//  StringLocalizable.swift
//  UltraCore
//
//  Created by Slam on 8/7/23.
//

import Foundation

protocol StringLocalizable: CaseIterable {
    var localized: String { get }
    var prefixOfTemplate: String { get }
    var localizableValue: String { get }
    var descrition: String { get }
}

extension StringLocalizable {
    var descrition: String { "\(prefixOfTemplate).\(localizableValue)" }

    var localized: String { NSLocalizedString("\(prefixOfTemplate).\(localizableValue)",
                                              comment: "\(prefixOfTemplate).\(localizableValue)") }
}
