//
//  UITableView+Extensions.swift
//  UltraCore
//
//  Created by Slam on 4/20/23.
//

import UIKit

public extension UITableView {
    
    func registerCell(type: UITableViewCell.Type, identifier: String? = nil) {
        register(type, forCellReuseIdentifier: type.identifier)
    }
    
    func dequeueCell<T: UITableViewCell>() -> T {
        return dequeueReusableCell(withIdentifier: T.identifier) as! T
    }
}

public extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
    
}
