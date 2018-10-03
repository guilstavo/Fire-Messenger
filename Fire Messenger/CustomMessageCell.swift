//
//  CustomMessageCell.swift
//  Fire Messenger
//
//  Created by Gustavo M Santos on 01/10/2018.
//  Copyright © 2018 Gustavo M Santos. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {

    @IBOutlet weak var messageBackground: UIView!
    @IBOutlet weak var MessageTime: UILabel!
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var rightBackgroundConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftBackgroundConstraint: NSLayoutConstraint!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
