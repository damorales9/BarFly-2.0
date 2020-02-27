//
//  PostVC.swift
//  BarFly Reformat
//
//  Created by Derek Morales on 2/24/20.
//  Copyright © 2020 LoFi Games. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class PostVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var postMessage: UILabel!
    @IBOutlet var likeBtn: CheckClicked!
    @IBOutlet var dislikeBtn: CheckClicked!
    @IBOutlet var likesLbl: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var commentTaskBar: UIView!
    @IBOutlet var postView: UIView!
    
    var allComments = [Post]()
    
    var currentBar: String!
    var currentPost: Post!
    
    var colorUp: String!
    var colorDown: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.delegate=self
        tableView?.dataSource=self
        
        allComments.removeAll()
        getComments(barName: "\(currentBar!)") { (success) in
            if (success){
                self.tableView?.reloadData()
            }
        }
        
        self.postView.layer.borderWidth = 5
        self.postView.layer.borderColor = UIColor.black.cgColor
        self.postView.layer.cornerRadius = 10
        
        self.commentTaskBar.layer.borderWidth = 5
        self.commentTaskBar.layer.borderColor = UIColor.black.cgColor
        self.commentTaskBar.layer.cornerRadius = 10
        
        self.tableView.layer.borderWidth = 3
        self.tableView.layer.borderColor = UIColor.barflyblue.cgColor
        self.tableView.layer.cornerRadius = 10
        
        
        self.postMessage.text = currentPost.message
        self.likesLbl.text = ""
        if let likes = currentPost.likes
        {
            likesLbl.text = "\(likes)"
        }
        
        self.likeBtn.setImage(UIImage(named: "\(colorUp!)"), for: .normal)
        self.dislikeBtn.setImage(UIImage(named: "\(colorDown!)"), for: .normal)
        
        self.likeBtn.title = currentBar
        self.dislikeBtn.title = currentBar
        
        self.likeBtn.uid = currentPost.uid
        self.dislikeBtn.uid = currentPost.uid

        
        self.likeBtn.amountPeople = currentPost.likes
        self.dislikeBtn.amountPeople = currentPost.likes
        
        
        self.likeBtn.addTarget(self, action: #selector(self.likeBtnClicked(_:)), for: .touchUpInside)
        self.dislikeBtn.addTarget(self, action: #selector(self.dislikeBtnClicked(_:)), for: .touchUpInside)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(self.back(_:)))
        
        

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(allComments.count == 0){
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Comments"
            noDataLabel.textColor     = UIColor.barflyblue
            noDataLabel.textAlignment = .center
            noDataLabel.font = UIFont(name: "Roboto-Thin", size: 20)
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
            return 0
        }
        else {
            if (allComments.count < 20){
                tableView.backgroundView = nil
                return allComments.count
            }
            else{
                return 20
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! PostCell
        
        cell.commentMsg.text = allComments[indexPath.row].message
        if let likes = allComments[indexPath.row].likes
        {
            cell.commentLikes.text = "\(likes)"
        }
        
        cell.commentMsgLike.setImage(UIImage(named: "up"), for: .normal)
        cell.commentMsgDislike.setImage(UIImage(named: "down"), for: .normal)
        
        for s in allComments[indexPath.row].likedBy {
            if (s == AppDelegate.user?.uid){
                cell.commentMsgLike.setImage(UIImage(named: "grayup30"), for: .normal)
                cell.commentMsgDislike.setImage(UIImage(named: "down"), for: .normal)
            }
        }
        
        for p in allComments[indexPath.row].dislikedBy {
            if (p == AppDelegate.user?.uid) {
                cell.commentMsgLike.setImage(UIImage(named: "up"), for: .normal)
                cell.commentMsgDislike.setImage(UIImage(named: "graydown30"), for: .normal)
            }
        }
        
        cell.commentMsgLike.amountPeople = allComments[indexPath.row].likes
        cell.commentMsgDislike.amountPeople = allComments[indexPath.row].likes
        
        cell.commentMsgLike.title = currentPost.uid
        cell.commentMsgDislike.title = currentPost.uid
        
        cell.commentMsgLike.uid = allComments[indexPath.row].uid
        cell.commentMsgDislike.uid = allComments[indexPath.row].uid
        
        cell.commentMsgLike.cell = cell
        cell.commentMsgDislike.cell = cell
        
        cell.commentMsgLike.addTarget(self, action: #selector(self.likeBtnClicked(_:)), for: .touchUpInside)
        cell.commentMsgDislike.addTarget(self, action: #selector(self.dislikeBtnClicked(_:)), for: .touchUpInside)
        
        cell.layer.cornerRadius = 5
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.barflyblue.cgColor
        
        
        return cell
    }
    
    func getComments(barName: String, completion: @escaping (_ success: Bool) -> Void){
        print(barName)
        let basicQuery = Firestore.firestore().collection("Bar Feeds").document("\(barName)").collection("feed").document("\(currentPost!.uid!)").collection("comments").limit(to: 50)
        basicQuery.getDocuments { (snapshot, error) in
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let allPost = snapshot.documents
            for postDocument in allPost {
                
                let post = Post()
                let message = postDocument.data()["message"] as? String
                print(message)
                let uid = postDocument.documentID
                print(postDocument.documentID)
                let likes = postDocument.data()["likes"] as? Int
                let likedBy = postDocument.data()["likedBy"] as? [String]
                let dislikedBy = postDocument.data()["dislikedBy"] as? [String]
                
                post.message = message!
                post.uid = uid
                post.likes = likes!
                post.likedBy = likedBy!
                post.dislikedBy = dislikedBy!
                
                //self.allPosts.append(post)
                self.allComments.insert(post, at: 0)
                
                //completion(true)
            }
            completion(true)
        }
        
    }
    
    @IBAction func likeBtnClicked(_ sender: CheckClicked!) {
        var newAmount = 0
        let db = Firestore.firestore()
        let sfReference = db.collection("Bar Feeds").document("\(sender.title!)").collection("feed").document("\(sender.uid!)")
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let likedBy = sfDocument.data()?["likedBy"] as? [String] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from likedBy \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            guard let dislikedBy = sfDocument.data()?["dislikedBy"] as? [String] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from dislikedBy \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            var likedArray = [String]()
            likedArray = likedBy
            
            var dislikedArray = [String]()
            dislikedArray = dislikedBy
            
            for s in likedBy {
                if (s == AppDelegate.user?.uid){
                    if likedArray.contains(AppDelegate.user!.uid!){
                        let index = likedArray.firstIndex(of: AppDelegate.user!.uid!)
                        likedArray.remove(at: index!)
                    }
                    transaction.updateData(["dislikedBy" : dislikedArray], forDocument: sfReference)
                    transaction.updateData(["likedBy" : likedArray], forDocument: sfReference)
                    transaction.updateData(["likes": likedArray.count - dislikedArray.count], forDocument: sfReference)
                    
                    for p in FirstViewController.allPosts{
                        if p.uid == sender.uid {
                            p.likes = likedArray.count - dislikedArray.count
                            if p.likedBy.contains(AppDelegate.user!.uid!){
                                let index = p.likedBy.firstIndex(of: AppDelegate.user!.uid!)
                                p.likedBy.remove(at: index!)
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        //self.tableView?.reloadData()
                        self.likesLbl.text = "\(likedArray.count - dislikedArray.count)"
                        self.likeBtn.setImage(UIImage(named: "up30"), for: .normal)
                        self.dislikeBtn.setImage(UIImage(named: "down30"), for: .normal)
                    }
                    return nil
                }
            }
            
            for i in 0 ..< dislikedArray.count {
                if (dislikedArray[i] == AppDelegate.user?.uid) {
                    dislikedArray.remove(at: i)
                }
            }
            
            likedArray.append(AppDelegate.user!.uid!)
            transaction.updateData(["dislikedBy" : dislikedArray], forDocument: sfReference)
            transaction.updateData(["likedBy" : likedArray], forDocument: sfReference)
            transaction.updateData(["likes": likedArray.count - dislikedArray.count], forDocument: sfReference)
            
            for p in FirstViewController.allPosts{
                if p.uid == sender.uid {
                    p.likes = likedArray.count - dislikedArray.count
                    p.likedBy.append(AppDelegate.user!.uid!)
                    if p.dislikedBy.contains(AppDelegate.user!.uid!){
                        let index = p.dislikedBy.firstIndex(of: AppDelegate.user!.uid!)
                        p.dislikedBy.remove(at: index!)
                    }
                }
            }
            
            DispatchQueue.main.async {
                //self.tableView?.reloadData()
                self.likesLbl.text = "\(likedArray.count - dislikedArray.count)"
                self.likeBtn.setImage(UIImage(named: "grayup30"), for: .normal)
                self.dislikeBtn.setImage(UIImage(named: "down30"), for: .normal)
            }
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
    
    @IBAction func dislikeBtnClicked(_ sender: CheckClicked!) {
        var newAmount = 0
        let db = Firestore.firestore()
        let sfReference = db.collection("Bar Feeds").document("\(sender.title!)").collection("feed").document("\(sender.uid!)")
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let likedBy = sfDocument.data()?["likedBy"] as? [String] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from likedBy \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            guard let dislikedBy = sfDocument.data()?["dislikedBy"] as? [String] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from dislikedBy \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            var dislikedArray = [String]()
            dislikedArray = dislikedBy
            
            var likedArray = [String]()
            likedArray = likedBy
            
            for s in dislikedBy {
                if (s == AppDelegate.user?.uid){
                    if dislikedArray.contains(AppDelegate.user!.uid!){
                        let index = dislikedArray.firstIndex(of: AppDelegate.user!.uid!)
                        dislikedArray.remove(at: index!)
                    }
                    transaction.updateData(["dislikedBy" : dislikedArray], forDocument: sfReference)
                    transaction.updateData(["likedBy" : likedArray], forDocument: sfReference)
                    transaction.updateData(["likes": likedArray.count - dislikedArray.count], forDocument: sfReference)
                    
                    for p in FirstViewController.allPosts{
                        if p.uid == sender.uid {
                            p.likes = likedArray.count - dislikedArray.count
                            if p.dislikedBy.contains(AppDelegate.user!.uid!){
                                let index = p.dislikedBy.firstIndex(of: AppDelegate.user!.uid!)
                                p.dislikedBy.remove(at: index!)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        //self.tableView?.reloadData()
                        self.likesLbl.text = "\(likedArray.count - dislikedArray.count)"
                        self.likeBtn.setImage(UIImage(named: "up30"), for: .normal)
                        self.dislikeBtn.setImage(UIImage(named: "down30"), for: .normal)
                    }
                }
                return nil
            }
            
            for i in 0 ..< likedArray.count {
                if (likedArray[i] == AppDelegate.user?.uid) {
                    likedArray.remove(at: i)
                }
            }
            
            dislikedArray.append(AppDelegate.user!.uid!)
            
            transaction.updateData(["dislikedBy" : dislikedArray], forDocument: sfReference)
            transaction.updateData(["likedBy" : likedArray], forDocument: sfReference)
            transaction.updateData(["likes": likedArray.count - dislikedArray.count], forDocument: sfReference)
            
            for p in FirstViewController.allPosts{
                if p.uid == sender.uid {
                    p.likes = likedArray.count - dislikedArray.count
                    p.dislikedBy.append(AppDelegate.user!.uid!)
                    if p.likedBy.contains(AppDelegate.user!.uid!){
                        let index = p.likedBy.firstIndex(of: AppDelegate.user!.uid!)
                        p.likedBy.remove(at: index!)
                    }
                }
            }
            
            DispatchQueue.main.async {
                //self.tableView?.reloadData()
                self.likesLbl.text = "\(likedArray.count - dislikedArray.count)"
                self.likeBtn.setImage(UIImage(named: "up30"), for: .normal)
                self.dislikeBtn.setImage(UIImage(named: "graydown30"), for: .normal)
            }
            
//            DispatchQueue.main.async {
//                self.tableView?.reloadData()
//                sender.cell.dislikeBtn.setImage(UIImage(named: "graydown30"), for: .normal)
//                sender.cell.likeBtn.setImage(UIImage(named: "up30"), for: .normal)
//            }
                
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
    
    @IBAction func commentLikeClicked(_ sender: CheckClicked!) {
    }
    
    @IBAction func commentDislikeClicked(_ sender: CheckClicked!) {
    }
    
    @IBAction func back(_ sender: Any){
        print("Hi")
    }
    
    

}
