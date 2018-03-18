//
//  PostCell.swift
//  InstagramLike
//
//  Created by Андрей Лапушкин on 18.03.2018.
//  Copyright © 2018 Андрей Лапушкин. All rights reserved.
//

import UIKit

class PostCell: UICollectionViewCell {
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var unlikeBtn: UIButton!

    
    @IBAction func pressedLike(_ sender: UIButton) {
    }
    
    @IBAction func pressedUnlike(_ sender: UIButton) {
    }
}
