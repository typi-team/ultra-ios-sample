//
//  AdditioanalController.swift
//  UltraCore
//
//  Created by Slam on 7/3/23.
//

import UIKit

enum AdditioanalAction {
    case money_tranfer
}

class AdditioanalController: BaseViewController<String> {
    
    var resultCallback: ((AdditioanalAction) -> Void)?

    fileprivate let headlineLabel: HeadlineBody = .init({
        $0.textAlignment = .left
        $0.text = ConversationStrings.send.localized
    })

    fileprivate lazy var paymentButton: TextButton = .init({
        $0.titleLabel?.numberOfLines = 0
        
        $0.addAction { [weak self] in
            guard let `self` = self else { return }
            self.handle(action: .money_tranfer)
        }
        
        $0.setImage(.named("conversation_money_logo_icon"), for: .normal)
    })

    fileprivate lazy var stackView: UIStackView = .init {
        $0.axis = .vertical
        $0.spacing = kLowPadding
        $0.addArrangedSubview(headlineLabel)
        $0.setCustomSpacing(kHeadlinePadding, after: headlineLabel)
        $0.addArrangedSubview(paymentButton)
    }
    
    override func setupViews() {
        super.setupViews()
        self.view.addSubview(stackView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kHeadlinePadding + kMediumPadding)
            make.left.equalToSuperview().offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(-kLowPadding)
        }
    }
    
    func _buildPaymentDescription() {
        let boldFontAttributes: [NSAttributedString.Key: Any] = [.font: UltraCoreStyle.textButtonConfig.font,
                                                                 .foregroundColor: UltraCoreStyle.textButtonConfig.color]
        let smallFontAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.defaultRegularFootnote,
                                                                  .foregroundColor: UIColor.gray500]

        let boldText = ConversationStrings.insideTheBank.localized
        let smallText = ConversationStrings.sendToBankCustomer.localized
        let titleText = "\(boldText)\n\(smallText)"

        let attributedTitle = NSMutableAttributedString(string: titleText)
        attributedTitle.addAttributes(boldFontAttributes, range: NSRange(location: 0, length: boldText.count))
        attributedTitle.addAttributes(smallFontAttributes, range: NSRange(location: boldText.count + 1, length: smallText.count))
        self.paymentButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self._buildPaymentDescription()
    }
}

private extension AdditioanalController {
    func handle(action: AdditioanalAction) {
        self.dismiss(animated: true, completion: {
            self.resultCallback?(action)
        })
    }
}

