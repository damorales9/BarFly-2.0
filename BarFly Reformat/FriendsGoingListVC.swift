//
//  NonUserListVC.swift
//  BarFly Reformat
//
//  Created by Derek Morales on 11/18/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage

class FriendsGoingListVC: UITableViewController, UISearchResultsUpdating {
    
    var isFollowers: Bool?
    
    var filteredTableData = [User]()
    
    var friendsGoingList = [User]()
    
    var bar: String?
    
    var nonUser: User?
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true
        
        //setup search bar
        resultSearchController = ({
            
            var str = ""
            if(isFollowers!) {
                str = "followers"
            } else {
                str  = "friends"
            }
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.placeholder = "Search \(self.getName()) \(str)"
            controller.searchBar.sizeToFit()
            controller.searchBar.barStyle = .black
            controller.searchBar.searchTextField.textColor = UIColor(red:0.71, green:1.00, blue:0.99, alpha:1.0)
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        for friend in AppDelegate.user!.friends{
            User.getUser(uid: friend!) { (user) in
                if (user?.bar == self.bar){
                    self.friendsGoingList.append(user!)
                }
            }
        }
        
        print(friendsGoingList)
        
        tableView.reloadData()
        
    }
    
    func getName() -> String {
    
        if let user = nonUser, let name = user.username {
            
            if name == AppDelegate.user?.username {
                return "your"
            }
            
            //NAME IS USERNAME I WAS TOO LAZY TO CHANGE THE NAME
            if(name.indexDistance(of: "s") == name.count-1) {
                return "\(name)'"
            } else {
                return "\(name)'s"
            }
        }
        return "Chungus'"
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredTableData.removeAll(keepingCapacity: false)
        
        var x = 0
        
        if isFollowers! {
            
            for i in (nonUser?.followers)!  {
                
                User.getUser(uid: i!) { (user) in
                    
                    if let user = user, let username = user.username {
                
                        if(username.lowercased().contains(self.resultSearchController.searchBar.text!.lowercased())) {
                            
                            var dup = false
                            for j in self.filteredTableData {
                                if j.username == username {
                                    dup = true
                                }
                            }
                                    
                            if !dup {
                                self.filteredTableData.append(user)
                                self.tableView.reloadData()
                                x+=1
                            }
                            
                        }
                    }
                }
                
                if(x >= 20) {
                    break
                }
            }
        
        } else {
            
            for i in (nonUser?.friends)!  {
                User.getUser(uid: i!) { (user) in
                    
                    if let user = user, let username = user.username {
                
                        if(username.lowercased().contains(self.resultSearchController.searchBar.text!.lowercased())) {
                            
                            var dup = false
                            for j in self.filteredTableData {
                                if j.username == username {
                                    dup = true
                                }
                            }
                                    
                            if !dup {
                                self.filteredTableData.append(user)
                                self.tableView.reloadData()
                                x+=1
                            }
                            
                        }
                    }
                }
                
                if(x >= 20) {
                    break
                }
            }
            
            
            
        }
        
        
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            if !resultSearchController.isActive {
                
                if isFollowers! {
                    if let user = nonUser {
                        if user.followers.count < 20 {
                            return user.followers.count
                        } else {
                            return 20
                        }
                    } else {
                        return 0
                    }
                } else {
                    if((AppDelegate.user?.friends.count)! == 0) {
                        
                        let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                        noDataLabel.text          = "No requests you lonely piece of shit"
                        noDataLabel.textColor     = UIColor.barflyblue
                        noDataLabel.textAlignment = .center
                        noDataLabel.font = UIFont(name: "Roboto-Thin", size: 20)
                        tableView.backgroundView  = noDataLabel
                        tableView.separatorStyle  = .none
                        return 0
                    }
                    if let user = nonUser {
                        if user.friends.count < 20 {
                            return user.friends.count
                        } else {
                            return 20
                        }
                    } else {
                        return 0
                    }
                }
            } else {
                if((AppDelegate.user?.friends.count)! == 0) {
                    let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                    noDataLabel.text          = "No requests you lonely piece of shit"
                    noDataLabel.textColor     = UIColor.barflyblue
                    noDataLabel.textAlignment = .center
                    noDataLabel.font = UIFont(name: "Roboto-Thin", size: 20)
                    tableView.backgroundView  = noDataLabel
                    tableView.separatorStyle  = .none
                    return 0
                }
                else{
                    return filteredTableData.count
                }
            }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if (resultSearchController.isActive) {
            
            cell.textLabel?.text = filteredTableData[indexPath.row].username
            cell.detailTextLabel?.text = filteredTableData[indexPath.row].name
            
            
            cell.imageView?.clipsToBounds = true
            cell.imageView?.layer.cornerRadius = 24
            cell.imageView?.layer.borderWidth = 1
            cell.imageView?.layer.borderColor = UIColor.barflyblue.cgColor
            cell.imageView?.contentMode = .scaleToFill
            
            var placeholder: UIImage?
            if #available(iOS 13.0, *) {
                placeholder = UIImage(systemName: "person.circle")
            } else {
                // Fallback on earlier versions
                placeholder = UIImage(named: "profile")
            }

            if (filteredTableData[indexPath.row].profileURL != "") {

                cell.imageView?.getImage(ref: filteredTableData[indexPath.row].profileURL!, placeholder: placeholder!, maxMB: 40)


            } else {
                cell.imageView?.image = placeholder
            }
            
            cell.imageView?.image = cell.imageView?.image!.resizeImageWithBounds(bounds: CGSize(width: 50, height: 50))
            
            
            return cell
        }
        else {
            
            if let user = nonUser {
                
                if(isFollowers!) {
                    
                    User.getUser(uid: user.followers[indexPath.row]!) { (u) in
                        
                        if let u = u {
                            if (u.bar == self.bar){
                                cell.textLabel?.text = u.username
                                cell.detailTextLabel?.text = u.name
                                
                                cell.imageView?.clipsToBounds = true
                                cell.imageView?.layer.cornerRadius = 24
                                cell.imageView?.layer.borderWidth = 1
                                cell.imageView?.layer.borderColor = UIColor.barflyblue.cgColor
                                cell.imageView?.contentMode = .scaleToFill
                                
                                var placeholder: UIImage?
                                if #available(iOS 13.0, *) {
                                    placeholder = UIImage(systemName: "person.circle")
                                } else {
                                    // Fallback on earlier versions
                                    placeholder = UIImage(named: "profile")
                                }

                                if (u.profileURL != "") {

                                    cell.imageView?.getImage(ref: u.profileURL!, placeholder: placeholder!, maxMB: 40)


                                } else {
                                    cell.imageView?.image = placeholder
                                }
                                
                                cell.imageView?.image = cell.imageView?.image!.resizeImageWithBounds(bounds: CGSize(width: 50, height: 50))
                            }
                        }
                    }
                            
                    
                } else {
                    
                    User.getUser(uid: user.friends[indexPath.row]!) { (u) in
                        
                        if let u = u {
                            if (u.bar == self.bar){
                                cell.textLabel?.text = u.username
                                cell.detailTextLabel?.text = u.name
                                
                                cell.imageView?.clipsToBounds = true
                                cell.imageView?.layer.cornerRadius = 24
                                cell.imageView?.layer.borderWidth = 1
                                cell.imageView?.layer.borderColor = UIColor.barflyblue.cgColor
                                cell.imageView?.contentMode = .scaleToFill
                                
                                var placeholder: UIImage?
                                if #available(iOS 13.0, *) {
                                    placeholder = UIImage(systemName: "person.circle")
                                } else {
                                    // Fallback on earlier versions
                                    placeholder = UIImage(named: "profile")
                                }

                                if (u.profileURL != "") {
                                    
                                    cell.imageView?.getImage(ref: u.profileURL!, placeholder: placeholder!, maxMB: 40)
                                    
                                } else {
                                    cell.imageView?.image = placeholder
                                }
                                
                                cell.imageView?.image = cell.imageView?.image!.resizeImageWithBounds(bounds: CGSize(width: 50, height: 50))
                            }
                            
                        }
                    }
                }
                
            }
        
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(resultSearchController.isActive) {
            
            if(filteredTableData[indexPath.row].uid == AppDelegate.user?.uid) {
                
            } else {
            
                self.resultSearchController.dismiss(animated: true)
                self.navigationController?.popToRootViewController(animated: true)
                
            }
            
        } else {
            
            if isFollowers! {
                
                if(nonUser?.followers[indexPath.row] == AppDelegate.user?.uid) {
                    
                    self.resultSearchController.dismiss(animated: true)
                    self.navigationController?.popToRootViewController(animated: true)
                    
                } else {
                
                    User.getUser(uid: (nonUser?.followers[indexPath.row])!) { (user) in
                        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                        let userVC = storyBoard.instantiateViewController(withIdentifier: "nonUserProfileVC") as! NonUserProfileVC
                        userVC.nonUser = user!
                        self.resultSearchController.dismiss(animated: true)
                        self.navigationController?.pushViewController(userVC, animated:true)
                    }
                    
                }
                
                
            } else {
                
                if(nonUser?.friends[indexPath.row] == AppDelegate.user?.uid) {
                    
                    self.resultSearchController.dismiss(animated: true)
                    self.navigationController?.popToRootViewController(animated: true)
                    
                } else {
                
                    User.getUser(uid: (nonUser?.friends[indexPath.row])!) { (user) in
                        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                        let userVC = storyBoard.instantiateViewController(withIdentifier: "nonUserProfileVC") as! NonUserProfileVC
                        userVC.nonUser = user!
                        self.resultSearchController.dismiss(animated: true)
                        self.navigationController?.pushViewController(userVC, animated:true)
                    }
                    
                }
                
            }
            
            
        }
    }
}
