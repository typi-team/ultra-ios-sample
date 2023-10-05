//
//  IncomeVoiceCell.swift
//  UltraCore
//
//  Created by Slam on 8/10/23.
//

import Foundation

class IncomeVoiceCell: MediaCell {
    
    fileprivate let playImage: UIImage? = .named("conversation_play_sound_icon")
    fileprivate let pauseImage: UIImage? = .named("conversation_pause_sound_icon")
    
    fileprivate let voiceRepository = AppSettingsImpl.shared.voiceRepository

    fileprivate lazy var config = UltraCoreStyle.incomeMessageCell
    
    fileprivate lazy var slider: UISlider = .init({
        $0.thumbTintColor = config.sildirBackgroundColor.color
        $0.maximumTrackTintColor = config.sildirBackgroundColor.color
        $0.minimumTrackTintColor = config.sildirBackgroundColor.color
    })
    fileprivate let durationLabel: RegularFootnote = .init({ $0.text = "10.00₸" })
    
    fileprivate lazy var controllerView: UIButton = .init({
        $0.setImage(playImage, for: .normal)
        $0.addAction {[weak self] in
            guard let `self` = self, let message = self.message else { return }
            let fileID = try? voiceRepository.currentVoice.value()?.voiceMessage.fileID
            if  message.voice.fileID == fileID {
                self.voiceRepository.stop()
                self.controllerView.setImage(playImage, for: .normal)
            } else {
                self.controllerView.setImage(pauseImage, for: .normal)
                self.voiceRepository.play(message: message)
            }
            
        }
    })
    
    override func setupView() {
        super.setupView()
        self.container.addSubview(controllerView)
        self.container.addSubview(durationLabel)
        self.container.addSubview(slider)
    }

    override func setupConstraints() {
        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(kMediumPadding)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.right.equalToSuperview().offset(-120)
        }
        
        self.controllerView.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(kLowPadding)
        }
        
        self.slider.snp.makeConstraints { make in
            make.left.equalTo(controllerView.snp.right).offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.top.equalToSuperview().offset(kLowPadding)
            make.height.equalTo(kHeadlinePadding)
        }
        
        self.deliveryDateLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(kLowPadding)
            make.right.equalToSuperview().offset(-kLowPadding)
            
        }
        self.durationLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(kLowPadding)
            make.leading.equalTo(slider.snp.leading)
            make.bottom.equalToSuperview().offset(-kLowPadding)
        }
    }

    override func setup(message: Message) {
        super.setup(message: message)

        self.durationLabel.text = message.voice.duration.timeInterval.formatSeconds
        
        self.voiceRepository
            .currentVoice
            .subscribe(onNext: { [weak self] voice in
                guard let `self` = self else { return }
                if let voice = voice,
                   self.message?.voice.fileID == voice.voiceMessage.fileID {
                    let duration = voice.voiceMessage.duration.timeInterval
                    let value = (voice.currentTime / duration)

                    self.slider.setValue(Float(value), animated: true)
                    self.controllerView.setImage(value == 0 ? playImage : pauseImage, for: .normal)
                } else {
                    self.slider.setValue(0.0, animated: true)
                    self.controllerView.setImage(playImage, for: .normal)
                }
            })
            .disposed(by: disposeBag)
    }
 
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.slider.setValue(0.0, animated: true)
        self.durationLabel.text = 0.0.description
        self.controllerView.setImage(playImage, for: .normal)
    }
}

class OutcomeVoiceCell: IncomeVoiceCell {
    fileprivate let statusView: UIImageView = .init(image: UIImage.named("conversation_status_read"))
    
    
    override func setupView() {
        super.setupView()
        self.container.addSubview(statusView)
    }
    
    override func setupConstraints() {
        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(120)
            make.bottom.equalToSuperview().offset(-(kMediumPadding - 2))
            make.right.equalToSuperview().offset(-kMediumPadding)
        }
        
        self.controllerView.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(kLowPadding)
        }
        
        self.slider.snp.makeConstraints { make in
            make.left.equalTo(controllerView.snp.right).offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.top.equalToSuperview().offset(kLowPadding)
            make.height.equalTo(kHeadlinePadding)
        }
        
        self.deliveryDateLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(kLowPadding)
            make.right.equalToSuperview().offset(-kLowPadding)
        }
        
        self.durationLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(kLowPadding)
            make.leading.equalTo(slider.snp.leading)
            make.bottom.equalToSuperview().offset(-kLowPadding)
        }
        
        self.statusView.snp.makeConstraints { make in
            make.right.equalTo(deliveryDateLabel.snp.left).offset(-(kLowPadding / 2))
            make.centerY.equalTo(self.deliveryDateLabel.snp.centerY)
        }
    }
    
    override func setup(message: Message) {
        super.setup(message: message)
        self.statusView.image = .named(message.statusImageName)
    }
}
