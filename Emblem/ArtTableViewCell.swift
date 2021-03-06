//
//  ArtTableViewCell.swift
//  Emblem
//
//  Created by Dane Jordan on 8/12/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import UIKit

class ArtTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var statView: UIView!
    @IBOutlet weak var upvoteLabel: UILabel!
    @IBOutlet weak var downvoteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if let statView = statView {
            statView.layer.cornerRadius = 10
            statView.layer.masksToBounds = true
            statView.layer.opacity = 0.5
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
