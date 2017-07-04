//
//  ChannelListTableCell.swift
//  Astro_Assignment
//
//  Created by Kundan Jadhav on 6/23/17.
//  Copyright © 2017 Kundan. All rights reserved.
//

import UIKit

class ChannelListTableCell: UITableViewCell {

    @IBOutlet var channelLogoImg: UIImageView!
    @IBOutlet weak var ChNameLabel: UILabel!
    @IBOutlet weak var ChNumberLabel: UILabel!
    @IBOutlet weak var markFavBtn: UIImageView!
    let gradientView = GradientView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundView = gradientView
        gradientView.colors = [
            .white,
            UIColor(red: 239, green: 87, blue: 76, alpha: 0.9)
        ]

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
