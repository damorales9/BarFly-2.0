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
    
    var pregames = [Pregame?]()
    var yourPres = [Pregame?]()

    
    override func viewDidLoad() {
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true

        self.title = "Requests"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        pregames.removeAll()
        
        if let user = AppDelegate.user, let uid = user.uid {
            
            User.getUser(uid: uid) { (u) in
                
                var x = u?.pregames.count
                for i in u!.pregames {
                    
                    Pregame.getPregame(uid: i!) { (pregame) in
                        if pregame?.createdBy == AppDelegate.user?.uid {
                            self.yourPres.append(pregame)
                        } else {
                            self.pregames.append(pregame)
                        }
                        x!+=1
                        if(x == u!.pregames.count) {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            
        }
        
        
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let pregameVC = storyBoard.instantiateViewController(withIdentifier: "pregameVC") as! PregameVC
        pregameVC.pregame = pregames[indexPath.row]!
        self.navigationController?.pushViewController(pregameVC, animated:true)

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        var pregame: Pregame!
        
        if indexPath.section == 0 && yourPres.count != 0 {
            pregame = yourPres[indexPath.row]
        } else {
            pregame = pregames[indexPath.row]
        }
        
        if ((pregame?.accepted.contains(AppDelegate.user?.uid))!) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "acceptedPregameCell", for: indexPath) as! PregameAcceptedCell
            
            User.getUser(uid: (pregame?.createdBy)!) { (creator) in
                if let name = creator?.name, let location = pregame?.location, let date = pregame?.date, let url = creator?.profileURL {
                    
                    cell.profileImage?.clipsToBounds = true
                    cell.profileImage?.layer.cornerRadius = 24
                    cell.profileImage?.layer.borderWidth = 1
                    cell.profileImage?.layer.borderColor = UIColor.white.cgColor
                    cell.profileImage?.contentMode = .scaleToFill
                    
                    cell.cancel.tag = (AppDelegate.user?.pregames.firstIndex(of: pregame.uid))!

                    cell.cancel.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
                    
                    cell.profileImage.kf.setImage(with: URL(string: url))
                    cell.pregame.text = "You are going to \(name)'s pregame!"
                    cell.date.text = "\(date) at \(location)"
                    
                }
            }
            
            return cell
            
        } else if ((pregame?.declined.contains(AppDelegate.user?.uid))!) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "declinedPregameCell", for: indexPath) as! PregameDeclinedCell
            
            User.getUser(uid: (pregame?.createdBy)!) { (creator) in
                if let name = creator?.name, let location = pregame?.location, let date = pregame?.date, let url = creator?.profileURL {
                    
                    cell.profileImage?.clipsToBounds = true
                    cell.profileImage?.layer.cornerRadius = 24
                    cell.profileImage?.layer.borderWidth = 1
                    cell.profileImage?.layer.borderColor = UIColor.white.cgColor
                    cell.profileImage?.contentMode = .scaleToFill
                    
                    cell.cancel.tag = (AppDelegate.user?.pregames.firstIndex(of: pregame.uid))!

                    cell.cancel.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
                    
                    cell.profileImage.kf.setImage(with: URL(string: url))
                    cell.pregame.text = "You declined \(name)'s pregame invite"
                    cell.date.text = "\(date) at \(location)"
                    
                }
            }
            
            return cell
           
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "pregameCell", for: indexPath) as! PregameRequestCell
                       
           User.getUser(uid: (pregame?.createdBy)!) { (creator) in
               if let name = creator?.name, let location = pregame?.location, let date = pregame?.date, let url = creator?.profileURL {
                   
                   cell.profileImage?.clipsToBounds = true
                   cell.profileImage?.layer.cornerRadius = 24
                   cell.profileImage?.layer.borderWidth = 1
                   cell.profileImage?.layer.borderColor = UIColor.white.cgColor
                   cell.profileImage?.contentMode = .scaleToFill
                   
                   cell.accept.tag = (AppDelegate.user?.pregames.firstIndex(of: pregame.uid))!
                   cell.decline.tag = (AppDelegate.user?.pregames.firstIndex(of: pregame.uid))!

                   cell.accept.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
                   cell.decline.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
                   
                   cell.profileImage.kf.setImage(with: URL(string: url))
                   cell.pregame.text = "\(name) invited you to a pregame!"
                   cell.date.text = "\(date) at \(location)"
                   
               }
           }
           
           return cell
               
        }
        
    }
    
    @objc func buttonClicked(sender: UIButton) {
        
        if let user = AppDelegate.user, let uid = user.uid, let pregameID = user.pregames[sender.tag] {
            Pregame.getPregame(uid: pregameID) { (pregame) in
                if var p = pregame {
                
                    if (p.accepted.contains(uid)) {
                        p.invited.append(uid)
                        p.accepted.remove(at: (p.accepted.firstIndex(of: uid))!)
                    } else if (p.declined.contains(user.uid)) {
                        p.invited.append(uid)
                        p.declined.remove(at: (p.declined.firstIndex(of: uid))!)
                    } else {
                        p.accepted.append(uid)
                        p.invited.remove(at: (p.invited.firstIndex(of: uid))!)
                    }
                
                    Pregame.updatePregame(pregame: p)
                    self.tableView.reloadData()
                    
                }

            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if yourPres.count == 0 {
            return 1
        } else {
            return 2
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 && yourPres.count != 0 {
           
            return yourPres.count
            
        } else {
        
            if pregames.count <= 0 {
                let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = "No pregames you longely piece of shit"
                noDataLabel.textColor     = UIColor.barflyblue
                noDataLabel.textAlignment = .center
                noDataLabel.font = UIFont(name: "Roboto-Thin", size: 20)
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
            return pregames.count
        }
        
    }

}
