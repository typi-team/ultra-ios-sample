//
//  ContactCell.swift
//  UltraCore
//
//  Created by Slam on 4/21/23.
//

import UIKit

class ContactCell: BaseCell {

    fileprivate let titleLabel: RegularBody = .init({
        $0.font = .default(of: 14)
    })
    fileprivate let subLabel: RegularFootnote = .init({
        $0.font = .default(of: 12)
    })

    fileprivate let avatarImageView: UIImageView = .init()

    override func setupView() {
        super.setupView()
        self.contentView.addSubview(self.subLabel)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.avatarImageView)
    }

    override func setupConstraints() {
        super.setupConstraints()
        self.avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kLowPadding)
            make.width.height.equalTo((kMediumPadding * 2) + 2)
            make.bottom.equalToSuperview().offset(-kLowPadding)
            make.left.equalToSuperview().offset(kMediumPadding)
        }

        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.top)
            make.right.equalToSuperview().offset(-kHeadlinePadding)
            make.left.equalTo(avatarImageView.snp.right).offset(kMediumPadding - 4)
        }

        self.subLabel.snp.makeConstraints { make in
            make.bottom.equalTo(avatarImageView.snp.bottom)
            make.right.equalToSuperview().offset(-kHeadlinePadding)
            make.top.equalTo(titleLabel.snp.bottom).offset(kLowPadding / 2)
            make.left.equalTo(avatarImageView.snp.right).offset(kMediumPadding - 4)
        }
    }

    func setup(contact: ContactDisplayable) {
        if self.avatarImageView.borderColor != .green500 {
            self.avatarImageView.borderWidth = 2
            self.avatarImageView.cornerRadius = 17
            self.avatarImageView.borderColor = .green500
            self.avatarImageView.contentMode = .scaleAspectFit
        }
        self.avatarImageView.config(contact: contact)
        self.titleLabel.text = contact.displaName
        self.subLabel.textColor = contact.status.color
        self.subLabel.text = contact.status.displayText
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatarImageView.image = nil
        self.subLabel.textColor = .gray500
    }
}
