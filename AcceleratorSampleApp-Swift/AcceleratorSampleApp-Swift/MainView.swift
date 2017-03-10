//
//  MainView.swift
//
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

import UIKit

class ControlButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }
}

class MainView: UIView {
    
    @IBOutlet fileprivate weak var holderView: UIView!
    @IBOutlet fileprivate weak var callButton: UIButton!
    @IBOutlet fileprivate weak var publisherVideoButton: ControlButton!
    @IBOutlet fileprivate weak var publisherAudioButton: ControlButton!
    @IBOutlet fileprivate weak var messageButton: ControlButton!
    @IBOutlet weak var screenShareButton: ControlButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        callButton.isEnabled = true
        callButton.layer.cornerRadius = callButton.bounds.width / 2
    }
    
    func addPublisherView(_ publisherView: UIView) {
        publisherView.layer.backgroundColor = UIColor.gray.cgColor
        publisherView.frame = frame
        holderView.addSubview(publisherView)
    }
    
    func connectCallHolder(connected: Bool) {
        callButton.setImage(connected ? #imageLiteral(resourceName: "hangUp") : #imageLiteral(resourceName: "startCall"), for: .normal)
        callButton.layer.backgroundColor = connected ? UIColor(red: 205/255.0, green: 32/255.0, blue: 40/255.0, alpha: 1.0).cgColor : UIColor(red: 106/255.0, green: 173/255.0, blue: 191/255.0, alpha: 1.0).cgColor
    }
    
    func updatePublisherAudio(connected: Bool) {
        publisherAudioButton.setImage(connected ? #imageLiteral(resourceName: "mic") : #imageLiteral(resourceName: "mutedMic"), for: .normal)
    }
    
    func updatePublisherVideo(connected: Bool) {
        publisherVideoButton.setImage(connected ? #imageLiteral(resourceName: "video") : #imageLiteral(resourceName: "noVideo"), for: .normal)
    }
    
    func enableControlButtonsForCall(enabled: Bool) {
        publisherVideoButton.isEnabled = enabled
        publisherAudioButton.isEnabled = enabled
        messageButton.isEnabled = enabled
        screenShareButton.isEnabled = enabled
    }
    
    func resetAllControl() {
        connectCallHolder(connected: false)
        updatePublisherAudio(connected: true)
        updatePublisherVideo(connected: true)
        enableControlButtonsForCall(enabled: false)
    }
}
