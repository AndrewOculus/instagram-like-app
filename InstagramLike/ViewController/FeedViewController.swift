//
//  FeedViewController.swift
//  InstagramLike
//
//  Created by Андрей Лапушкин on 18.03.2018.
//  Copyright © 2018 Андрей Лапушкин. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts = [Post]()
    var following = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPosts()
    }

    func fetchPosts()
    {
        let ref = Database.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            let users = snapshot.value as! [String: AnyObject]
            
            for (_ , val) in users
            {
                if let uid = val["uid"] as? String{
                    if uid == Auth.auth().currentUser?.uid{
                        if let followingUsers = val["following"] as? [String:String]
                        {
                            for(_,user) in followingUsers{
                                self.following.append(user)
                            }
                        }
                        self.following.append(Auth.auth().currentUser!.uid)
                        
                        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                            let postSnap = snapshot.value as! [String : AnyObject]
                            
                            for (_, post) in postSnap{
                                if let userID = post["userID"] as? String{
                                    for each in self.following{
                                        if each == userID{
                                            let posst = Post()
                                            if let author = post["author"] as? String, let likes = post["likes"] as? Int, let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String
                                            {
                                                posst.author = author
                                                posst.likes = likes
                                                posst.pathToImage = pathToImage
                                                posst.postID = postID
                                                posst.userID = userID
                                                
                                                self.posts.append(posst)
                                            }
                                        }
                                    }
                                    
                                    self.collectionView.reloadData()
                                }
                                
                            }
                        })
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        cell.postImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
        cell.authorLabel.text = self.posts[indexPath.row].author
        cell.likesLabel.text = "\(self.posts[indexPath.row].likes) Likes"
        return cell
    }
}
