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
import MapKit

class SearchVC: UITableViewController, UISearchResultsUpdating, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var socialView: UIView!
    
    var filteredTableData = [User]()
    var resultSearchController = UISearchController()
    @IBOutlet weak var feedView: UITableView!
    @IBOutlet weak var favoritesView: UICollectionView!
    
    
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
        
        tableView.reloadData()
        feedView.reloadData()
        favoritesView.reloadData()
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
                    let friends = ((document!.get("friends") ?? [String]()) as! [String])
                    let profileURL = ((document!.get("profileURL")) as! String)
                    let requests = [String]()
                    let favorites = [String]()
                    let followers = [String]()
                    let galleryURLs = [String]()
                    let blocked = [String]()
                    
                    if (username.contains(self.resultSearchController.searchBar.text!.lowercased())) {
                        print("adding \(username)")
                        let u = User(uid: document?.documentID, name: name, username: username, bar: bar, friends: friends, followers: followers, blocked: blocked, requests: requests, favorites: favorites, profileURL: profileURL, galleryURLs: galleryURLs)
                        
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
            
        } else if(!resultSearchController.isActive ||  resultSearchController.searchBar.text?.count == 0) {
            
            print("getting this bad boy and he is \(timestampData.count)")
            socialView.isHidden = false
            return timestampData.count
            
        } else {
            socialView.isHidden = true
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
            cell.timeView.layer.borderColor = UIColor.black.cgColor
            cell.timeView.layer.cornerRadius = 20
            
            cell.bgView.layer.cornerRadius = 30
            
            
            return cell
        }
          
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == self.tableView) {
            User.getUser(uid: filteredTableData[indexPath.row].uid!, setFunction: {(user: User?) -> Void in
                
                let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                let userVC = storyBoard.instantiateViewController(withIdentifier: "nonUserProfileVC") as! NonUserProfileVC
                userVC.nonUser = user!
                self.resultSearchController.dismiss(animated: true)
                self.navigationController?.pushViewController(userVC, animated:true)
            })
        } else {
            if(indexPath.row < timestampData.count) {
                User.getUser(uid: (timestampData[indexPath.row]?.uid!)!, setFunction: {(user: User?) -> Void in
                    let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                    let userVC = storyBoard.instantiateViewController(withIdentifier: "nonUserProfileVC") as! NonUserProfileVC
                    userVC.nonUser = user!
                    self.resultSearchController.dismiss(animated: true)
                    self.navigationController?.pushViewController(userVC, animated:true)
                })
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (AppDelegate.user?.favorites.count ?? 0) + 1
     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(indexPath.row < (AppDelegate.user?.favorites.count)!) {
            
            let cell = favoritesView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath) as! FavoriteBarCell
            
            CustomBarAnnotation.getBar(name: AppDelegate.user!.favorites[indexPath.row]!) { (bar) in
                
                var placeholder: UIImage?
                if #available(iOS 13.0, *) {
                    placeholder = UIImage(systemName: "circle")
                } else {
                    // Fallback on earlier versions
                    placeholder = UIImage(named: "pin")
                }

                cell.imageView?.getImage(ref: bar!.imageName!, placeholder: placeholder!, maxMB: 40)
                
                cell.nameLbl.text = bar?.title
                cell.guestsLbl.text = "\(bar!.amntPeople ?? 0)"
                
                cell.nameLbl.layer.cornerRadius = 5
                cell.guestsLbl.layer.cornerRadius = 5
                
                cell.layer.borderWidth = 2
                cell.layer.borderColor = UIColor.barflyblue.cgColor
                cell.layer.cornerRadius = 75
                
            }
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath)
            
            cell.layer.borderWidth = 2
            cell.layer.borderColor = UIColor.barflyblue.cgColor
            cell.layer.cornerRadius = 75
            
            return cell
            
        }
        
     }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(indexPath.row < (AppDelegate.user?.favorites.count)!) {

            CustomBarAnnotation.getBar(name: (AppDelegate.user!.favorites[indexPath.row])!) { (bar: inout CustomBarAnnotation?) in
                let mapVC = (self.tabBarController?.viewControllers![0]) as! UINavigationController
                self.tabBarController?.selectedIndex = 0
                mapVC.popToRootViewController(animated: true)
                if let fVC = mapVC.viewControllers[0] as? FirstViewController {
                    fVC.myMapView.setCenter(bar!.coordinate, animated: true)
                    
                    var currentBar: MKAnnotation!
                    currentBar = FirstViewController.getAnnotation(title: bar!.title!)
                    fVC.myMapView.selectAnnotation(currentBar!, animated: true)
                }
            }
            
            //DISPLAY DETAIL THINGY
        } else {
            let mapVC = (tabBarController?.viewControllers![0]) as! UINavigationController
            tabBarController?.selectedIndex = 0
            mapVC.popToRootViewController(animated: true)
            if let fVC = mapVC.viewControllers[0] as? FirstViewController {
                
                fVC.refresh(fVC)
                
            }
            
        }
        
        
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
