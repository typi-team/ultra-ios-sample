//
//  AppSettingsImpl.swift
//  UltraCore
//
//  Created by Slam on 7/30/23.
//

import NIO
import GRPC
import UIKit
import RxSwift
import NIOPosix
import PodAsset
import Logging

open class AppSettingsImpl: AppSettings  {
    
    static let shared = AppSettingsImpl()

//    MARK: Public properties

    lazy var serverConfig: ServerConfigurationProtocol = {
        return UltraCoreSettings.delegate?.serverConfig() ?? ServerConfiguration()
    }()

//    MARK: Local Singletone properties
    lazy var mediaUtils: MediaUtils = .init()
    lazy var podAsset = PodAsset.bundle(forPod: "UltraCore")
    lazy var version: String = podAsset?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.2"
    
    lazy var channel: GRPCChannel = try! GRPCChannelPool.with(target: .host(serverConfig.pathToServer,
                                                                            port: serverConfig.portOfServer),
                                                              transportSecurity: .tls(.makeClientConfigurationBackedByNIOSSL()), eventLoopGroup: PlatformSupport.makeEventLoopGroup(compatibleWith: .makeClientConfigurationBackedByNIOSSL(), loopCount: 1))
    lazy var fileChannel: GRPCChannel = try! GRPCChannelPool.with(target: .host(serverConfig.pathToServer,
                                                                               port: serverConfig.portOfServer),
                                                                 transportSecurity: .tls(.makeClientConfigurationBackedByNIOSSL()), eventLoopGroup: PlatformSupport.makeEventLoopGroup(compatibleWith: .makeClientConfigurationBackedByNIOSSL(), loopCount: 1))

    lazy var updateChannel: GRPCChannel = try! GRPCChannelPool.with(target: .host(serverConfig.pathToServer,
                                                                                  port: serverConfig.portOfServer),
                                                                    transportSecurity: .tls(.makeClientConfigurationBackedByNIOSSL()), eventLoopGroup: PlatformSupport.makeEventLoopGroup(compatibleWith: .makeClientConfigurationBackedByNIOSSL(), loopCount: 1))

//    MARK: GRPC Services
    lazy var callService: CallServiceClientProtocol = CallServiceNIOClient(channel: channel)
    lazy var userService: UserServiceClientProtocol = UserServiceNIOClient(channel: channel)
    lazy var authService: AuthServiceClientProtocol = AuthServiceNIOClient(channel: channel)
    lazy var fileService: FileServiceClientProtocol = FileServiceNIOClient(channel: fileChannel)
    lazy var deviceService: DeviceServiceClientProtocol = DeviceServiceNIOClient(channel: channel)
    lazy var messageService: MessageServiceClientProtocol = MessageServiceNIOClient(channel: channel)
    lazy var contactsService: ContactServiceClientProtocol = ContactServiceNIOClient(channel: channel)
    lazy var updateService: UpdatesServiceClientProtocol = UpdatesServiceNIOClient(channel: updateChannel)
    lazy var conversationService: ChatServiceClientProtocol = ChatServiceNIOClient.init(channel: channel)
    lazy var integrateService: IntegrationServiceClientProtocol = IntegrationServiceNIOClient.init(channel: channel, defaultCallOptions: .default())

//    MARK: Services

    lazy var messageDBService: MessageDBService = .init(userId: appStore.userID())
    lazy var appStore: AppSettingsStore = AppSettingsStoreImpl()
    lazy var contactDBService: ContactDBService = .init(userID: appStore.userID())
    lazy var conversationDBService: ConversationDBService = .init(userID: appStore.userID())

//    MARK: Repositories

    lazy var voiceRepository: VoiceRepository = VoiceRepository.init(mediaUtils: mediaUtils)
    lazy var mediaRepository: MediaRepository = MediaRepositoryImpl(mediaUtils: mediaUtils,
                                                                    uploadFileInteractor: UploadFileInteractor(fileService: fileService),
                                                                    fileService: fileService,
                                                                    createFileSpaceInteractor: CreateFileInteractor(fileService: fileService))
    lazy var contactRepository: ContactsRepository = ContactsRepositoryImpl(contactDBService: contactDBService)
    lazy var messageRespository: MessageRepository = MessageRespositoryImpl(messageService: messageDBService)
    lazy var updateRepository: UpdateRepository = UpdateRepositoryImpl.init(appStore: appStore,
                                                                            messageService: messageDBService,
                                                                            contactService: contactDBService,
                                                                            update: updateService,
                                                                            conversationService: conversationDBService,
                                                                            userByIDInteractor: ContactByUserIdInteractor.init(contactsService: contactsService),
                                                                            deliveredMessageInteractor: DeliveredMessageInteractor.init(messageService: messageService))
    lazy var conversationRespository: ConversationRepository = ConversationRepositoryImpl(conversationService: conversationDBService)
    
    //    MARK: App main interactors, must be create once
    
    lazy var superMessageSaverInteractor: UseCase<MessageData, Conversation?> = SuperMessageSaverInteractor.init(appStore: appStore,
                                                                                                                 contactDBService: contactDBService,
                                                                                                                 messageDBService: messageDBService,
                                                                                                                 conversationDBService: conversationDBService,
                                                                                                                 messageService: messageService,
                                                                                                                 contactsService: contactsService)
    
    
    func update(ssid: String, callback: @escaping (Error?) -> Void) {
        let localService = JWTTokenInteractorImpl(authService: authService)
        _ = localService.executeSingle(params: .with({
            $0.device = .ios
            $0.sessionID = ssid
            $0.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Ну указано"
        }))
            .do(onSuccess: { [weak self] response in
                guard let `self` = self else { return }
                self.appStore.store(token: response.token)
                self.appStore.store(userID: response.userID)
            }, onError: { callback($0) })
            .do(onSuccess: { _ in callback(nil) })
            .subscribe()
    }
}

