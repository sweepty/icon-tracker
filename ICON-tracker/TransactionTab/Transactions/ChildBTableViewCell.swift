//
//  ChildBTableViewCell.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 23/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit

class ChildBTableViewCell: UITableViewCell {

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var txHashLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
