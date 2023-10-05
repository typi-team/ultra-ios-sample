//
//  VoiceRepository.swift
//  UltraCore
//
//  Created by Slam on 8/10/23.
//

import Foundation
import AVFAudio
import RxSwift

class VoiceItem {
    let voiceMessage: VoiceMessage
    var currentTime: TimeInterval = 0.0
    
    init(voiceMessage: VoiceMessage, currentTime: TimeInterval) {
        self.voiceMessage = voiceMessage
        self.currentTime = currentTime
    }
}

class VoiceRepository: NSObject {
    
    fileprivate var timer: Timer?
    fileprivate let mediaUtils: MediaUtils
    fileprivate var audioPlayer: AVAudioPlayer?

    init(mediaUtils: MediaUtils) {
        self.mediaUtils = mediaUtils
    }
    
    var currentVoice: BehaviorSubject<VoiceItem?> = .init(value: nil)

    func stop() {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        self.currentVoice.on(.next(nil))
        self.timer?.invalidate()
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func play(message: Message) {
        guard let soundURL = self.mediaUtils.mediaURL(from: message) else { return }
        do {
            self.stop()
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.prepareToPlay()
            audioPlayer.delegate = self
            audioPlayer.play()
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            self.audioPlayer = audioPlayer
            self.currentVoice.on(.next(.init(voiceMessage: message.voice, currentTime: 0.0)))
        } catch {
            self.stop()
            PP.error(error.localizedDescription)
        }
    }
}

extension VoiceRepository: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.stop()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        PP.error(error?.localizedDescription ?? "")
        self.stop()
    }
    
}

private extension VoiceRepository {
    @objc func updateTime() {
        guard let currentTime = self.audioPlayer?.currentTime else { return }
        try? self.currentVoice.value()?.currentTime = currentTime
        self.currentVoice.on(.next(try? self.currentVoice.value()))
    }

}
