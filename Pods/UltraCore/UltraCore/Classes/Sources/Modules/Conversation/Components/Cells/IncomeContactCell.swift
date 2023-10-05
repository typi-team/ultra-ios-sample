//
//  IncomeContactCell.swift
//  UltraCore
//
//  Created by Slam on 7/25/23.
//

import UIKit

class IncomeContactCell : BaseMessageCell {
    
    let mediaRepository: MediaRepository = AppSettingsImpl.shared.mediaRepository
    
    fileprivate let displayNameLabel: RegularCallout = .init({ $0.text = "Kabanbai batyr" })
    fileprivate let phoneNumberLabel: RegularFootnote = .init({ $0.text = "+ 7 777 777 77 77" })
    fileprivate let moneyAvatarView: UIImageView = .init({
        $0.contentMode = .center
        $0.image = UIImage.named("contact_file_icon")
    })
    
    override func setupView() {
        super.setupView()
        self.container.addSubview(displayNameLabel)
        self.container.addSubview(phoneNumberLabel)
        self.container.addSubview(moneyAvatarView)
    }

    override func setupConstraints() {
        
        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.right.lessThanOrEqualToSuperview().offset(-120)
        }
        
        self.displayNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kMediumPadding)
            make.left.equalToSuperview().offset(kMediumPadding)
        }
        
        self.phoneNumberLabel.snp.makeConstraints { make in
            make.bottom.equalTo(moneyAvatarView.snp.bottom)
            make.left.equalToSuperview().offset(kMediumPadding)
            make.top.equalTo(displayNameLabel.snp.bottom).offset(1)
        }

        self.moneyAvatarView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.top.equalToSuperview().offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalToSuperview().offset(-kMediumPadding)
            make.left.equalTo(displayNameLabel.snp.right).offset(kLowPadding)
        }

        self.deliveryDateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(phoneNumberLabel.snp.centerY)
            make.right.equalTo(moneyAvatarView.snp.left).offset(-kLowPadding)
            make.left.equalTo(phoneNumberLabel.snp.right).offset(kLowPadding / 2)
        }
    }

    override func setup(message: Message) {
        super.setup(message: message)
        self.phoneNumberLabel.text = message.contact.phone
        self.displayNameLabel.text = message.contact.displayName
        self.moneyAvatarView.loadImage(by: nil,placeholder: .initial(text: message.contact.displayName.initails))
        
    }
}

extension ContactMessage {
    var displayName: String{
        return [firstname, lastname].filter({!$0.isEmpty}).joined(separator: " ") 
    }
}
