//
//  Labels.swift
//  UltraCore
//
//  Created by Slam on 4/14/23.
//

import UIKit

class BaseLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }

    func setupView() {
        textColor = .gray500
        self.numberOfLines = 0
        font = .defaultRegularFootnote
        self.traitCollectionDidChange(UIScreen.main.traitCollection)
    }
}

class HeadlineBody: BaseLabel {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.font = UltraCoreStyle.headlineConfig.font
        self.textColor = UltraCoreStyle.headlineConfig.color
    }
}

class RegularBody: BaseLabel {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.font = UltraCoreStyle.regularLabelConfig.font
        self.textColor = UltraCoreStyle.regularLabelConfig.color
    }
}

class RegularCallout: BaseLabel {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.font = UltraCoreStyle.regularCalloutConfig.font
        self.textColor = UltraCoreStyle.regularCalloutConfig.color
    }
}

class RegularFootnote: BaseLabel {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.font = UltraCoreStyle.regularFootnoteConfig.font
        self.textColor = UltraCoreStyle.regularFootnoteConfig.color
    }
}

class RegularCaption3: BaseLabel {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.font = UltraCoreStyle.regularCaption3Config.font
        self.textColor = UltraCoreStyle.regularCaption3Config.color
    }
}

class SubHeadline: BaseLabel {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.font = UltraCoreStyle.subHeadlineConfig.font
        self.textColor = UltraCoreStyle.subHeadlineConfig.color
    }
}


class LabelWithInsets: BaseLabel {
    
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top, left: -textInsets.left, bottom: -textInsets.bottom, right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }
}
