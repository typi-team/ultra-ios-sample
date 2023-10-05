//
//  IncomingCallWireframe.swift
//  Pods
//
//  Created by Slam on 9/4/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

final class IncomingCallWireframe: BaseWireframe<IncomingCallViewController> {

    // MARK: - Private properties -

    // MARK: - Module setup -

    init(call status: CallStatus) {
        let moduleViewController = IncomingCallViewController()
        super.init(viewController: moduleViewController)

        let presenter = IncomingCallPresenter.init(userId: appSettings.appStore.userID(),
                                                   callInformation: status,
                                                   view: moduleViewController,
                                                   contactService: appSettings.contactDBService,
                                                   callService: appSettings.callService,
                                                   wireframe: self,
                                                   contactInteractor: .init(contactsService: appSettings.contactsService))
        moduleViewController.presenter = presenter
    }

}

// MARK: - Extensions -

extension IncomingCallWireframe: IncomingCallWireframeInterface {
}
