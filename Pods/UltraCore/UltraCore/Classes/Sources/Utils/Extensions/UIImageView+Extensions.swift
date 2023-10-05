//
//  UIImageView+Extensions.swift
//  UltraCore
//
//  Created by Slam on 4/18/23.
//

import Foundation
import SDWebImage

extension UIImageView {
    enum PlaceholderType {
        case oval, rounded, square
        case initial(text: String)
    }

    func config(contact: ContactDisplayable) {
        self.contentMode = .scaleAspectFit
        if let image = contact.image {
            self.image = image
            self.borderWidth = 1
            self.image = MediaUtils.image(from: contact) ?? image
        } else {
            self.borderWidth = 2
            self.loadImage(by: nil, placeholder: .initial(text: contact.displaName.initails))
        }
    }
    
    
    func loadImage(by path: String?, placeholder: PlaceholderType = .square) {
        self.contentMode = .scaleAspectFit
        switch placeholder {
        case let .initial(text: text):
            if let image = self.imageFromCache(forKey: text) {
                self.image = image
            } else if let image = self.generateAvatarImage(forUsername: text, size: self.frame.size == .zero ? CGSize(width: 64, height: 64) : self.frame.size) {
                self.saveImageToCache(image, forKey: text)
                self.image = image
            } else {
                self.image = placeholder.image
            }

        default:
            self.image = placeholder.image
            self.sd_setImage(with: path?.url, placeholderImage: placeholder.image)
        }
    }
}

extension UIImageView {
    
    func generateAvatarImage(forUsername username: String, size: CGSize) -> UIImage? {
        let frame = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Draw circle
        context.addEllipse(in: frame)
        context.clip()
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(frame)
        
        // Draw initials
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.green500,
            .font: UIFont.default(of: size.width / 2, and: .bold)
        ]
        let initials = String(username.prefix(2)).uppercased()
        let initialsString = NSAttributedString(string: initials, attributes: attributes)
        let textSize = initialsString.size()
        let textRect = CGRect(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2, width: textSize.width, height: textSize.height)
        initialsString.draw(in: textRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // Функция для сохранения изображения в кэш
    func saveImageToCache(_ image: UIImage?, forKey key: String) {
        guard let image = image else {
            return
        }
        let cache = SDImageCache.shared
        cache.store(image, forKey: key, toDisk: true, completion: nil)
    }

    // Функция для получения изображения из кэша по имени
    func imageFromCache(forKey key: String) -> UIImage? {
        let cache = SDImageCache.shared
        return cache.imageFromCache(forKey: key)
    }
}

extension UIImageView.PlaceholderType {
    var image: UIImage? {  UIImage.named("ff_logo_text") }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest = 0
        case low = 0.25
        case medium = 0.5
        case high = 0.75
        case highest = 1
    }

    func compress(_ jpegQuality: JPEGQuality) -> Data? { self.jpegData(compressionQuality: jpegQuality.rawValue) }

    static func named(_ name: String) -> UIImage? {
        let bundle = Bundle(for: AppSettingsImpl.self)
        if let resourceURL = bundle.url(forResource: "UltraCore", withExtension: "bundle"),
           let resourceBundle = Bundle(url: resourceURL) {
            let image = UIImage(named: name, in: resourceBundle, compatibleWith: nil)
            return image
        }
        return UIImage(named: name, in: AppSettingsImpl.shared.podAsset, compatibleWith: nil)
    }
    
    func downsample(reductionAmount: Float) -> UIImage? {
        let image = UIKit.CIImage(image: self)
        guard let lanczosFilter = CIFilter(name: "CILanczosScaleTransform") else { return nil }
        lanczosFilter.setValue(image, forKey: kCIInputImageKey)
        lanczosFilter.setValue(NSNumber(value: reductionAmount), forKey: kCIInputScaleKey)

        guard let outputImage = lanczosFilter.outputImage else { return nil }
        let context = CIContext(options: [CIContextOption.useSoftwareRenderer: false])
        let scaledImage = UIImage(cgImage: context.createCGImage(outputImage, from: outputImage.extent)!)

        return scaledImage
    }
}
