//
//  IncomingMediaCell.swift
//  UltraCore
//
//  Created by Slam on 6/6/23.
//

import UIKit

class IncomingPhotoCell: MediaCell {
    
    override func setupView() {
        self.contentView.addSubview(container)
        self.backgroundColor = .clear
        self.container.addSubview(mediaView)
        self.container.addSubview(playView)
        self.container.addSubview(downloadProgress)
        self.container.addSubview(deliveryWrapper)
        self.deliveryWrapper.addSubview(deliveryDateLabel)
        self.additioanSetup()
    }
    
    override func setupConstraints() {

        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.right.lessThanOrEqualToSuperview().offset(-120)
        }

        self.mediaView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.constants.maxWidth)
            make.height.equalTo(self.constants.maxHeight)
        }
        
        self.downloadProgress.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(5)
        }

        self.deliveryWrapper.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-kLowPadding)
            make.right.equalToSuperview().offset(-(kLowPadding + 1))
        }
        
        self.deliveryDateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kLowPadding / 2)
            make.top.equalToSuperview().offset(kLowPadding / 2)
            make.right.equalToSuperview().offset(-(kLowPadding / 2))
            make.bottom.equalToSuperview().offset(-(kLowPadding / 2))
        }
        
        self.playView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(kHeadlinePadding * 2)
        }
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        self.mediaView.image = UIImage.init(data: message.photo.preview)
        if let image = self.mediaRepository.image(from: message) {
            self.mediaView.image = image
        } else {
            self.dowloadImage(by: message)
        }
    }
}


class IncomingVideoCell: IncomingPhotoCell {
    override func setup(message: Message) {
        super.setup(message: message)
        self.playView.isHidden = !message.hasVideo
        self.mediaView.image = UIImage.init(data: message.video.thumbPreview)
        if let image = self.mediaRepository.image(from: message) {
            self.mediaView.image = image
            self.playView.isHidden = !message.hasVideo
        } else {
            self.dowloadImage(by: message)
        }
    }
}
