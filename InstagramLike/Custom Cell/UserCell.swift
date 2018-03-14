//
//  UserCell.swift
//  InstagramLike
//
//  Created by Андрей Лапушкин on 13.03.2018.
//  Copyright © 2018 Андрей Лапушкин. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userLabel: UILabel!
    
    var userId: String!
}
