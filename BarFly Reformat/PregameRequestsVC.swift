//
//  PregameRequestsVC.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 2/24/20.
//  Copyright © 2020 LoFi Games. All rights reserved.
//

import Foundation
import UIKit


class PregameRequestsVC: UITableViewController {
    
    @IBOutlet var tableVIew: UITableView!
    
    override func viewDidLoad() {
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true

        self.title = "Requests"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = AppDelegate.user, let pregameID = user.pregames[indexPath.row] {
            Pregame.getPregame(uid: pregameID) { (pregame) in
                let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                let pregameVC = storyBoard.instantiateViewController(withIdentifier: "pregameVC") as! PregameVC
                pregameVC.pregame = pregame!
                self.navigationController?.pushViewController(pregameVC, animated:true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "pregameCell", for: indexPath) as! PregameRequestCell
        
        if let user = AppDelegate.user, let pregameID = user.pregames[indexPath.row] {
            Pregame.getPregame(uid: pregameID) { (pregame) in
                User.getUser(uid: (pregame?.createdBy)!) { (creator) in
                    if let name = creator?.name, let location = pregame?.location, let date = pregame?.date, let url = creator?.profileURL {
                        
                        cell.profileImage?.clipsToBounds = true
                        cell.profileImage?.layer.cornerRadius = 24
                        cell.profileImage?.layer.borderWidth = 1
                        cell.profileImage?.layer.borderColor = UIColor.white.cgColor
                        cell.profileImage?.contentMode = .scaleToFill
                        
                        if (pregame?.invited.contains(user.uid))! {
                            cell.accept.tag = indexPath.row
                            cell.decline.tag = indexPath.row

                            cell.accept.addTarget(self, action: #selector(self.acceptClicked), for: .touchUpInside)
                            cell.decline.addTarget(self, action: #selector(self.declineClicked), for: .touchUpInside)
                        }
                        cell.accept.tag = indexPath.row
                        cell.decline.tag = indexPath.row

                        cell.accept.addTarget(self, action: #selector(self.acceptClicked), for: .touchUpInside)
                        cell.decline.addTarget(self, action: #selector(self.declineClicked), for: .touchUpInside)
                        
                        cell.profileImage.kf.setImage(with: URL(string: url))
                        cell.pregame.text = "\(name) invited you to a pregame!"
                        cell.date.text = "\(date) at \(location)"
                        cell.accept.tag = indexPath.row
                        
                    }
                }
            }
        }
        
        return cell
        
    }
    
    @objc func acceptClicked(sender: UIButton) {
        if let user = AppDelegate.user, let pregameID = user.pregames[sender.tag] {
            Pregame.getPregame(uid: pregameID) { (pregame) in
                var p = pregame
                
                p?.invited.remove(at: p?.invited.firstIndex(of: user.uid))
                p.accepted.
            }
        }
          User.getUser(uid: (AppDelegate.user?.requests[sender.tag])!) { ( user: User?) in
              
              var u = user!
              
              AppDelegate.user?.followers.append(u.uid)
              u.friends.append(AppDelegate.user?.uid)
              AppDelegate.user?.requests.remove(at: sender.tag)
              
              User.updateUser(user: u)
              User.updateUser(user: AppDelegate.user)
              
              self.tableView.reloadData()
              
              (self.tabBarController as! TabBarController).findAndUpdate()
              
          }
    }
    
    @objc func declineClicked(sender: UIButton) {
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let user = AppDelegate.user {
            
            if user.pregames.count == 0 {
                let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = "No pregames you longely piece of shit"
                noDataLabel.textColor     = UIColor.barflyblue
                noDataLabel.textAlignment = .center
                noDataLabel.font = UIFont(name: "Roboto-Thin", size: 20)
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
            return user.pregames.count
        } else {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No pregames you longely piece of shit"
            noDataLabel.textColor     = UIColor.barflyblue
            noDataLabel.textAlignment = .center
            noDataLabel.font = UIFont(name: "Roboto-Thin", size: 20)
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
            return 0
        }
        
    }
}
