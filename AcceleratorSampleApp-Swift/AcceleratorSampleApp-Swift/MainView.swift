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
    
    func updateSubscriberViews(_ subscriberViews:[OTMultiPartyRemote], publisherView: UIView?) {
        for view in holderView.subviews {
            view.removeFromSuperview()
        }
        
        guard let publisherView = publisherView else {return}
        
        if subscriberViews.count == 0 {
            addPublisherView(publisherView)
            return
        }
        
        if subscriberViews.count == 1 {
            addPublisherView(publisherView)
            guard let remote = subscriberViews.last else {return}
            remote.subscriberView.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height / 2)
            holderView.addSubview(remote.subscriberView)
            return
        }
        
        var height, subscriberWidth, publisherWidth: CGFloat
        height = bounds.size.height / (CGFloat(subscriberViews.count / 2) + 1)
        subscriberWidth = subscriberViews.count + 1 > 2 ? bounds.size.width / 2 :   bounds.size.width
        publisherWidth = (subscriberViews.count + 1) % 2 == 0 ? bounds.size.width / 2 : bounds.size.width
        
        var x: CGFloat = 0.0, y: CGFloat = 0.0
        var i = 0
        repeat {

            let remote = subscriberViews[i]
            remote.subscriberView.frame = CGRect(x: x, y: y, width: subscriberWidth, height: height)
            
            // this will position and audio/video controls
            remote.subscriberView.controlView.backgroundColor = UIColor.black
            remote.subscriberView.controlView.isVerticalAlignment = true
            remote.subscriberView.controlView.frame = CGRect(x: 10, y: 10, width: remote.subscriberView.bounds.width * 0.2, height: remote.subscriberView.bounds.height * 0.3)
            
            holderView.addSubview(remote.subscriberView)
            
            // update x and y value for the next subscriber view
            if (i + 1) % 2 == 0 {
                x = 0
            }
            else {
                x = subscriberWidth
            }
            y = CGFloat((i + 1) / 2) * height
            
            // update index
            i += 1
        } while i < subscriberViews.count
        
        
        addPublisherView(publisherView)
        if subscriberWidth != publisherWidth {
            // publisher is at the bottom
            publisherView.frame = CGRect(x: 0, y: y, width: publisherWidth, height: height);
        }
        else {
            // publisher is at the bottom right
            publisherView.frame = CGRect(x: bounds.size.width / 2, y: y, width: publisherWidth, height: height);
        }
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
