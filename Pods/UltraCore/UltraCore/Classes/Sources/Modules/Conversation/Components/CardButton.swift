//
//  CardButton.swift
//  UltraCore
//
//  Created by Slam on 7/4/23.
//

import UIKit

class CardButton: UIView {
    
    fileprivate lazy var shevron: UIImageView = .init(image: .named("conversation_shevron"))
    
    fileprivate lazy var currentSummLabel: RegularCallout = .init({
        $0.text = "27 016.19 ₸"
    })
    
    fileprivate lazy var cardButton: TextButton = .init({
        $0.titleLabel?.numberOfLines = 0
        $0.setImage(.named("conversation_money_card_icon"), for: .normal)
        
        let boldFontAttributes: [NSAttributedString.Key: Any] = [ .font: UIFont.defaultRegularBody,
                                                                  .foregroundColor : UltraCoreStyle.textButtonConfig.color ]
        let smallFontAttributes: [NSAttributedString.Key: Any] = [ .font: UIFont.defaultRegularFootnote,
                                                                   .foregroundColor : UIColor.gray500]

        let boldText = ConversationStrings.multivalue.localized
        let smallText = "5500 13 •••• 0088"
        let titleText = "\(boldText)\n\(smallText)"

        let attributedTitle = NSMutableAttributedString(string: titleText)
        attributedTitle.addAttributes(boldFontAttributes, range: NSRange(location: 0, length: boldText.count))
        attributedTitle.addAttributes(smallFontAttributes, range: NSRange(location: boldText.count + 1, length: smallText.count))
        $0.setAttributedTitle(attributedTitle, for: .normal)
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.addSubview(cardButton)
        self.addSubview(currentSummLabel)
        self.addSubview(shevron)
        self.cardButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.currentSummLabel.snp.makeConstraints { make in
            make.left.equalTo(self.cardButton.snp.right).offset(kMediumPadding)
            make.centerY.equalToSuperview()
        }
        
        self.shevron.snp.makeConstraints { make in
            make.left.equalTo(currentSummLabel.snp.right).offset(kMediumPadding)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
}
