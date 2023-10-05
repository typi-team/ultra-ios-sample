//
//  BaseMessageCell.swift
//  UltraCore
//
//  Created by Slam on 4/26/23.
//

import UIKit
import RxSwift


struct MediaMessageConstants {
    let maxWidth: CGFloat
    let maxHeight: CGFloat
}

class BaseMessageCell: BaseCell {
    var message: Message?
    var actionCallback: ((Message) -> Void)?
    var longTapCallback:((Message) -> Void)?
    lazy var disposeBag: DisposeBag = .init()
    lazy var constants: MediaMessageConstants = .init(maxWidth: 300, maxHeight: 200)
    
    let textView: SubHeadline = .init({
        $0.numberOfLines = 0
    })
    
    let deliveryDateLabel: RegularFootnote = .init({
        $0.textAlignment = .right
    })
    
    let container: UIView = .init({
        $0.cornerRadius = 18
        $0.backgroundColor = .white
    })
    
    override func setupView() {
        super.setupView()
        self.contentView.addSubview(container)
        self.backgroundColor = .clear
        self.container.addSubview(textView)
        self.container.addSubview(deliveryDateLabel)
        
        self.additioanSetup()
    }
    
    override func additioanSetup() {
        super.additioanSetup()
        
        self.selectionStyle = .gray
        let longTap = UILongPressGestureRecognizer.init(target: self, action: #selector(self.handleLongPress(_:)))
        longTap.minimumPressDuration = 0.3
        self.container.addGestureRecognizer(longTap)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapPress(_:)))
        self.container.addGestureRecognizer(tap)
        
        self.selectedBackgroundView = UIView({
            $0.backgroundColor = .clear
        })
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.right.lessThanOrEqualToSuperview().offset(-120)
        }

        self.textView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kLowPadding)
            make.left.equalToSuperview().offset(kLowPadding + 2)
            make.bottom.equalToSuperview().offset(-kLowPadding)
        }

        self.deliveryDateLabel.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.bottom.equalTo(textView.snp.bottom)
            make.right.equalToSuperview().offset(-(kLowPadding + 1))
            make.left.equalTo(textView.snp.right).offset(kMediumPadding - 5)
        }
    }
    
    func setup(message: Message) {
        self.message = message
        self.textView.text = message.text
        self.deliveryDateLabel.text = message.meta.created.dateBy(format: .hourAndMinute)
        self.traitCollectionDidChange(UIScreen.main.traitCollection)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let message = message {
            if message.isIncome {
                self.container.backgroundColor = UltraCoreStyle.incomeMessageCell.backgroundColor.color
            } else {
                self.container.backgroundColor = UltraCoreStyle.outcomeMessageCell.backgroundColor.color
            }
        } else {
            self.container.backgroundColor = UltraCoreStyle.incomeMessageCell.backgroundColor.color
        }
    }
}

extension BaseMessageCell {
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        guard let message = self.message, sender.state == .began else {
            return
        }
        
        self.longTapCallback?(message)
     }
    
    @objc func handleTapPress(_ sender: UILongPressGestureRecognizer) {
        guard let message = self.message else {
            return
        }
        self.actionCallback?(message)
     }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.container.isUserInteractionEnabled = !editing
        self.contentView.isUserInteractionEnabled = !editing
    }
}
