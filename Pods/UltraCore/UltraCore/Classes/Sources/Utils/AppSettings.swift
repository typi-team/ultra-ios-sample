import NIO
import GRPC
import UIKit
import RxSwift
import NIOPosix
import PodAsset
import Logging

protocol AppSettings: Any {
    
    var superMessageSaverInteractor: UseCase<MessageData, Conversation?> { get }
    
    var appStore: AppSettingsStore { get set }
    
    var mediaRepository: MediaRepository { get }
    var updateRepository: UpdateRepository { get }
    var messageRespository: MessageRepository { get }
    var contactRepository: ContactsRepository { get }
    var conversationRespository: ConversationRepository { get }
    
    var contactDBService: ContactDBService { get }
    var messageDBService: MessageDBService { get }
    var conversationDBService: ConversationDBService { get }
    
    var callService: CallServiceClientProtocol { get }
    var userService: UserServiceClientProtocol { get }
    var fileService: FileServiceClientProtocol { get }
    var authService: AuthServiceClientProtocol { get }
    var deviceService: DeviceServiceClientProtocol { get }
    var messageService: MessageServiceClientProtocol { get }
    var contactsService: ContactServiceClientProtocol { get }
    var conversationService: ChatServiceClientProtocol { get }
    var integrateService: IntegrationServiceClientProtocol { get }
}
