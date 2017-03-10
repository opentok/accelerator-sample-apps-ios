//
//  MainViewController.swift
//
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

import Foundation

class MainViewController: UIViewController {
    
    fileprivate var mainView: MainView {
        return self.view as! MainView
    }
    
    fileprivate var subscribers = [OTMultiPartyRemote]()
    fileprivate var multipartyCommunicator: OTMultiPartyCommunicator?
    
    var selectedImage: UIImage?
    lazy fileprivate var screenShareMenuAlertController: UIAlertController = {
        
        let screenShareMenuAlertController = UIAlertController.init(title: nil, message: "Please choose the content you want to share", preferredStyle: .actionSheet)
        
        screenShareMenuAlertController.addAction(UIAlertAction.init(title: "Camera Roll", style: .default) {
            [unowned self] (action) in
            
            let imagePickerViewController = UIImagePickerController()
            imagePickerViewController.delegate = self
            imagePickerViewController.sourceType = .photoLibrary
            self.present(imagePickerViewController, animated: true, completion: nil)
        })
        
        screenShareMenuAlertController.addAction(UIAlertAction.init(title: "Cancel", style: .destructive) {
            [unowned self] (action) in
            
            screenShareMenuAlertController.dismiss(animated: true, completion: nil)
        })
        
        return screenShareMenuAlertController
    }()
    
    @IBAction func callButtonPressed(_ sender: Any) {
        
        guard let multipartyCommunicator = multipartyCommunicator else {return}
        
        if !multipartyCommunicator.isCallEnabled {
            
            // start call
            SVProgressHUD.show()
            multipartyCommunicator.connect {
                [unowned self] (signal, remote, error) in
                
                guard error == nil else {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    return
                }
                self.handleCommunicationSignal(signal, remote: remote)
            }
        }
        else {
            
            // end call
            SVProgressHUD.dismiss()
            multipartyCommunicator.disconnect()
            mainView.resetAllControl()
            subscribers.removeAll()
        }
    }
    
    @IBAction func publisherAudioButtonPressed(_ sender: Any) {
        multipartyCommunicator!.isPublishAudio = !multipartyCommunicator!.isPublishAudio
        mainView.updatePublisherAudio(connected: multipartyCommunicator!.isPublishAudio)
    }
    
    @IBAction func publisherVideoButtonPressed(_ sender: Any) {
        multipartyCommunicator!.isPublishVideo = !multipartyCommunicator!.isPublishVideo
        mainView.updatePublisherVideo(connected: multipartyCommunicator!.isPublishVideo)
    }
    
    @IBAction func textMessageButtonPressed(_ sender: Any) {
        present(TextChatTableViewController(), animated: true, completion: nil)
    }
    
    @IBAction func screenShareButtonPressed(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            // handle iphone
            present(screenShareMenuAlertController, animated: true, completion: nil)
        }
        else {
            // handle ipad
            screenShareMenuAlertController.modalPresentationStyle = .popover
            screenShareMenuAlertController.popoverPresentationController?.sourceView = mainView.screenShareButton
            screenShareMenuAlertController.popoverPresentationController?.sourceRect = mainView.screenShareButton.bounds
            present(screenShareMenuAlertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        multipartyCommunicator = OTMultiPartyCommunicator.init()
        multipartyCommunicator!.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainView.updateSubscriberViews(subscribers, publisherView: multipartyCommunicator?.publisherView)
    }
    
    fileprivate func handleCommunicationSignal(_ signal: OTCommunicationSignal, remote: OTMultiPartyRemote?) {
        switch signal {
        case .publisherCreated: // join a call
            
            guard let multipartyCommunicator = multipartyCommunicator else {break}
            SVProgressHUD.popActivity()
            multipartyCommunicator.publisherView.showAudioVideoControl = false
            mainView.enableControlButtonsForCall(enabled: true)
            mainView.connectCallHolder(connected: multipartyCommunicator.isCallEnabled)
            mainView.addPublisherView(multipartyCommunicator.publisherView)
            
        case .subscriberReady:  // one participant joins
            SVProgressHUD.popActivity()
            if let remote = remote, subscribers.index(of: remote) == nil {
                subscribers.append(remote)
                mainView.updateSubscriberViews(subscribers, publisherView: multipartyCommunicator?.publisherView)
            }
            
        case .subscriberDestroyed:  // one participant leaves
            if let remote = remote, let index = subscribers.index(of: remote) {
                subscribers.remove(at: index)
                mainView.updateSubscriberViews(subscribers, publisherView: multipartyCommunicator?.publisherView)
            }

        case .sessionDidBeginReconnecting, .subscriberCreated:
            SVProgressHUD.show()
            
        case .sessionDidReconnect:
            SVProgressHUD.popActivity()
            
        case .subscriberVideoDisableWarningLifted:
            remote?.isSubscribeToVideo = true
            
        case .subscriberVideoDisableWarning:
            remote?.isSubscribeToVideo = false

        default:break
        }
    }
}

// MARK: - OTMultiPartyCommunicatorDataSource
extension MainViewController: OTMultiPartyCommunicatorDataSource  {
    func session(of multiPartyCommunicator: OTMultiPartyCommunicator!) -> OTAcceleratorSession! {
        return (UIApplication.shared.delegate as? AppDelegate)?.session
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let screenSharingVC = segue.destination as? ScreenShareViewController else {return}
        screenSharingVC.sharingImage = selectedImage
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        selectedImage = image
        picker.dismiss(animated: true) {
            [unowned self] in
            self.performSegue(withIdentifier: "ScreenSharing", sender: nil)
        }
    }
}
