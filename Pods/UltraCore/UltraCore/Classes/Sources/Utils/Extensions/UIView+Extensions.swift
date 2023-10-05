//
//  UIView+Extensions.swift
//  UltraCore
//
//  Created by Slam on 4/19/23.
//

import Foundation

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    private func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                           shadowOffset: CGSize = CGSize(width: 0, height: 1.0),
                           shadowOpacity: Float = 0.3,
                           shadowRadius: CGFloat = 1.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}
