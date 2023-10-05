//
//  MediaCell.swift
//  UltraCore
//
//  Created by Slam on 6/7/23.
//

import UIKit
import RxSwift

class MediaCell: BaseMessageCell {
    
    let playView: UIImageView = .init {
        $0.isUserInteractionEnabled = false
        $0.image = .named("conversation_media_play")
    }
    
    let downloadProgress: UIProgressView = .init({
        $0.trackTintColor = .clear
        $0.progressTintColor = .green500
    })

    let deliveryWrapper: UIView = .init {
        $0.cornerRadius = 12
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }

    let mediaRepository: MediaRepository = AppSettingsImpl.shared.mediaRepository

    lazy var mediaView: UIImageView = .init {
        $0.image = .named("ff_logo_text")
        $0.contentMode = .scaleAspectFill
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.mediaView.image = nil
        self.playView.isHidden = true
        self.downloadProgress.isHidden = true
    }

    func dowloadImage(by message: Message) {
        self.mediaView.image = UIImage(data: message.photo.preview)
        self.mediaRepository
            .downloadingImages
            .map({ $0.first(where: { $0.fileID == self.message?.fileID }) })
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] request in
                guard let `self` = self, let request = request else { return }
                if request.fromChunkNumber >= request.toChunkNumber {
                    self.downloadProgress.isHidden = true
                } else {
                    self.downloadProgress.isHidden = false
                    self.downloadProgress.progress = Float(request.fromChunkNumber) / Float(request.toChunkNumber)
                }
            })
            .map({ [weak self] request -> UIImage? in
                guard let `self` = self, let message = self.message, let request = request else { return nil }

                if request.fromChunkNumber >= request.toChunkNumber {
                    return self.mediaRepository.image(from: message)
                } else {
                    return nil
                }
            })
            .compactMap({ $0 })
                .do(onNext: {[weak self] _ in
                    guard let `self` = self, let message = self.message else { return }
                    self.playView.isHidden = !message.hasVideo
                })
            .subscribe { [weak self] image in
                guard let `self` = self else { return }
                self.mediaView.image = image
            }
            .disposed(by: disposeBag)
    }
}
