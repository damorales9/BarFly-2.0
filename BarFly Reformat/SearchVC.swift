//
//  SearchVC.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/3/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

class SearchVC: UITableViewController, UISearchResultsUpdating {

    
    
    @IBOutlet weak var socialView: UIView!
    
    var filteredTableData = [User]()
    var resultSearchController = UISearchController()
    @IBOutlet weak var feedView: UITableView!
    
    var timestampData = [User?]()
    
    override func viewDidLoad() {
        
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.placeholder = "Find a User"
            controller.searchBar.sizeToFit()
            controller.searchBar.barStyle = .black
            controller.searchBar.searchTextField.textColor = UIColor(red:0.71, green:1.00, blue:0.99, alpha:1.0)
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        resultSearchController.searchBar.becomeFirstResponder();
        
        // Reload the table
        
        tableView.rowHeight = 60
        
        feedView.rowHeight = 70
        
        feedView.delegate = tableView.delegate

        feedView.dataSource = tableView.dataSource
        
        feedView.reloadData()
        
        tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getTimestampData()
    }
    
    func getTimestampData() {
        timestampData.removeAll()
//        self.feedView.reloadData()
        
        User.getUser(uid: AppDelegate.user!.uid!) { (user) in
            
            for i in user!.friends {
                User.getUser(uid: i!) { (user) in
                    if(user?.bar != "nil") {
                        self.timestampData.append(user)
                        self.timestampData.sort(by: { (user1, user2) -> Bool in
                            return (user1?.timestamp!.doubleValue)! > (user2?.timestamp!.doubleValue)!
                        })
                        self.feedView.reloadData()
                    }
                }
            }
            
            
        }
    }
    
    func updateSearchResults(for searchController:
        UISearchController) {
        
        filteredTableData.removeAll(keepingCapacity: false)

        
        let db = Firestore.firestore()
        db.collection(LoginVC.USER_DATABASE).getDocuments { (snapshot, error) in
            
            if error != nil {
                print(error as Any)
                print("Error when getting UID list from firebase")
            }
            
            var x = 0
            for document in (snapshot?.documents)!{
                let userRef = db.collection(LoginVC.USER_DATABASE)
                let docRef = userRef.document("\(document.documentID)")
                docRef.getDocument { (document, error) in
                    let name = ((document!.get("name")) as! String)
                    let username = ((document!.get("username")) as! String)
                    let bar = ((document!.get("bar")) as! String)
                    let friends = ((document!.get("friends")) as! [String])
                    let profileURL = ((document!.get("profileURL")) as! String)
                    let requests = [String]()
                    
                    if (username.contains(self.resultSearchController.searchBar.text!.lowercased())) {
                        print("adding \(username)")
                        let u = User(uid: document?.documentID, name: name, username: username, bar: bar, friends: friends, requests: requests, profileURL: profileURL)
                        
                        var dup = false
                        for i in self.filteredTableData {
                            if(i.uid == u.uid) {
                                dup = true
                            }
                        }
                        if(!dup) {
                            self.filteredTableData.append(u)
                            self.tableView.reloadData()
                            x = x + 1
                        }
                        
                    }
                }
                
                if(x > 20) {
                    break
                }
            }
        }
        
        self.tableView.reloadData()
        self.feedView.reloadData()
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.tableView){
        
            // return the number of rows
            if  (resultSearchController.isActive) {
                return filteredTableData.count
            } else {
                return 0
            }
            
        } else if(!resultSearchController.isActive) {
            
            print("getting this bad boy and he is \(timestampData.count)")
            return timestampData.count
            
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == self.tableView) {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            print("trying to show something!")
            
            if (resultSearchController.isActive) {
                cell.textLabel?.text = filteredTableData[indexPath.row].username
                cell.detailTextLabel?.text = filteredTableData[indexPath.row].name
                
                
                cell.imageView?.clipsToBounds = true
                cell.imageView?.layer.cornerRadius = 24
                cell.imageView?.layer.borderWidth = 1
                cell.imageView?.layer.borderColor = UIColor.white.cgColor
                cell.imageView?.contentMode = .scaleToFill
                
                var placeholder: UIImage?
                if #available(iOS 13.0, *) {
                    placeholder = UIImage(systemName: "person.circle")
                } else {
                    // Fallback on earlier versions
                    placeholder = UIImage(named: "profile")
                }

                if (filteredTableData[indexPath.row].profileURL != "") {

                    let storage = Storage.storage()
                    let httpsReference = storage.reference(forURL: filteredTableData[indexPath.row].profileURL!)


                    cell.imageView?.sd_setImage(with: httpsReference, placeholderImage: placeholder)


                } else {
                    cell.imageView?.image = placeholder
                }
                
                cell.imageView?.image = cell.imageView?.image!.resizeImageWithBounds(bounds: CGSize(width: 50, height: 50))
                
                
                return cell
            }
            else {
                return cell
            }
            
        } else {
            
            let cell = feedView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! TimestampCell
            
            //getting time number
            let ti = NSInteger(NSNumber(value: NSDate().timeIntervalSince1970).doubleValue - (timestampData[indexPath.row]!.timestamp?.doubleValue)!)
            
            
            let seconds = ti % 60
            let minutes = (ti / 60) % 60
            let hours = (ti / 3600)
            
            if hours == 1 {
                cell.timeLbl.text = "1 hour"
            } else if hours > 1 {
                cell.timeLbl.text = "\(hours) hours"
            } else {
                if minutes == 1 {
                    cell.timeLbl.text = "1 minute"
                } else if minutes > 1{
                    cell.timeLbl.text = "\(minutes) minutes"
                } else {
                    if seconds == 1 {
                        cell.timeLbl.text = "1 second"
                    } else if seconds > 1 {
                        cell.timeLbl.text = "\(seconds) seconds"
                    } else {
                        cell.timeLbl.text = "now"
                    }
                }
            }
            
            cell.nameLbl.text = timestampData[indexPath.row]?.name
            cell.choiceLbl.text = timestampData[indexPath.row]?.bar
            
            cell.timeView.layer.borderWidth = 2
            cell.timeView.layer.borderColor = UIColor.barflyblue.cgColor
            cell.timeView.layer.cornerRadius = 20
            
            return cell
        }
          
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        User.getUser(uid: filteredTableData[indexPath.row].uid!, setFunction: {(user: User?) -> Void in
            NonUserProfileVC.nonUser = user!
                
            self.dismiss(animated: true) {
                self.performSegue(withIdentifier: "showNonUser", sender: self)
            }
        })
        
    }
}

extension UIImage {
    func resizeImageWithBounds(bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width/size.width
        let verticalRatio = bounds.height/size.height
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
