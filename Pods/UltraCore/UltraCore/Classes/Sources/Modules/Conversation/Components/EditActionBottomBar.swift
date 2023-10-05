//
//  EditActionBottomBar.swift
//  UltraCore
//
//  Created by Slam on 7/17/23.
//

import Foundation
protocol EditActionBottomBarDelegate: AnyObject {
    func delete()
    func cancel()
}

class EditActionBottomBar: UIView {
    
    weak var delegate:EditActionBottomBarDelegate?
    
    fileprivate lazy var stackView: UIStackView = .init({
        $0.axis = .horizontal
        $0.spacing = kHeadlinePadding
        $0.distribution = .fillEqually
    })
    
    fileprivate lazy var deleteButton: UIButton = .init({
        $0.setTitle("Удалить", for: .normal)
        $0.titleLabel?.font = .defaultRegularCallout
        $0.setTitleColor(.red500, for: .normal)
        $0.addAction {[weak self] in
            guard let `self` = self else {
                 return
            }
            self.delegate?.delete()
        }
    })
    
    fileprivate lazy var cancelButton: UIButton = .init({
        $0.setTitle("Отменить", for: .normal)
        $0.titleLabel?.font = .defaultRegularCallout
        $0.setTitleColor(.gray900, for: .normal)
        $0.addAction {[weak self] in
            guard let `self` = self else {
                 return
            }
            self.delegate?.cancel()
        }
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
        self.setupConstraints()
    }
}

private extension EditActionBottomBar {
    func setupViews() {
        self.addSubview(stackView)
        self.backgroundColor = .gray100
        self.stackView.addArrangedSubview(self.deleteButton)
        self.stackView.addArrangedSubview(self.cancelButton)
    }
    
    func setupConstraints() {
        self.stackView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }
}
