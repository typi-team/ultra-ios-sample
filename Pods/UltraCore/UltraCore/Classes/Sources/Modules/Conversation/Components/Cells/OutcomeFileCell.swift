//
//  OutcomeFileCell.swift
//  UltraCore
//
//  Created by Slam on 7/18/23.
//

import UIKit

class OutcomeFileCell : BaseMessageCell {
    
    fileprivate let statusView: UIImageView = .init(image: UIImage.named("conversation_status_read"))
    fileprivate let moneyAvatarView: UIImageView = .init({
        $0.image = UIImage.named("contact_file_icon")
        $0.contentMode = .center
    })
    
    fileprivate let moneyHeadlineLabel: RegularCallout = .init({ $0.text = ConversationStrings.money.localized })
    fileprivate let moneyCaptionlabel: RegularFootnote = .init({ $0.text = MessageStrings.fileWithoutSmile.localized })
    
    override func setupView() {
        super.setupView()

        self.container.addSubview(moneyAvatarView)
        self.container.addSubview(moneyHeadlineLabel)
        self.container.addSubview(moneyCaptionlabel)
        self.container.addSubview(statusView)
        self.container.backgroundColor = .gray200
    }
    
    override func setupConstraints() {
        
        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.left.greaterThanOrEqualToSuperview().offset(kHeadlinePadding * 4)
        }
        
        self.moneyAvatarView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kMediumPadding)
            make.top.equalToSuperview().offset(kMediumPadding)
            make.bottom.equalToSuperview().offset(-kMediumPadding)
            make.width.equalTo(16)
        }
        
        self.moneyHeadlineLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kMediumPadding)
            make.left.equalTo(moneyAvatarView.snp.right).offset(kMediumPadding)
            make.right.equalToSuperview().offset(kMediumPadding).offset(-kMediumPadding)
        }
        
        self.moneyCaptionlabel.snp.makeConstraints { make in
            make.bottom.equalTo(moneyAvatarView.snp.bottom)
            make.top.equalTo(moneyHeadlineLabel.snp.bottom).offset(1)
            make.left.equalTo(moneyAvatarView.snp.right).offset(kMediumPadding)
        }

        self.statusView.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(self.moneyCaptionlabel.snp.right).offset(kLowPadding / 2)
            make.centerY.equalTo(moneyCaptionlabel.snp.centerY)
        }
        
        self.deliveryDateLabel.snp.makeConstraints { make in
            make.left.equalTo(self.statusView.snp.right).offset(kLowPadding / 2)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalTo(moneyCaptionlabel.snp.bottom)
            make.centerY.equalTo(statusView.snp.centerY)
        }
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        self.moneyHeadlineLabel.text = message.file.fileName
        self.statusView.image = .named(message.statusImageName)
    }
}
