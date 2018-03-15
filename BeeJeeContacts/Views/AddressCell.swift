//
//  AddressCell.swift
//  BeeJeeContacts
//
//  Created by Karlygash Zhuginissova on 3/15/18.
//  Copyright © 2018 Karlygash Zhuginissova. All rights reserved.
//

import UIKit

class AddressCell: UITableViewCell, UITextFieldDelegate {
    var delegate: ClearButtonTappable?
    var textDelegate: TextFieldDidChange?
    
    @IBOutlet var zipTextField: UITextField!
    @IBOutlet var countryTextField: UITextField!
    @IBOutlet var stateTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var s2TextField: UITextField!
    @IBOutlet var s1TextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        s1TextField.delegate = self
        s2TextField.delegate = self
        cityTextField.delegate = self
        stateTextField.delegate = self
        countryTextField.delegate = self
        zipTextField.delegate = self
        // Initialization code
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textDelegate?.textFieldDidChange(cell: self)
    }

    @IBAction func onDelete(_ sender: Any) {
        delegate?.clear(cell: self)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
