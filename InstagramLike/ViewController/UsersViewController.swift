//
//  UsersViewController.swift
//  InstagramLike
//
//  Created by Андрей Лапушкин on 13.03.2018.
//  Copyright © 2018 Андрей Лапушкин. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController ,UITableViewDataSource , UITableViewDelegate  {

    @IBOutlet weak var tableView: UITableView!
    
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        retriveUsers()
    }

    func retriveUsers()
    {
        var ref = Database.database().reference()
        self.users.removeAll()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: {snapshot in
            let users = snapshot.value as! [String : AnyObject]
            
            for(_, value) in users
            {
                if let userID = value["uid"] as? String
                {
                    var userToShow = User()
                    
                    if let fullName = value["full name"] as? String , let imagePath = value["urlToImage"] as? String{
                        userToShow.fullName = fullName
                        userToShow.imagePath = imagePath
                        userToShow.userID = userID
                        self.users.append(userToShow)
                    }
                }
            }
            self.tableView.reloadData()
        })
        ref.removeAllObservers()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        
        cell.userLabel.text = self.users[indexPath.row].fullName
        cell.userId = self.users[indexPath.row].userID
        cell.userImage.downloadImage(from: users[indexPath.row].imagePath)
        checkFollowing(cellForRowAt:indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        var isFollower = false
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: {snapshot in
            if let following = snapshot.value as? [String : AnyObject] {
                for (ke,value) in following{

                    print("\(value as! String) and \(self.users[indexPath.row].userID)")

                    if value as! String == self.users[indexPath.row].userID
                    {
                        print("ok")

                        isFollower = true
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(self.users[indexPath.row].userID).child("followers/\(ke)").removeValue()
                        
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                }
            }
            if !isFollower {
                let following = ["following/\(key)" : self.users[indexPath.row].userID]
                let followers = ["followers/\(key)" : uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.users[indexPath.row].userID).updateChildValues(followers)
                
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        })
        ref.removeAllObservers()
    }
    
    func checkFollowing( cellForRowAt indexPath: IndexPath)
    {
        
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        var isFollower = false
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: {snapshot in
            if let following = snapshot.value as? [String : AnyObject] {
                for (ke,value) in following{
                    
                    if value as! String == self.users[indexPath.row].userID
                    {
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark

                    }
                    
                    /*
                    print("\(value as! String) and \(self.users[indexPath.row].userID)")
                    
                    if value as! String == self.users[indexPath.row].userID
                    {
                        print("ok")
                        
                        isFollower = true
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(self.users[indexPath.row].userID).child("followers/\(ke)").removeValue()
                        
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    }*/
                }
            }
        })
        ref.removeAllObservers()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    @IBAction func logOutPressed(_ sender: Any) {
    }
}

extension UIImageView{
    func downloadImage(from imageUrl: String!)
    {
        let url = URLRequest(url: URL(string: imageUrl)!)
        let task = URLSession.shared.dataTask(with: url){
            (data,response,error) in
            if error != nil{
                print ( "error")
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}
