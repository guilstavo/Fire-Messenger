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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
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
                    let userUid = String(Auth.auth().currentUser!.uid)
                    let friendUid = snapshot.value as! String
                    let uidArray = [userUid, friendUid]
                    for (index, uid) in uidArray.enumerated() {
                        let boolIndex = Bool(truncating: index as NSNumber) ? 0 : 1
                        let uidToSet = uidArray[boolIndex]
                        let userDB = Database.database().reference().child("User").child(uid).child("friends").child(uidToSet)
                        userDB.setValue(uidToSet) {
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
