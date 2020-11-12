//
//  ScreenShareViewController.swift
//
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

import UIKit

class ScreenShareViewController: UIViewController {
    
    public var sharingImage: UIImage?
    
    @IBOutlet weak var extiButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var annotationView: UIView!
    @IBOutlet weak var annotationToolbarView: UIView!
    
    var multipartyScreenSharer: OTMultiPartyCommunicator?
    var annotator: OTAnnotator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageView.image = sharingImage
        startScreenSharing()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let _ = multipartyScreenSharer?.disconnect()
        multipartyScreenSharer = nil
        annotator?.annotationScrollView.removeFromSuperview()
        annotator?.annotationScrollView.annotationView.removeFromSuperview()
        let _ = annotator?.disconnect()
        annotator = nil
    }
    
    fileprivate func styleUI() {
        extiButton.layer.cornerRadius = extiButton.bounds.width / 2
    }
    
    fileprivate func startScreenSharing() {
        multipartyScreenSharer = OTMultiPartyCommunicator.init(view: annotationView)
        multipartyScreenSharer?.dataSource = self
        
        // publishOnly here is to avoid subscripting to those who already subscribed
        multipartyScreenSharer?.isPublishOnly = true
        
        multipartyScreenSharer?.connect {
            [unowned self](signal, remote, error) in
            
            guard error == nil else {
                self.dismiss(animated: true) {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }
                return
            }
            
            if signal == .publisherCreated {
                self.multipartyScreenSharer?.isPublishAudio = false
                self.startAnnotation()
            }
        }
    }
    
    fileprivate func startAnnotation() {
        annotator = OTAnnotator()
        annotator?.dataSource = self
        annotator?.connect {
            [unowned self] (signal, error) in
            
            guard error == nil else {
                self.dismiss(animated: true) {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }
                return
            }
            
            if signal == .sessionDidConnect {
                self.annotator?.annotationScrollView.initializeToolbarView()
                
                guard let annotator = self.annotator,
                        let toolbarView = annotator.annotationScrollView.toolbarView else {
                    print("Error on launching annotation")
                    return
                }
                
                // using frame and self.view to contain toolbarView is for having more space to interact with color picker
                
                toolbarView.toolbarViewDataSource = self
                toolbarView.frame = self.annotationToolbarView.frame
                self.view.addSubview(toolbarView)

                annotator.annotationScrollView.frame = self.annotationView.bounds;
                annotator.annotationScrollView.scrollView.contentSize = CGSize(width: CGFloat(annotator.annotationScrollView.bounds.width), height: CGFloat(annotator.annotationScrollView.bounds.height))
                self.annotationView.addSubview(annotator.annotationScrollView)
                
                annotator.annotationScrollView.isAnnotatable = false
            }
        }
    }
    
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ScreenShareViewController: OTMultiPartyCommunicatorDataSource {
    func session(of multiPartyCommunicator: OTMultiPartyCommunicator!) -> OTAcceleratorSession! {
        return (UIApplication.shared.delegate as? AppDelegate)?.session
    }
}

extension ScreenShareViewController: OTAnnotatorDataSource {
    func session(of annotator: OTAnnotator!) -> OTAcceleratorSession! {
        return (UIApplication.shared.delegate as? AppDelegate)?.session
    }
}

extension ScreenShareViewController: OTAnnotationToolbarViewDataSource {
    func annotationToolbarViewForRootView(forScreenShot toolbarView: OTAnnotationToolbarView!) -> UIView! {
        return annotationView
    }
}
