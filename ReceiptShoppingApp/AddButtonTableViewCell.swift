//
//  AddButtonTableViewCell.swift
//  ReceiptShoppingApp
//
//  Created by NOZOMI ISHII on 2023/10/09.
//

import UIKit

protocol TableViewDelegate {
    func buttonTapAction()
}

class AddButtonTableViewCell: UITableViewCell {
    @IBOutlet weak var addCellButton: UIButton!
    
    var delegate: TableViewDelegate?
    
    
    @IBAction func addCellButton(_ sender: Any) {
        delegate?.buttonTapAction()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

