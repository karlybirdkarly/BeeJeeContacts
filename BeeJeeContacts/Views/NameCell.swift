//
//  NameCell.swift
//  BeeJeeContacts
//
//  Created by Karlygash Zhuginissova on 3/15/18.
//  Copyright © 2018 Karlygash Zhuginissova. All rights reserved.
//

import UIKit

class NameCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var textField: UITextField!
    var textDelegate: TextFieldDidChange?
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        self.textField.placeholder = "First Name"

        // Initialization code
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textDelegate?.textFieldDidChange(cell: self)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
