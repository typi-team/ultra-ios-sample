//
//  MoneyTransferWireframe.swift
//  Pods
//
//  Created by Slam on 8/18/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

final class MoneyTransferWireframe: BaseWireframe<MoneyTransferViewController> {

    // MARK: - Private properties -
    fileprivate let moneyTransitioningDelegate = SheetTransitioningDelegate()
    // MARK: - Module setup -

    init(conversation: Conversation, moneyCallback: @escaping MoneyCallback) {
        let moduleViewController = MoneyTransferViewController()
        moduleViewController.modalPresentationStyle = .custom
        moduleViewController.transitioningDelegate = moneyTransitioningDelegate
    
        super.init(viewController: moduleViewController)

        let userId = self.appSettings.appStore.userID()

        let presenter = MoneyTransferPresenter(userID: userId,
                                               conversation: conversation,
                                               appStore: appSettings.appStore,
                                               view: moduleViewController,
                                               resultCallback: moneyCallback,
                                               wireframe: self,
                                               sendMoneyInteractor: SendMoneyInteractor())
        moduleViewController.presenter = presenter
    }

}

// MARK: - Extensions -

extension MoneyTransferWireframe: MoneyTransferWireframeInterface {
}
