//
//  VoiceInputBar.swift
//  UltraCore
//
//  Created by Slam on 8/8/23.
//

import Foundation

protocol VoiceInputBarDelegate: AnyObject {
    func recordedVoice(url: URL, in duration: TimeInterval)
}

class VoiceInputBar: UIView {
    
    weak var delegate: VoiceInputBarDelegate?
    
    fileprivate var voiceInputBarConfig: VoiceInputBarConfig { UltraCoreStyle.voiceInputBarConfig }
    
    fileprivate lazy var audioRecordUtils: AudioRecordUtils = .init({
        $0.delegate = self
    })
    
    fileprivate lazy var roundedView: UIView = .init({
        $0.cornerRadius = 12
        $0.backgroundColor = self.voiceInputBarConfig.roundedViewBackground.color
    })
    
    fileprivate lazy var removeButton: UIButton = .init({
        $0.tintColor = self.voiceInputBarConfig.removeButtonBackground.color
        $0.setImage(.named("conversation_voice_delete_icon"), for: .normal)
        $0.addAction {[weak self] in
            self?.cancelRecording()
        }
    })
    
    fileprivate lazy var recordingButton: UIButton = .init({
        $0.tintColor = self.voiceInputBarConfig.recordBackground.color
        $0.setImage(.named("conversation_send"), for: .normal)
        $0.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
    })
    
    fileprivate lazy var waveView: AudioVisualizerView = .init({
        $0.backgroundColor = .clear
    })
    
    fileprivate lazy var durationLabel: SubHeadline = .init({
        $0.text = "0:00"
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.setupConstraints()
    }
    
    private func setupView() {
        
        self.addSubview(roundedView)
        self.roundedView.addSubview(removeButton)
        self.roundedView.addSubview(recordingButton)
        self.roundedView.addSubview(waveView)
        self.roundedView.addSubview(durationLabel)
        
        self.backgroundColor = voiceInputBarConfig.background.color
    }
    
    private func setupConstraints() {
        self.roundedView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kHeadlinePadding / 2)
            make.left.equalToSuperview().offset(kMediumPadding)
            make.right.equalToSuperview().offset(-(kMediumPadding))
            make.bottom.equalToSuperview().offset(-(kHeadlinePadding / 2))
        }
        
        self.removeButton.snp.makeConstraints { make in
            make.width.equalTo(kHeadlinePadding)
            make.left.equalToSuperview().offset(kHeadlinePadding / 2)
            make.top.equalToSuperview().offset(kLowPadding - 2)
            make.bottom.equalToSuperview().offset(-(kLowPadding - 2))
        }
        
        self.waveView.snp.makeConstraints { make in
            make.left.equalTo(removeButton.snp.right).offset(10)
            make.top.equalToSuperview().offset(7)
            make.bottom.equalToSuperview().offset(-7)
            
        }
        
        self.durationLabel.snp.makeConstraints { make in
            make.left.equalTo(waveView.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        self.recordingButton.snp.makeConstraints { make in
            make.left.equalTo(durationLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-12)
            make.width.equalTo(kHeadlinePadding)
            make.top.equalToSuperview().offset(kLowPadding - 2)
            make.bottom.equalToSuperview().offset(-(kLowPadding - 2))
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        self.waveView.clearWaves()
        self.durationLabel.text = 0.00.description
    }
    
    func setActiveRecord() {
        self.audioRecordUtils.requestRecordPermission()
    }
}


extension VoiceInputBar: AudioRecordUtilsDelegate {
    func recordingVoice(average power: Float) {
        self.waveView.appendWave(value: power)
    }
    
    func recodedDuration(time interal: TimeInterval) {
        self.durationLabel.text = interal.formatSeconds
    }
    
    func requestRecordPermissionIsFalse() {
        self.removeFromSuperview()
    }
    
    func recordedVoice(url: URL, in duration: TimeInterval) {
        self.removeFromSuperview()
        self.delegate?.recordedVoice(url: url, in: duration)
    }
}

private extension VoiceInputBar {
    @objc func stopRecording() {
        self.audioRecordUtils.stopRecording()
        self.removeFromSuperview()
    }

    @objc func cancelRecording() {
        self.audioRecordUtils.cancelRecording()
        self.removeFromSuperview()
    }
}
