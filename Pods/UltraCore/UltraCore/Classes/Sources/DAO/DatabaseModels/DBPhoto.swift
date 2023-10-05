//
//  DBPhoto.swift
//  UltraCore
//
//  Created by Slam on 5/23/23.
//

import Foundation
import RealmSwift

class DBPhoto: Object {
    @objc dynamic var fileID = ""
    @objc dynamic var mimeType = ""
    @objc dynamic var width: Int32 = 0
    @objc dynamic var height: Int32 = 0
    @objc dynamic var fileSize: Int64 = 0
    @objc dynamic var preview: Data = Data()
    
    override class func primaryKey() -> String? {
        return "fileID"
    }
    
    convenience init(from photo: Photo) {
        self.init()
        self.width = photo.width
        self.fileID = photo.fileID
        self.height = photo.height
        self.preview = photo.preview
        self.fileSize = photo.fileSize
        self.mimeType = photo.mimeType
    }
    
    func toProto() -> Photo {
        return .with({
            $0.width = self.width
            $0.fileID = self.fileID
            $0.height = self.height
            $0.preview = self.preview
            $0.fileSize = self.fileSize
            $0.mimeType = self.mimeType
        })
    }
}
