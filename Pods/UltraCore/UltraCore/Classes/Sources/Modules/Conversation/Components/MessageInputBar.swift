//
//  MessageInputBar.swift
//  UltraCore
//
//  Created by Slam on 4/25/23.
//

import Foundation

protocol MessageInputBarDelegate: AnyObject {
    func exchanges()
    func message(text: String)
    func typing(is active: Bool)
    func micro(isActivated: Bool)
    func pressedDone(in view: MessageInputBar)
    func pressedPlus(in view: MessageInputBar)
}

class MessageInputBar: UIView {

//    MARK: Static properties
    
    fileprivate var lastTypingDate: Date = .init()
    fileprivate let kTextFieldMaxHeight: CGFloat = 120
    fileprivate let kInputSendImage: UIImage? = .named("conversation_send")
    fileprivate let kInputPlusImage: UIImage? = .named("conversation_plus")
    fileprivate let kInputMicroImage: UIImage? = .named("message_input_micro")
    fileprivate let kInputExchangeImage: UIImage? = .named("message_input_exchange")
    
    private var divider: UIView = .init { $0.backgroundColor = UltraCoreStyle.divederColor.color }
    
    private let containerStack: UIStackView = .init {
        $0.axis = .horizontal
        $0.spacing = kMediumPadding
        $0.cornerRadius = kLowPadding
        $0.backgroundColor = .gray200
    }
    
    private lazy var messageTextView: UITextView = MessageTextView.init {[weak self] textView in
        textView.delegate = self
        textView.backgroundColor = .gray200
        textView.cornerRadius = kLowPadding
        textView.placeholder = "\(ConversationStrings.insertText.localized)..."
    }
    
    private lazy var sendButton: UIButton = .init {[weak self] button in
        guard let `self` = self else { return }
        button.setImage(self.kInputPlusImage, for: .normal)
        button.addAction {
            guard let message = self.messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                    !message.isEmpty else {
                self.delegate?.pressedPlus(in: self)
                return
            }
            self.messageTextView.text = ""
            self.delegate?.message(text: message)
            self.textViewDidChange(self.messageTextView)
        }
    }
    
    private lazy var exchangesButton: UIButton = .init {[weak self] button in
        guard let `self` = self else { return }
        button.setImage(self.kInputExchangeImage, for: .normal)
        button.addAction {
            self.delegate?.exchanges()
        }
    }
    
    private lazy var microButton: UIButton = .init {[weak self] button in
        guard let `self` = self else { return }
        button.setImage(self.kInputMicroImage, for: .normal)
        button.addAction(for: .touchDown, {
            self.delegate?.micro(isActivated: false)
        })
    }
    
//    MARK: Public properties
    
    weak var delegate: MessageInputBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        self.addSubview(divider)
        self.addSubview(sendButton)
        self.addSubview(containerStack)
        self.addSubview(exchangesButton)
        self.containerStack.addArrangedSubview(messageTextView)
        self.containerStack.addArrangedSubview(microButton)
        self.backgroundColor = UltraCoreStyle.controllerBackground.color
    }
    
    private func setupConstraints() {
        self.exchangesButton.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.width.equalTo(kHeadlinePadding * 2)
            make.leading.equalToSuperview().offset(kLowPadding)
            make.bottom.equalTo(messageTextView.snp.bottom)
        }

        self.divider.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(1)
        }

        self.containerStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kMediumPadding - 4)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 4))
            make.leading.equalTo(exchangesButton.snp.trailing).offset(kLowPadding)
        }

        self.messageTextView.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.left.equalToSuperview().offset(kLowPadding)
        }

        self.sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-kLowPadding)
            make.height.width.equalTo(36)
            make.bottom.equalTo(messageTextView.snp.bottom)
            make.left.equalTo(containerStack.snp.right).offset(kLowPadding)
        }
        
        self.microButton.snp.makeConstraints { make in
            make.width.equalTo(36)
            make.bottom.equalToSuperview()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.divider.backgroundColor = UltraCoreStyle.divederColor.color
        self.backgroundColor = UltraCoreStyle.inputMessageBarBackgroundColor.color
    }
}


extension MessageInputBar: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
       
        textView.snp.updateConstraints { make in
            make.height.equalTo(min(textView.heightOfInsertedText() + kLowPadding * 2 + 1, kTextFieldMaxHeight))
        }

        if let text = textView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.microButton.isHidden = true
            self.sendButton.setImage(self.kInputSendImage, for: .normal)
            
        } else {
            self.microButton.isHidden = false
            self.sendButton.setImage(self.kInputPlusImage, for: .normal)
        }

        if Date().timeIntervalSince(lastTypingDate) > kTypingMinInterval {
            self.lastTypingDate = Date()
            self.delegate?.typing(is: true)
        }
    }
}


extension UITextView {

    private class PlaceholderLabel: UILabel { }

    private var placeholderLabel: PlaceholderLabel {
        if let label = subviews.compactMap({ $0 as? PlaceholderLabel }).first {
            return label
        } else {
            let label = PlaceholderLabel(frame: .zero)
            label.font = font
            label.textColor = .gray500
            addSubview(label)
            label.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(4)
                make.right.equalToSuperview()
            }
            return label
        }
    }

    @IBInspectable
    var placeholder: String {
        get {
            return subviews.compactMap( { $0 as? PlaceholderLabel }).first?.text ?? ""
        }
        set {
            let placeholderLabel = self.placeholderLabel
            placeholderLabel.text = newValue
            placeholderLabel.numberOfLines = 0
            self.addSubview(placeholderLabel)
            textStorage.delegate = self
        }
    }

}

extension UITextView: NSTextStorageDelegate {

    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(.editedCharacters) {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
    
    func heightOfInsertedText() ->CGFloat {
        guard let text = text else { return 0.0 }
        let maxSize = CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]

        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font as Any]

        let boundingRect = (text as NSString).boundingRect(with: maxSize,
                                                           options: options,
                                                           attributes: attributes,
                                                           context: nil)

        return ceil(boundingRect.height)
    }
}


