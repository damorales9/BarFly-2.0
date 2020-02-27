//
//  PostCell.swift
//  BarFly Reformat
//
//  Created by Derek Morales on 2/20/20.
//  Copyright © 2020 LoFi Games. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet var messageText: UILabel!
    @IBOutlet var likeBtn: CheckClicked!
    @IBOutlet var dislikeBtn: CheckClicked!
    @IBOutlet var amntLikes: UILabel!
    
    @IBOutlet var commentMsg: UILabel!
    @IBOutlet var commentMsgLike: CheckClicked!
    @IBOutlet var commentMsgDislike: CheckClicked!
    @IBOutlet var commentLikes: UILabel!
    
    

}
