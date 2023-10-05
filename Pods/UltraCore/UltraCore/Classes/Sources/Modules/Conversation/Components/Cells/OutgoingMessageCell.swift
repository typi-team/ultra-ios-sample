//
//  OutgoingMessageCell.swift
//  UltraCore
//
//  Created by Slam on 5/10/23.
//

import Foundation

class OutgoingMessageCell: BaseMessageCell {
    
    fileprivate let statusView: UIImageView = .init(image: UIImage.named("conversation_status_read"))
    
    override func setupView() {
        super.setupView()
        self.container.addSubview(statusView)
    }
    
    override func setupConstraints() {
        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.left.greaterThanOrEqualToSuperview().offset(kHeadlinePadding * 4)
        }

        self.textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(kLowPadding)
            make.bottom.equalToSuperview().offset(-kLowPadding)
        }

        self.statusView.snp.makeConstraints { make in
            make.left.equalTo(self.textView.snp.right).offset(kLowPadding / 2)
        }

        self.deliveryDateLabel.snp.makeConstraints { make in
            make.left.equalTo(self.statusView.snp.right).offset(kLowPadding / 2)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalTo(textView.snp.bottom)
            make.width.equalTo(40)
            make.centerY.equalTo(statusView.snp.centerY)
        }
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        self.statusView.image = .named(message.statusImageName)
    }
}


extension Message {
    var statusImageName: String {
        if self.seqNumber == 0 {
            return "conversation_status_loading"
        } else if self.state.delivered == false && self.state.read == false {
            return "conversation_status_sent"
        } else if self.state.delivered == true && self.state.read == false {
            return "conversation_status_delivered"
        } else {
            return "conversation_status_read"
        }
    }
}
