//
//  IncomeMoneyCell.swift
//  UltraCore
//
//  Created by Slam on 7/5/23.
//

import UIKit

class IncomeMoneyCell : BaseMessageCell {
    
    fileprivate let moneyAmountLabel: RegularCallout = .init({ $0.text = "10.00₸" })
    fileprivate let moneyHeadlineLabel: RegularCallout = .init({ $0.text = ConversationStrings.money.localized })
    fileprivate let moneyCaptionlabel: RegularFootnote = .init({ $0.text = MessageStrings.moneyTransfer.localized })
    fileprivate let moneyAvatarView: UIImageView = .init({
        $0.image = UIImage.named("conversation_money_icon")
        $0.contentMode = .center
    })
    
    override func setupView() {
        super.setupView()
        self.container.addSubview(moneyAvatarView)
        self.container.addSubview(moneyAmountLabel)
        self.container.addSubview(moneyHeadlineLabel)
        self.container.addSubview(moneyCaptionlabel)
    }

    override func setupConstraints() {
        
        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.right.lessThanOrEqualToSuperview().offset(-120)
        }
        
        self.moneyHeadlineLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kMediumPadding)
            make.left.equalToSuperview().offset(kMediumPadding)
        }

        self.moneyAmountLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kMediumPadding)
            make.left.equalTo(moneyHeadlineLabel.snp.right).offset(kLowPadding)
        }
        
        self.moneyCaptionlabel.snp.makeConstraints { make in
            make.top.equalTo(moneyHeadlineLabel.snp.bottom).offset(1)
            make.left.equalToSuperview().offset(kMediumPadding)
            make.bottom.equalTo(moneyAvatarView.snp.bottom)
        }

        self.moneyAvatarView.snp.makeConstraints { make in
            make.left.equalTo(moneyAmountLabel.snp.right).offset(kMediumPadding)
            make.top.equalToSuperview().offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalToSuperview().offset(-kMediumPadding)
            make.width.equalTo(16)
        }

        self.deliveryDateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(moneyCaptionlabel.snp.centerY)
            make.right.equalTo(moneyAvatarView.snp.left).offset(-kMediumPadding)
            make.left.equalTo(self.moneyCaptionlabel.snp.right).offset(kLowPadding / 2)
        }
    }

    override func setup(message: Message) {
        super.setup(message: message)
        self.moneyAmountLabel.text = message.money.money.formattedPrice
    }
}
