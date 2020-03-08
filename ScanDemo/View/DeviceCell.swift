//
//  DeviceCell.swift
//  ScanDemo
//
//  Created by 曾钊 on 2020/3/7.
//  Copyright © 2020 曾钊. All rights reserved.
//

import UIKit

class DeviceCell: UITableViewCell {

    @IBOutlet weak var ipAddrLabel: UILabel!
    @IBOutlet weak var macLabel: UILabel!
    @IBOutlet weak var hostName: UILabel!
    @IBOutlet weak var brand: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
