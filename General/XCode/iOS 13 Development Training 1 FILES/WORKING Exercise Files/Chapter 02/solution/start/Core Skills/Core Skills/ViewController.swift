//
//  ViewController.swift
//  Core Skills
//
//  Created by Todd Perkins on 9/21/19.
//  Copyright © 2019 Todd Perkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var myTextField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        myLabel.text = "Changed with Code!"
        myTextField.becomeFirstResponder()
        myTextField.delegate = self
        lastNameField.delegate = self
    }

    @IBAction func buttonWasPressed(_ sender: UITextField) {
        myLabel.text = "Hello \(myTextField.text!) \(lastNameField.text!)!"
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}

