//
//  UIColor+Extensions.swift
//  UltraCore
//
//  Created by Slam on 4/18/23.
//

import Foundation

extension UIColor {

  @nonobjc class var gray900: UIColor {
      return UIColor(red: 17.0 / 255.0, green: 24.0 / 255.0, blue: 39.0 / 255.0, alpha: 1.0)
  }
    
    @nonobjc class var gray700: UIColor {
      return UIColor(red: 55.0 / 255.0, green: 65.0 / 255.0, blue: 81.0 / 255.0, alpha: 1.0)
  }

  @nonobjc class var gray600: UIColor {
      return UIColor(red: 75.0 / 255.0, green: 85.0 / 255.0, blue: 99.0 / 255.0, alpha: 1.0)
  }

  @nonobjc class var green600: UIColor {
      return UIColor(red: 22.0 / 255.0, green: 163.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
  }

  @nonobjc class var productBlurDark: UIColor {
      return UIColor(red: 17.0 / 255.0, green: 24.0 / 255.0, blue: 39.0 / 255.0, alpha: 0.5)
  }

  @nonobjc class var black: UIColor {
      return UIColor(white: 0.0, alpha: 1.0)
  }

  @nonobjc class var productBlurLight: UIColor {
      return UIColor(red: 243.0 / 255.0, green: 244.0 / 255.0, blue: 246.0 / 255.0, alpha: 0.7)
  }

  @nonobjc class var gray100: UIColor {
      return UIColor(red: 243.0 / 255.0, green: 244.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
  }

  @nonobjc class var white: UIColor {
      return UIColor(white: 1.0, alpha: 1.0)
  }

  @nonobjc class var gray500: UIColor {
      return UIColor(red: 107.0 / 255.0, green: 114.0 / 255.0, blue: 128.0 / 255.0, alpha: 1.0)
  }

  @nonobjc class var green100: UIColor {
      return UIColor(red: 188.0 / 255.0, green: 224.0 / 255.0, blue: 203.0 / 255.0, alpha: 1.0)
  }

  @nonobjc class var green500: UIColor {
      return UIColor(red: 34.0 / 255.0, green: 197.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0)
  }

  @nonobjc class var red500: UIColor {
      return UIColor(red: 239.0 / 255.0, green: 68.0 / 255.0, blue: 68.0 / 255.0, alpha: 1.0)
  }

  @nonobjc class var gray200: UIColor {
      return UIColor(red: 229.0 / 255.0, green: 231.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0)
  }
    
    @nonobjc class var gray400: UIColor { UIColor.from(hex: "#9CA3AF") }
    
    static func from(hex: String) -> UIColor {
        var formattedString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            formattedString = formattedString.replacingOccurrences(of: "#", with: "")

            var hex: UInt64 = 0

            Scanner(string: formattedString).scanHexInt64(&hex)

            let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(hex & 0x0000FF) / 255.0

            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
