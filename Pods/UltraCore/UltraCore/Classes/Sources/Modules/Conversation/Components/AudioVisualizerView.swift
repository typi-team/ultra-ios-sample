//
//  AudioVisualizerView.swift
//  UltraCore
//
//  Created by Slam on 8/9/23.
//
import UIKit
import AVFoundation

class AudioVisualizerView: UIView {
    
    private var wavePowers: [Float] = []
    private var waveformLayer: CAShapeLayer!
    fileprivate var internalLineWidth: CGFloat = 2.0
    fileprivate var internalLineSeperation: CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    
    func visualizeAudio(withPath audioFileURL: URL) {
        
    }
    
    func appendWave(value: Float) {
        self.wavePowers.append(value)
        self.updateWaveform(wavePowers: convertArray(wavePowers,
                                                     fromRange: -160.0...0.0,
                                                     toRange: 0.0...21.0))
    }
    
    func clearWaves() {
        self.wavePowers = []
        self.waveformLayer.sublayers?.forEach({ $0.removeFromSuperlayer() })
    }
}

private extension AudioVisualizerView {
    func convertArray(_ array: [Float], fromRange: ClosedRange<Float>, toRange: ClosedRange<Float>) -> [Float] {
        return array.map { value in
            let convertedValue = convertValue(value, fromRange: fromRange, toRange: toRange)
            return convertedValue
        }
    }

    func convertValue(_ value: Float, fromRange: ClosedRange<Float>, toRange: ClosedRange<Float>) -> Float {
        let fromMin = fromRange.lowerBound
        let fromMax = fromRange.upperBound

        let toMin = toRange.lowerBound
        let toMax = toRange.upperBound

        let scaledValue = (value - fromMin) / (fromMax - fromMin)
        let convertedValue = toMin + (scaledValue * (toMax - toMin))

        return convertedValue - 10
    }

    func createColumnLayer(at position: CGPoint, height: CGFloat, width: CGFloat) -> CAShapeLayer {
        let columnPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: width, height: height))

        let columnLayer = CAShapeLayer()
        columnLayer.path = columnPath.cgPath
        columnLayer.fillColor = UIColor.green500.cgColor

        let columnX = position.x - width / 2.0
        let columnY = position.y
        columnLayer.position = CGPoint(x: columnX, y: columnY)

        return columnLayer
    }

    func updateWaveform(wavePowers: [Float]) {
        self.waveformLayer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        let spacing: CGFloat = 1.0
        let columnWidth: CGFloat = 3.0
        let columnCount = wavePowers.count

        let totalWidth = CGFloat(columnCount) * (columnWidth + spacing) - spacing
        let startX = (self.bounds.width - totalWidth)

        for i in 0 ..< wavePowers.count {
            let columnHeight = CGFloat(wavePowers[i])
            let x = startX + CGFloat(i) * (columnWidth + spacing)
            let y = self.bounds.height - columnHeight

            let columnLayer = createColumnLayer(at: CGPoint(x: x, y: y), height: columnHeight, width: columnWidth)
            self.waveformLayer.addSublayer(columnLayer)
        }
    }

    func createWaveformLayer(position: CGPoint, width: CGFloat) -> CAShapeLayer {
        let waveformLayer = CAShapeLayer()
        waveformLayer.position = position
        waveformLayer.bounds = CGRect(x: 0, y: 0, width: width, height: frame.height)
        waveformLayer.strokeColor = UIColor.green.cgColor
        waveformLayer.lineWidth = 2.0
        waveformLayer.lineCap = .round
        return waveformLayer
    }

    func setupView() {
        self.clipsToBounds = true
        self.backgroundColor = .clear
        self.waveformLayer = createWaveformLayer(position: CGPoint(x: frame.width / 2, y: frame.height / 2), width: frame.width)
        self.layer.addSublayer(waveformLayer)
    }
}
