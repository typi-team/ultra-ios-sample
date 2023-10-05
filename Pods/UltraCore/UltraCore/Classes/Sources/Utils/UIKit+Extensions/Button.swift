//
//  Button.swift
//  UltraCore
//
//  Created by Slam on 4/19/23.
//

import Foundation

class ElevatedButton: UIButton {
    
    // Отступы для содержимого кнопки
    let contentInsets = UIEdgeInsets(top: kMediumPadding, left: kHeadlinePadding, bottom: kMediumPadding, right: kHeadlinePadding)
    
    override func contentRect(forBounds bounds: CGRect) -> CGRect {
        // Учитываем отступы для вычисления фактической области содержимого кнопки
        let newBounds = bounds.inset(by: contentInsets)
        return super.contentRect(forBounds: newBounds)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        // Учитываем отступы для вычисления фактической области заголовка кнопки
        let newContentRect = contentRect.inset(by: contentInsets)
        return super.titleRect(forContentRect: newContentRect)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        // Учитываем отступы для вычисления фактической области изображения кнопки
        let newContentRect = contentRect.inset(by: contentInsets)
        return super.imageRect(forContentRect: newContentRect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.backgroundColor = .green600
        self.cornerRadius = kMediumPadding
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = .defaultRegularCallout
    }
}


class TextButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.titleEdgeInsets = .init(top: 0, left: kMediumPadding + 2, bottom: 0, right: 0)
        self.traitCollectionDidChange(UIScreen.main.traitCollection)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.titleLabel?.font = UltraCoreStyle.textButtonConfig.font
        self.setTitleColor(UltraCoreStyle.textButtonConfig.color, for: .normal)
    }
}
