//
//  MediaRepository.swift
//  UltraCore
//
//  Created by Slam on 6/6/23.
//

import UIKit
import RxSwift

protocol MediaRepository {
    
    var uploadingMedias: BehaviorSubject<[FileDownloadRequest]> { get set }
    var downloadingImages: BehaviorSubject<[FileDownloadRequest]> { get set }
    
    func mediaURL(from message: Message) -> URL?
    func isUploading(from message: Message) -> Bool
    func download(from message: Message) -> Single<Message>
    func image(from message: Message) -> UIImage?
    func upload(file: FileUpload, in conversation: Conversation) -> Single<MessageSendRequest>
}

class MediaRepositoryImpl {
    fileprivate let mediaUtils: MediaUtils
    fileprivate let appStore: AppSettingsStore
    fileprivate let messageDBService: MessageDBService
    fileprivate let fileService: FileServiceClientProtocol
    fileprivate let uploadFileInteractor: UseCase<[FileChunk], Void>
    fileprivate let createFileSpaceInteractor: UseCase<(data: Data, extens: String), [FileChunk]>
    
    var currentVoice: BehaviorSubject<[VoiceMessage]> = .init(value: [])
    var uploadingMedias: BehaviorSubject<[FileDownloadRequest]> = .init(value: [])
    var downloadingImages: BehaviorSubject<[FileDownloadRequest]> = .init(value: [])
    
    init(mediaUtils: MediaUtils,
         uploadFileInteractor: UseCase<[FileChunk], Void>,
         appStore: AppSettingsStore = AppSettingsImpl.shared.appStore,
         fileService: FileServiceClientProtocol = AppSettingsImpl.shared.fileService,
         messageDBService: MessageDBService = AppSettingsImpl.shared.messageDBService,
         createFileSpaceInteractor: UseCase<(data: Data, extens: String), [FileChunk]>) {
        
        self.appStore = appStore
        self.mediaUtils = mediaUtils
        self.fileService = fileService
        self.messageDBService = messageDBService
        self.uploadFileInteractor = uploadFileInteractor
        self.createFileSpaceInteractor = createFileSpaceInteractor
    }
}

extension MediaRepositoryImpl: MediaRepository {
    func mediaURL(from message: Message) -> URL? {
        return mediaUtils.mediaURL(from: message)
    }
    
    
    func isUploading(from message: Message) -> Bool {
        return try! self.uploadingMedias.value().contains(where: { $0.fileID == message.fileID })
    }

    func upload(file: FileUpload, in conversation: Conversation) -> Single<MessageSendRequest> {
        if file.mime.containsImage {
            return self.uploadImage(by: file, in: conversation)
        } else if file.mime.containsVideo {
            return self.uploadVideo(by: file, in: conversation)
        } else if file.mime.containsAudio{
            return self.uploadVoice(by: file, in: conversation)
        }else {
            return self.uploadFile(by: file, in: conversation)
        }
    }
    
    func image(from message: Message) -> UIImage? {
        return self.mediaUtils.image(from: message)
    }
    
    func download(from message: Message) -> Single<Message> {
        var inProgressValues = try! downloadingImages.value()
        guard let fileID = message.fileID,
              !inProgressValues.contains(where: {$0.fileID == fileID}) else {
            return Single.just(message)
        }

        let maxChunkSize = message.fileSize / (512 * 1024)
        
        return Single<Message>.create {[weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            var params = FileDownloadRequest.with({
                $0.fileID = fileID
                $0.fromChunkNumber = 0
                $0.toChunkNumber = maxChunkSize
            })

            var data: Data = .init()

            inProgressValues.append(params)
            self.downloadingImages.on(.next(inProgressValues))

            self.fileService
                .download(params, callOptions: .default(), handler: { chunk in
                    data.append(chunk.data)
                    params.fromChunkNumber = chunk.seqNum
                    PP.info((Float(params.fromChunkNumber) / Float(params.toChunkNumber)).description)
                    var images = try? self.downloadingImages.value()
                    images?.removeAll(where: {$0.fileID == chunk.fileID})
                    images?.append(params)
                    self.downloadingImages.on(.next(images ?? []))
                })
                .status
                .whenComplete {[weak self] result in
                    guard let `self` = self else { return observer(.failure(NSError.selfIsNill))}
                    switch result {
                    case .success:
                        do {
                            if message.hasVoice {
                                try self.mediaUtils.write(data, file: message.voice.originalVoiceFileId, and: message.voice.extensions)
                                params.fromChunkNumber = params.toChunkNumber
                                var images = try? self.downloadingImages.value()
                                images?.removeAll(where: { $0.fileID == params.fileID })
                                images?.append(params)
                                self.downloadingImages.on(.next(images ?? []))
                                observer(.success(message))
                            } else if message.hasPhoto {
                                try self.mediaUtils.write(data, file: message.photo.originalFileId, and: message.photo.extensions)
                                try self.mediaUtils.write(data, file: message.photo.previewFileId, and: message.photo.extensions)
                                
                                params.fromChunkNumber = params.toChunkNumber
                                var images = try? self.downloadingImages.value()
                                images?.removeAll(where: { $0.fileID == params.fileID })
                                images?.append(params)
                                self.downloadingImages.on(.next(images ?? []))
                                observer(.success(message))
                            } else if message.hasVideo {
                                Single<URL>
                                    .just(try self.mediaUtils.write(data, file: message.video.originalVideoFileId, and: message.video.extensions))
                                    .flatMap({ (url: URL) -> Single<Data> in self.mediaUtils.thumbnailData(in: url) })
                                    .map({ imageData in try self.mediaUtils.write(imageData, file: message.video.previewVideoFileId, and: "png")})
                                    .subscribe(onSuccess: {
                                        params.fromChunkNumber = params.toChunkNumber
                                        var images = try? self.downloadingImages.value()
                                        images?.removeAll(where: { $0.fileID == params.fileID })
                                        images?.append(params)
                                        self.downloadingImages.on(.next(images ?? []))
                                        observer(.success(message))
                                    })
                                    .dispose()
                                return
                            } else if message.hasFile {
                                try self.mediaUtils.write(data, file: message.file.originalFileId, and: message.file.extensions)
                                
                                params.fromChunkNumber = params.toChunkNumber
                                var images = try? self.downloadingImages.value()
                                images?.removeAll(where: { $0.fileID == params.fileID })
                                images?.append(params)
                                self.downloadingImages.on(.next(images ?? []))
                                observer(.success(message))
                            }
                        } catch {
                            observer(.failure(error))
                        }
                    case let .failure(error):
                        observer(.failure(error))
                    }
                }

            return Disposables.create()
        }
    }
}

private extension MediaRepositoryImpl {
    
    func uploadImage(by file: FileUpload, in conversation: Conversation) -> Single<MessageSendRequest> {

        var message = self.mediaUtils.createMessageForUpload(in: conversation, with: appStore.userID())
        message.photo = .with({ photo in
            photo.fileName = ""
            photo.fileSize = Int64(file.data.count)
            photo.mimeType = file.mime
            photo.height = Int32(file.height)
            photo.width = Int32(file.width)
        })

        return self.createFileSpaceInteractor.executeSingle(params: (file.data, message.photo.mimeType))
            .do(onSuccess: { [weak self] chunks in
                guard let `self` = self else { return }
                var images = try self.uploadingMedias.value()
                images.append(FileDownloadRequest.with({
                    $0.fileID = chunks.first?.fileID ?? ""
                    $0.fromChunkNumber = 0
                    $0.toChunkNumber = Int64(chunks.count)
                }))
                self.uploadingMedias.on(.next(images))
            })
            .do(onSuccess: { [weak self] chunks in
                guard let `self` = self else { throw NSError.selfIsNill }
                message.photo.fileID = chunks.first?.fileID ?? ""
                try self.mediaUtils.write(file.data, file: message.photo.originalFileId, and: message.photo.extensions)
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.fromChunkNumber = file.toChunkNumber - ((file.toChunkNumber * 80) / 100)
                self.uploadingMedias.on(.next(process))
            })
            .flatMap({ [weak self] response -> Single<[FileChunk]> in
                guard let `self` = self else { throw NSError.selfIsNill }
                return self.messageDBService.save(message: message).map({ response })
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.fromChunkNumber = file.toChunkNumber - ((file.toChunkNumber * 60) / 100)
                self.uploadingMedias.on(.next(process))
            })
            .flatMap({ [weak self] response -> Single<Void> in
                guard let `self` = self else {
                    throw NSError.selfIsNill
                }
                return self.uploadFileInteractor.executeSingle(params: response)
            })
                
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.fromChunkNumber = file.toChunkNumber - ((file.toChunkNumber * 80) / 100)
                self.uploadingMedias.on(.next(process))
            })
            .map({ _ -> MessageSendRequest in
                MessageSendRequest.with({ req in
                    req.peer.user = .with({ peer in
                        peer.userID = conversation.peer?.userID ?? "u1FNOmSc0DAwM"
                    })
                    req.message = message
                })
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self, var process = try? self.uploadingMedias.value() else { return }
                process.removeAll(where: { $0.fileID == message.photo.fileID })
                self.uploadingMedias.on(.next(process))
            }, onError: {[weak self] (error: Error) in
                PP.warning(error.localizedDescription)
                guard let `self` = self, var process = try? self.uploadingMedias.value() else { return }
                process.removeAll(where: { $0.fileID == message.photo.fileID })
                self.uploadingMedias.on(.next(process))
            })
    }
    
    func uploadFile(by file: FileUpload, in conversation: Conversation) -> Single<MessageSendRequest> {

        var message = self.mediaUtils.createMessageForUpload(in: conversation, with: appStore.userID())
        message.file = .with({ photo in
            photo.mimeType = file.mime
            photo.fileSize = Int64(file.data.count)
            photo.fileName = file.url?.pathComponents.last ?? " "
        })

        return self.createFileSpaceInteractor.executeSingle(params: (file.data, file.mime))
            .do(onSuccess: { [weak self] chunks in
                guard let `self` = self else { return }
                var images = try self.uploadingMedias.value()
                images.append(FileDownloadRequest.with({
                    $0.fileID = chunks.first?.fileID ?? ""
                    $0.fromChunkNumber = 0
                    $0.toChunkNumber = Int64(chunks.count)
                }))
                self.uploadingMedias.on(.next(images))
            })
            .map({ [weak self] chunks in
                guard let `self` = self else { throw NSError.selfIsNill }
                message.file.fileID = chunks.first?.fileID ?? ""

                try self.mediaUtils.write(file.data, file: message.file.originalFileId, and: message.file.extensions)
                return chunks
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.fromChunkNumber = file.toChunkNumber - ((file.toChunkNumber * 80) / 100)
                self.uploadingMedias.on(.next(process))
            })
            .flatMap({ [weak self] response -> Single<[FileChunk]> in
                guard let `self` = self else { throw NSError.selfIsNill }
                return self.messageDBService.save(message: message).map({ response })
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.fromChunkNumber = file.toChunkNumber - ((file.toChunkNumber * 60) / 100)
                self.uploadingMedias.on(.next(process))
            })
            .flatMap({ [weak self] response -> Single<Void> in
                guard let `self` = self else {
                    throw NSError.selfIsNill
                }
                return self.uploadFileInteractor.executeSingle(params: response)
            })
                
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.fromChunkNumber = file.toChunkNumber - ((file.toChunkNumber * 80) / 100)
                self.uploadingMedias.on(.next(process))
            })
            .map({ _ -> MessageSendRequest in
                MessageSendRequest.with({ req in
                    req.peer.user = .with({ peer in
                        peer.userID = conversation.peer?.userID ?? "u1FNOmSc0DAwM"
                    })
                    req.message = message
                })
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self, var process = try? self.uploadingMedias.value() else { return }
                process.removeAll(where: { $0.fileID == message.photo.fileID })
                self.uploadingMedias.on(.next(process))
            }, onError: {[weak self] (error: Error) in
                PP.warning(error.localizedDescription)
                guard let `self` = self, var process = try? self.uploadingMedias.value() else { return }
                process.removeAll(where: { $0.fileID == message.photo.fileID })
                self.uploadingMedias.on(.next(process))
            })
    }
    
    func uploadVideo(by file: FileUpload, in conversation: Conversation) -> Single<MessageSendRequest> {

        guard let url = file.url else { return Single.error(NSError.objectsIsNill )}
        var message = self.mediaUtils.createMessageForUpload(in: conversation, with: appStore.userID())
        
        message.video = .with({ photo in
            photo.fileName = ""
            photo.fileSize = Int64(file.data.count)
            photo.mimeType = file.mime
            photo.height = Int32(file.height)
            photo.width = Int32(file.width)
        })
        
        
        var thumbnailData: Data = .init()

        return self.mediaUtils.thumbnailData(in: url)
            
                .do(onSuccess: {thumbnailData = $0 })
                    .flatMap({data -> Single<[FileChunk]> in
                        return self.createFileSpaceInteractor.executeSingle(params: (data: data, extens: "image/png"))})
                    .do(onSuccess: { chunks in
                        message.video.thumbFileID = chunks.first?.fileID ?? ""
                    })
                    .flatMap({ chunks in
                        return self.uploadFileInteractor.executeSingle(params: chunks)
                    })
                        
            .flatMap {[weak self] _ -> Single<[FileChunk]> in
                guard let `self` = self else { throw NSError.selfIsNill }
                return self.createFileSpaceInteractor
                    .executeSingle(params: (file.data, message.video.mimeType))
            }
            .do(onSuccess: {[weak self] chunks in
                message.video.fileID = chunks.first?.fileID ?? ""
                try self?.mediaUtils.write(thumbnailData, file: message.video.previewVideoFileId, and: "png")
            })
            .do(onSuccess: { [weak self] chunks in
                guard let `self` = self else { return }
                var images = try self.uploadingMedias.value()
                images.append(FileDownloadRequest.with({
                    $0.fileID = chunks.first?.fileID ?? ""
                    $0.fromChunkNumber = 0
                    $0.toChunkNumber = Int64(chunks.count)
                }))
                self.uploadingMedias.on(.next(images))
            })
            .do( onSuccess: { [weak self] chunks in
                guard let `self` = self else { throw NSError.selfIsNill }
                message.video.fileID = chunks.first?.fileID ?? ""
                try self.mediaUtils.write(file.data, file: message.video.originalVideoFileId, and: message.video.extensions)
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.toChunkNumber = file.toChunkNumber / 10
                self.uploadingMedias.on(.next(process))
            })
            .flatMap({ [weak self] response -> Single<[FileChunk]> in
                guard let `self` = self else { throw NSError.selfIsNill }
                return self.messageDBService.save(message: message).map({ response })
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.toChunkNumber = file.toChunkNumber / 40
                self.uploadingMedias.on(.next(process))
            })
            .flatMap({ [weak self] response -> Single<Void> in
                guard let `self` = self else {
                    throw NSError.selfIsNill
                }
                return self.uploadFileInteractor.executeSingle(params: response)
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.toChunkNumber = file.toChunkNumber
                self.uploadingMedias.on(.next(process))
            })
            .map({ _ -> MessageSendRequest in
                return MessageSendRequest.with({ req in
                    req.peer.user = .with({ peer in
                        peer.userID = conversation.peer?.userID ?? "u1FNOmSc0DAwM"
                    })
                    req.message = message
                })
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self, var process = try? self.uploadingMedias.value() else { return }
                process.removeAll(where: { $0.fileID == message.fileID })
                self.uploadingMedias.on(.next(process))
            })
    }
    
    func uploadVoice(by file: FileUpload, in conversation: Conversation) -> Single<MessageSendRequest> {

        var message = self.mediaUtils.createMessageForUpload(in: conversation, with: appStore.userID())
        
        message.voice = .with({ photo in
            photo.mimeType = file.mime
            photo.duration = file.duration.nanosec
            photo.fileSize = Int64(file.data.count)
            photo.fileName = file.url?.lastPathComponent ?? ""
        })

        return self.createFileSpaceInteractor
            .executeSingle(params: (file.data, message.voice.mimeType))
            .do(onSuccess: { [weak self] chunks in
                guard let `self` = self else { return }
                var images = try self.uploadingMedias.value()
                images.append(FileDownloadRequest.with({
                    $0.fileID = chunks.first?.fileID ?? ""
                    $0.fromChunkNumber = 0
                    $0.toChunkNumber = Int64(chunks.count)
                }))
                self.uploadingMedias.on(.next(images))
            })
            .map({ [weak self] chunks in
                guard let `self` = self else { throw NSError.selfIsNill }
                message.voice.fileID = chunks.first?.fileID ?? ""
                try self.mediaUtils.write(file.data, file: message.voice.originalVoiceFileId, and: message.voice.extensions)
                return chunks
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.fromChunkNumber = file.toChunkNumber - ((file.toChunkNumber * 80) / 100)
                self.uploadingMedias.on(.next(process))
            })
            .flatMap({ [weak self] response -> Single<[FileChunk]> in
                guard let `self` = self else { throw NSError.selfIsNill }
                return self.messageDBService.save(message: message).map({ response })
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.fromChunkNumber = file.toChunkNumber - ((file.toChunkNumber * 60) / 100)
                self.uploadingMedias.on(.next(process))
            })
            .flatMap({ [weak self] response -> Single<Void> in
                guard let `self` = self else {
                    throw NSError.selfIsNill
                }
                return self.uploadFileInteractor.executeSingle(params: response)
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self,
                      let process = try? self.uploadingMedias.value(),
                      var file = process.first(where: { $0.fileID == message.fileID }) else { return }
                file.fromChunkNumber = file.toChunkNumber - ((file.toChunkNumber * 80) / 100)
                self.uploadingMedias.on(.next(process))
            })
            .map({ _ -> MessageSendRequest in
                MessageSendRequest.with({ req in
                    req.peer.user = .with({ peer in
                        peer.userID = conversation.peer?.userID ?? "u1FNOmSc0DAwM"
                    })
                    req.message = message
                })
            })
            .do(onSuccess: { [weak self] _ in
                guard let `self` = self, var process = try? self.uploadingMedias.value() else { return }
                process.removeAll(where: { $0.fileID == message.photo.fileID })
                self.uploadingMedias.on(.next(process))
            }, onError: {[weak self] (error: Error) in
                
                PP.warning(error.localizedDescription)
                guard let `self` = self, var process = try? self.uploadingMedias.value() else { return }
                process.removeAll(where: { $0.fileID == message.photo.fileID })
                self.uploadingMedias.on(.next(process))
            })
    }
}

