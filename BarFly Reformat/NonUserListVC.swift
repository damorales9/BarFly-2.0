//
//  NonUserListVC.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/18/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage

class NonUserListVC: UITableViewController, UISearchResultsUpdating {
    
    var isFollowers: Bool?
    
    var filteredTableData = [User]()
    
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
                return filteredTableData.count
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
                            
                    
                } else {
                    
                    User.getUser(uid: user.friends[indexPath.row]!) { (u) in
                        
                        if let u = u {
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

extension StringProtocol {
    func indexDistance(of element: Element) -> Int? { firstIndex(of: element)?.distance(in: self) }
    func indexDistance<S: StringProtocol>(of string: S) -> Int? { range(of: string)?.lowerBound.distance(in: self) }
}
extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(from: string.startIndex, to: self) }
}

extension UIImageView {
    
    func getImage(ref: String, placeholder: UIImage, maxMB: Int) {
        self.getImage(ref: ref, placeholder: placeholder, maxMB: maxMB, completion: {
            //convenience
        })
    }
    
    func getImage(ref: String, placeholder: UIImage, maxMB: Int, completion: @escaping () -> Void) {
//        ref.getData(maxSize: Int64(maxMB * 1024 * 1024)) { data, error in
//            if error != nil {
//                self.image = placeholder
//          } else {
//                self.image = UIImage(data: data!)
//          }
//
//            completion()
//        }
        dnldImage(from: URL(string: ref)!, completion: { (image) in
            self.image = image
            completion()
        }, error: {
            self.image = placeholder
            completion()
        })
    }
    
    
    static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    static func downloadImage(from url: URL, completion: @escaping (UIImage) -> Void, error: @escaping () -> Void) {
        print("Download Started for image at \(url.absoluteString)")
        getData(from: url) { data, response, err in
            guard let data = data, err == nil else {
                error()
                return
            }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                completion(UIImage(data: data)!)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func dnldImage(from url: URL, completion: @escaping (UIImage) -> Void, error: @escaping () -> Void) {
        print("Download Started for image at \(url.absoluteString)")
        getData(from: url) { data, response, err in
            guard let data = data, err == nil else {
                error()
                return
            }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                completion(UIImage(data: data)!)
            }
        }
    }
}
