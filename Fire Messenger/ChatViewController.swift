//
//  ChatViewController.swift
//  Fire Messenger
//
//  Created by Gustavo M Santos on 01/10/2018.
//  Copyright © 2018 Gustavo M Santos. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var messageArray : [Message] = [Message]()
    var selectedFriend : User? {
        didSet {
//            retrieveChat()
        }
    }
    let currentUser = Auth.auth().currentUser?.email
    var duration : NSNumber = 0
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var bottomChatContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextField.delegate = self
        
        messageTableView.register(UINib(nibName: "CustomMessageCell", bundle: nil), forCellReuseIdentifier: "CustomMessageCell")
        retrieveChat()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        messageTableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120.0
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.MessageTime.text = "00:00"
        cell.contentView.superview?.clipsToBounds = true
        
        if messageArray[indexPath.row].sender == Auth.auth().currentUser?.email! {
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        } else {
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        return cell
    }
    
    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber)
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight : Int = Int(keyboardSize.height)
            print("keyboardHeight",keyboardHeight)
            
            UIView.animate(withDuration: TimeInterval(truncating: duration)) {
                self.heightConstraint.constant = CGFloat(keyboardHeight + 50)
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: TimeInterval(truncating: duration)) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    func retrieveChat() {
        print("retrieveChat")
        self.title = selectedFriend!.name
        let messagesDB = Database.database().reference().child("Messages").child(selectedFriend!.chatId)
        
        messagesDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let message = Message()
            
            message.messageBody = snapshotValue["messageBody"]!
            message.sender = snapshotValue["sender"]!
//            message.timestamp = String(snapshotValue["timestamp"]!)
            

            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
        }
        
    }


    @IBAction func sendPressed(_ sender: Any) {
        if messageTextField.text != "" {
            messageTextField.endEditing(true)
            messageTextField.isEnabled = false
            sendButton.isEnabled = false
            
            
            let messageDictionary = [
                "sender": currentUser as Any,
                "messageBody": messageTextField.text!
//                "timestamp": ServerValue.timestamp()
            ] as [String : Any]
            
            let messagesDB = Database.database().reference().child("Messages").child(selectedFriend!.chatId)
            messagesDB.childByAutoId().setValue(messageDictionary) {
                (error, reference) in
                if error != nil {
                    print(error!)
                } else {
                    print("Message saved successfully!")
                    self.messageTextField.isEnabled = true
                    self.sendButton.isEnabled = true
                    self.messageTextField.text = ""
                }
            }
        }
    }
}
