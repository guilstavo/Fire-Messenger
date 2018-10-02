//
//  UserTableViewController.swift
//  Fire Messenger
//
//  Created by Gustavo M Santos on 01/10/2018.
//  Copyright © 2018 Gustavo M Santos. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class UserTableViewController: UITableViewController {
    
    let userUid = String(Auth.auth().currentUser!.uid)
    var friendsArray : [User] = [User]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveFriends()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friendsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        let item = friendsArray[indexPath.row]
        
        cell.textLabel?.text = item.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToChat", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ChatViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedFriend = friendsArray[indexPath.row]
        }
    }
    
    
    func retrieveFriends() {
        let messageDB = Database.database().reference().child("Friendship").child(userUid)
        self.friendsArray = []
        messageDB.observe(.childAdded) { (snapshot) in
            let friendUid = snapshot.key
            let chatId = snapshot.value as! String
            self.getUser(uid: friendUid, chatId: chatId)
        }
    }
    
    func getUser(uid: String, chatId: String) {
        let messageDB = Database.database().reference().child("User").child(uid)
        messageDB.observe(.value) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let user = User()
            user.name = snapshotValue["name"]!
            user.email = snapshotValue["email"]!
            user.uid = snapshotValue["uid"]!
            user.chatId = chatId
            self.friendsArray.append(user)
            self.tableView.reloadData()
        }
    }

    
    @IBAction func addPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Find Friend", message: "Type friend email", preferredStyle: .alert)
        let action = UIAlertAction(title: "Find Friend", style: .default) { (action) in
            SVProgressHUD.show()
            let newFriendEmail = textField.text!.replacingOccurrences(of: ".", with: ",", options: .literal, range: nil)
            let findFriendDB = Database.database().reference().child("User-Ref").child(newFriendEmail)
            
            findFriendDB.observe(.value, with: { (snapshot) -> Void in
                if snapshot.exists() {
                    let friendUid = snapshot.value as! String
                    let uidArray = [self.userUid, friendUid]
                    let messageKey = Database.database().reference().child("Message").childByAutoId().key
                    for (index, uid) in uidArray.enumerated() {
                        let boolIndex = Bool(truncating: index as NSNumber) ? 0 : 1
                        let uidToSet = uidArray[boolIndex]
                        let userDB = Database.database().reference().child("Friendship").child(uid).child(uidToSet)
                        
                        userDB.setValue(messageKey) {
                            (error, reference) in
                            if error != nil {
                                print(error!)
                            } else {
                                print("user: \(uid), friend: \(uidToSet)")
                            }
                        }
                    }
                    SVProgressHUD.dismiss()
                } else {
                    SVProgressHUD.dismiss()
                    print("user doesn't exist")
                }
            })
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "email"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    

    @IBAction func logOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("error, thare was a problem signing out")
        }
    }
}
