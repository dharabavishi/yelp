//
//  ExpandCell.swift
//  Yelp
//
//  Created by Ruchit Mehta on 10/21/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class ExpandCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expnadButton: UIButton!
    @IBOutlet weak var radioButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
            }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onExpandClick(_ sender: UIButton) {
    }
    
    @IBAction func onRadioButtonClick(_ sender: UIButton) {
    }
   

}
