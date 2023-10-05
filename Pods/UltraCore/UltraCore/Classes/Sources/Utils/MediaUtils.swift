//
//  MediaUtils.swift
//  UltraCore
//
//  Created by Slam on 6/10/23.
//


import UIKit
import RxSwift
import AVFoundation
import MobileCoreServices

class MediaUtils {
    static func image(from contact: ContactDisplayable) -> UIImage? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = documentsDirectory.appendingPathComponent(contact.imagePath)
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func image(from message: Message) -> UIImage? {
        guard let data = try? readFileWithName(fileName: message.hasPhoto ? message.photo.originalFileIdWithExtension : message.video.previewVideoFileIdWithExtension) else { return nil }
        return UIImage(data: data)
    }
    
    func createMessageForUpload(in conversation: Conversation, with userID: String) -> Message {
        return Message.with { mess in
            mess.receiver = .with({ receiver in
                receiver.chatID = conversation.idintification
                receiver.userID = conversation.peer?.userID ?? ""
            })
            mess.meta = .with { $0.created = Date().nanosec }
            mess.sender = .with { $0.userID = userID }
            mess.id = UUID().uuidString
        }
    }
    
    @discardableResult
    func write(_ data: Data, file path: String, and extension: String) throws -> URL {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(path).appendingPathExtension(`extension`)
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }
    
    func readFileWithName(fileName: String) throws -> Data? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        let data = try Data(contentsOf: fileURL)
        return data
    }
    
    func thumbnailData(in url: URL) -> Single<Data> {
        return self.thumbnail(in: url)
            .map({ $0.downsample(reductionAmount: 0.4)?
                .compress(.medium) ?? Data() })
    }
    
    func thumbnail(in url: URL) -> Single<UIImage> {
        return Single.create { observer -> Disposable in
            do {
                let asset = AVURLAsset(url: url)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                
                let cgImage = try imageGenerator.copyCGImage(at: CMTime.zero,
                                                             actualTime: nil)
                observer(.success(UIImage.init(cgImage: cgImage)))
            }catch {
                observer(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func mediaURL(from message: Message) -> URL? {
        guard let originalFileIdWithExtension = message.originalFileIdWithExtension else { return nil }
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(originalFileIdWithExtension)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL
        } else {
            PP.warning("Файл с именем \(originalFileIdWithExtension) не найден.")
            return nil
        }
    }
}

typealias MimeType = String

extension URL {
    func mimeType() -> MimeType {
        let pathExtension = self.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as MimeType
            }
        }
        return "application/octet-stream" as MimeType
    }
}

extension MimeType {
    var containsImage: Bool {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, self as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeImage)
    }

    var containsAudio: Bool {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, self as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeAudio)
    }

    var containsVideo: Bool {
        
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, self as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeMovie)
    }
    
    var containsVoice: Bool {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, self as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeAudio)
    }
}

extension Message {
    var originalFileIdWithExtension: String? {
        if hasPhoto {
            return photo.originalFileIdWithExtension
        } else if hasVideo {
            return video.originalVideoFileIdWithExtension
        } else if hasFile {
            return file.originalFileIdWithExtension
        } else if hasVoice {
            return voice.originalFileIdWithExtension
        } else {
            return nil
        }
    }
}

extension VideoMessage {
    var extensions:String { mimeType.components(separatedBy: "/").last ?? ""}
    
    var previewVideoFileId: String { "preview_video_\(fileID)" }
    var originalVideoFileId: String { "original_video_\(fileID)" }
    
    var previewVideoFileIdWithExtension: String { "preview_video_\(fileID).png" }
    var originalVideoFileIdWithExtension: String { "original_video_\(fileID).\(extensions)" }
}

extension VoiceMessage {
    var extensions:String { mimeType.components(separatedBy: "/").last ?? ""}
    var originalVoiceFileId: String { "original_voice\(fileID)" }
    var originalFileIdWithExtension: String { "\(originalVoiceFileId).\(extensions)" }
}

extension PhotoMessage {

    var extensions:String { mimeType.components(separatedBy: "/").last ?? ""}

    var previewFileId: String { "preview_\(fileID)" }
    var previewFileIdWithExtensions: String { "preview_\(fileID).\(extensions)" }

    var originalFileId: String { "original_\(fileID)" }
    var originalFileIdWithExtension: String { "original_\(fileID).\(extensions)" }
}

extension FileMessage {
    var originalFileId: String { "original_\(fileID)" }
    var extensions: String {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue(),
              let type = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension)?.takeRetainedValue() as? String else {
            return mimeType.components(separatedBy: "/").last ?? ""
        }

        return type
    }
    
    var originalFileIdWithExtension: String { "original_\(fileID).\(extensions)" }
}

extension Message {
    var hasFile: Bool { self.file.fileID != "" }
    var hasPhoto: Bool { self.photo.fileID != "" }
    var hasVideo: Bool { self.video.fileID != "" }
    var hasVoice: Bool { self.voice.fileID != "" }
    
    var fileID: String? {
        if hasPhoto {
            return photo.fileID
        } else if hasVideo {
            return video.fileID
        } else if hasFile {
            return file.fileID
        } else if hasVoice {
            return voice.fileID
        } else {
            return nil
        }
    }
    
    var fileSize: Int64 {
        if hasPhoto {
            return photo.fileSize
        } else if hasVideo {
            return video.fileSize
        } else {
            return 0
        }
    }
}

