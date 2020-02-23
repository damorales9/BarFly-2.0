//
//  BlockVC.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/21/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

class BlockVC: UITableViewController, UISearchResultsUpdating {
    
    var filteredSearchResults = [User?]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        
        resultSearchController = ({
            
            
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.placeholder = "Search blocked users"
            controller.searchBar.sizeToFit()
            controller.searchBar.barStyle = .black
            controller.searchBar.searchTextField.textColor = UIColor(red:0.71, green:1.00, blue:0.99, alpha:1.0)
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true
        
        tableView.reloadData()
    
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredSearchResults.removeAll()
        
        var x = 0
        for i in AppDelegate.user!.blocked {
            User.getUser(uid: i!) { (user) in
                
                if let user = user, let username = user.username {
            
                    if(username.lowercased().contains(self.resultSearchController.searchBar.text!.lowercased())) {
                
                        
                        var dup = false
                        for i in self.filteredSearchResults {
                            if i?.username == username {
                                dup = true
                            }
                        }
                        
                        if !dup {
                            self.filteredSearchResults.append(user)
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.isActive {
            return filteredSearchResults.count
        } else if ((AppDelegate.user?.blocked.count)! > 20) {
            return 20
        } else {
            return (AppDelegate.user?.blocked.count)!
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if resultSearchController.isActive {
            
            cell.textLabel?.text = filteredSearchResults[indexPath.row]?.username
            cell.detailTextLabel?.text = filteredSearchResults[indexPath.row]?.name
            
            
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

            if (filteredSearchResults[indexPath.row]?.profileURL != "") {

                cell.imageView!.kf.setImage(with: URL(string: (filteredSearchResults[indexPath.row]?.profileURL!)!), placeholder: placeholder, options: [.scaleFactor(50)])

            } else {
                cell.imageView?.image = placeholder
            }
            
        } else {
            
            User.getUser(uid: (AppDelegate.user?.blocked[indexPath.row])!) { (user) in
                
                cell.textLabel?.text = user?.username
                cell.detailTextLabel?.text = user?.name
                
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

                if (user?.profileURL != "") {
                    cell.imageView!.kf.setImage(with: URL(string: user!.profileURL!), placeholder: placeholder, options: [.scaleFactor(50)])
                } else {
                    cell.imageView?.image = placeholder
                }
                
            }
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(resultSearchController.isActive) {
            
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let userVC = storyBoard.instantiateViewController(withIdentifier: "nonUserProfileVC") as! NonUserProfileVC
            userVC.nonUser = filteredSearchResults[indexPath.row]
            self.resultSearchController.dismiss(animated: true)
            self.navigationController?.pushViewController(userVC, animated:true)
            
        } else {
            
            User.getUser(uid: (AppDelegate.user?.blocked[indexPath.row])!) { (user) in
            
                let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                let userVC = storyBoard.instantiateViewController(withIdentifier: "nonUserProfileVC") as! NonUserProfileVC
                userVC.nonUser = user!
                self.resultSearchController.dismiss(animated: true)
                self.navigationController?.pushViewController(userVC, animated:true)
                
            }
            
            
        }
            
    }
}
