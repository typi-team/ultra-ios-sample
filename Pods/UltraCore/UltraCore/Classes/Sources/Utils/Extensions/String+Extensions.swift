//
//  String+Extensions.swift
//  UltraCore
//
//  Created by Slam on 4/21/23.
//

import Foundation
extension String {
    var initails: String {
        let components = self.components(separatedBy: " ")
        var initials = ""
        for component in components {
            if let firstCharacter = component.first {
                initials.append(firstCharacter)
            }
        }
        return initials
    }
    
    var isValidPhone: Bool {
        return self.starts(with: "+7") && count == 12
    }
    
    var localized: String { NSLocalizedString(self, comment: self) }
}
