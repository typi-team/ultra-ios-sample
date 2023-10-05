//
//  PermissionStateView.swift
//  UltraCore
//
//  Created by Slam on 5/22/23.
//

import UIKit

typealias VoidCallback = () -> Void

struct PermissionStateViewData {
    var imageName: String
    var headline: String
    var subline: String
    var action: VoidCallback?
}

class PermissionStateView: UIView {
    
    final let data: PermissionStateViewData
    
    init(data: PermissionStateViewData) {
        self.data = data
        super.init(frame: .zero)
        self.setupView()
        self.setupConstraints()
        self.setupData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var subline: RegularFootnote = .init({
        $0.textAlignment = .center
    })
    fileprivate lazy var imageView: UIImageView = .init()
    fileprivate lazy var headline: RegularBody = .init({
        $0.textAlignment = .center
        $0.font = .default(of: 13, and: .bold)
    })
    fileprivate lazy var button: ElevatedButton = .init()

    private func setupView() {
        self.addSubview(subline)
        self.addSubview(headline)
        self.addSubview(imageView)

        if let action = self.data.action {
            self.addSubview(button)
            self.button.addAction(action)
        }
    }
    
    private func setupConstraints() {
        self.imageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
        }
        
        self.headline.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset((kHeadlinePadding * 2) - 2)
            make.left.equalToSuperview().offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
        }
        
        self.subline.snp.makeConstraints { make in
            make.top.equalTo(headline.snp.bottom).offset(kMediumPadding)
            make.left.equalToSuperview().offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
        }
        
        if data.action != nil {
            self.button.snp.makeConstraints { make in
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottomMargin).offset(-kMediumPadding * 2)
                make.left.equalToSuperview().offset(kHeadlinePadding)
                make.right.equalToSuperview().offset(-kHeadlinePadding)
                make.height.equalTo(kButtonHeight)
            }
        }
    }
    
    func setupData() {
        self.headline.text = data.headline
        self.subline.text = data.subline
        self.imageView.image = .named(data.imageName)
        self.button.setTitle("Предоставить доступ", for: .normal)
    }
}
