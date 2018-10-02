//
//  WelcomeViewController.swift
//  Fire Messenger
//
//  Created by Gustavo M Santos on 02/10/2018.
//  Copyright © 2018 Gustavo M Santos. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        registerButton.layer.cornerRadius = 25
        loginButton.layer.cornerRadius = 25
        stackView.setCustomSpacing(100.0, after: titleLabel)
        
        // Do any additional setup after loading the view.
    }
    
   
  

}
