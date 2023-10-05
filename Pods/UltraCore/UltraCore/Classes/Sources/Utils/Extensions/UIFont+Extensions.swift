//
//  UIFont+Extensions.swift
//  UltraCore
//
//  Created by Slam on 4/18/23.
//

import Foundation

extension UIFont {

    class var defaultRegularHeadline: UIFont {
        return UIFont.systemFont(ofSize: 18.0, weight: .regular)
    }
    
    class var defaultRegularSubHeadline: UIFont {
        return UIFont.systemFont(ofSize: 15.0, weight: .regular)
    }
    
    class var defaultRegularBoldSubHeadline: UIFont {
        return UIFont.systemFont(ofSize: 15.0, weight: .bold)
    }

    class var defaultRegularBody: UIFont {
        return UIFont.systemFont(ofSize: 17.0, weight: .regular)
    }

    class var defaultRegularCallout: UIFont {
        return UIFont.systemFont(ofSize: 16.0, weight: .regular)
    }

    class var defaultRegularFootnote: UIFont {
        return UIFont.systemFont(ofSize: 13.0, weight: .regular)
    }

    class var defaultRegularCaption3: UIFont {
        return UIFont.systemFont(ofSize: 10.0, weight: .regular)
    }
}


extension UIFont {
    static func `default`(of size: CGFloat, and weight: Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
