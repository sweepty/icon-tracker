//
//  ChildATableViewCell.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 30/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit

class ChildATableViewCell: UITableViewCell {

    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var txCountLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
