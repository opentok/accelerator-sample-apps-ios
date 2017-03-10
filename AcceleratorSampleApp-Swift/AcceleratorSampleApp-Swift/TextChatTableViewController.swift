//
//  TextChatTableViewController.swift
//
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

import UIKit

class TextChatTableViewController: OTTextChatViewController {
    
    var textChat: OTTextChat?
    var textMessages = [OTTextMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textChat = OTTextChat()
        textChat?.dataSource = self
        textChat?.alias = "Toxboxer"
        
        textChatNavigationBar.topItem?.title = textChat?.alias
        tableView.textChatTableViewDelegate = self
        tableView.separatorStyle = .none
        textChatInputView.textField.delegate = self
        
        textChat?.connect(handler: { (signal, connection, error) in
            
            guard error == nil else {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
                return
            }
            
            if signal == .didConnect {
                print("Text Chat starts")
            }
            else if signal == .didDisconnect {
                print("Text Chat stops")
            }
            
        }) { [unowned self](signal, message, error) in
            
            guard error == nil, let message = message else {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
                return
            }
            
            self.textMessages.append(message)
            self.tableView.reloadData()
            self.textChatInputView.textField.text = nil
            self.scrollTextChatTableViewToBottom()
        }
        
        textChatInputView.sendButton.addTarget(self, action: #selector(TextChatTableViewController.sendTextMessage), for: .touchUpInside)
    }
    
    func sendTextMessage() {
        textChat?.sendMessage(textChatInputView.textField.text)
    }
}

extension TextChatTableViewController: OTTextChatDataSource {
    public func session(of textChat: OTTextChat!) -> OTAcceleratorSession! {
        return (UIApplication.shared.delegate as? AppDelegate)?.session
    }
}

extension TextChatTableViewController: OTTextChatTableViewDataSource {
    
    func type(of tableView: OTTextChatTableView!) -> OTTextChatViewType {
        return .default
    }
    
    public func textChatTableView(_ tableView: OTTextChatTableView!, numberOfRowsInSection section: Int) -> Int {
        return  textMessages.count
    }
    
    func textChatTableView(_ tableView: OTTextChatTableView!, textMessageItemAt indexPath: IndexPath!) -> OTTextMessage! {
        return textMessages[indexPath.row]
    }
    
    func textChatTableView(_ tableView: OTTextChatTableView!, cellForRowAt indexPath: IndexPath!) -> UITableViewCell! {
        return nil
    }
}

extension TextChatTableViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTextMessage()
        return true
    }
}
