//
//  BlockDetailTableViewCell.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 07/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import ICONKit
import RxDataSources

class BlockDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var txHashLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        txHashLabel.text = nil
        fromLabel.text = nil
        toLabel.text = nil
        amountLabel.text = nil
    }

}

struct SectionOfCustomData {
    var items: [Response.Block.ConfirmedTransactionList]
}

extension SectionOfCustomData: SectionModelType {
    
    init(original: SectionOfCustomData, items: [Response.Block.ConfirmedTransactionList]) {
        self = original
        self.items = items
    }
}
