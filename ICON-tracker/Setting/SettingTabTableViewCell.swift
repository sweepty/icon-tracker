//
//  SettingTabTableViewCell.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 09/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingTabTableViewCell: UITableViewCell {
    
    @IBOutlet weak var switchButton: UISwitch!
    
    var cellBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textLabel?.theme.textColor = themeService.attrStream { $0.textColor }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
