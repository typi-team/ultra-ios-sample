//
//  OutcomeContactCell.swift
//  UltraCore
//
//  Created by Slam on 7/25/23.
//

import UIKit


class OutcomeContactCell : BaseMessageCell {
    
    fileprivate let statusView: UIImageView = .init(image: UIImage.named("conversation_status_read"))
    fileprivate let displayNameLabel: RegularCallout = .init({ $0.text = "Кабанбай батыр" })
    fileprivate let phoneLabel: RegularFootnote = .init({ $0.text = "+ 7 777 777 77 77" })
    fileprivate let contactImageView: UIImageView = .init({
        $0.image = UIImage.named("contact_file_icon")
        $0.contentMode = .center
    })
    
    override func setupView() {
        super.setupView()
        self.container.addSubview(displayNameLabel)
        self.container.addSubview(phoneLabel)
        self.container.addSubview(contactImageView)
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
        
        self.contactImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kMediumPadding)
            make.top.equalToSuperview().offset(kMediumPadding)
            make.bottom.equalToSuperview().offset(-kMediumPadding)
            make.width.height.equalTo(40)
        }
        
        self.displayNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kMediumPadding)
            make.left.equalTo(contactImageView.snp.right).offset(kMediumPadding)
            make.right.equalToSuperview().offset(kMediumPadding).offset(-kMediumPadding)
        }
        
        self.phoneLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contactImageView.snp.bottom)
            make.top.equalTo(displayNameLabel.snp.bottom).offset(1)
            make.left.equalTo(contactImageView.snp.right).offset(kMediumPadding)
        }

        self.statusView.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(self.phoneLabel.snp.right).offset(kLowPadding / 2)
            make.centerY.equalTo(phoneLabel.snp.centerY)
        }
        
        self.deliveryDateLabel.snp.makeConstraints { make in
            make.left.equalTo(self.statusView.snp.right).offset(kLowPadding / 2)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalTo(phoneLabel.snp.bottom)
            make.centerY.equalTo(statusView.snp.centerY)
        }
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        
        self.statusView.image = .named(message.statusImageName)
        
        self.phoneLabel.text = message.contact.phone
        self.displayNameLabel.text = message.contact.displayName
        self.contactImageView.loadImage(by: nil,placeholder: .initial(text: message.contact.displayName.initails))
    }
}
