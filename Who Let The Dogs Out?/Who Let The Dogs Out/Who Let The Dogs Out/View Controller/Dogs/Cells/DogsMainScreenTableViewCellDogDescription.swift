//
//  DogsMainScreenTableViewCellDogDescription.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/11/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsMainScreenTableViewCellDogDisplayDelegate{
    func didToggleDogSwitch(sender: Sender, dogName: String, isEnabled: Bool)
    func didClickTrash(sender: Sender, dogName: String)
}

class DogsMainScreenTableViewCellDogDisplay: UITableViewCell {
    
    
    //MARK: Properties
    
    var dog: Dog = Dog()
    
    var delegate: DogsMainScreenTableViewCellDogDisplayDelegate! = nil
    
    //MARK: IB Links
    
    @IBOutlet weak var dogName: UILabel!
    
    @IBOutlet weak var dogDescription: UILabel!
    
    @IBOutlet weak var dogToggleSwitch: UISwitch!
    
    //Occurs when the on off switch is toggled
    @IBAction func didToggleDogSwitch(_ sender: Any) {
        dog.setEnable(newEnableStatus: dogToggleSwitch.isOn)
        try! delegate.didToggleDogSwitch(sender: Sender(origin: self, localized: self), dogName: dog.dogSpecifications.getDogSpecification(key: "name"), isEnabled: self.dog.getEnable())
    }
    
    @IBAction func didClickTrash(_ sender: Any) {
        try! delegate.didClickTrash(sender: Sender(origin: self, localized: self), dogName: dog.dogSpecifications.getDogSpecification(key: "name"))
    }
    
    //MARK: General Functions
    
    //Function used externally to setup dog
    func setup(dogPassed: Dog){
        dog = dogPassed
        try! self.dogName.text = dogPassed.dogSpecifications.getDogSpecification(key: "name")
        try! self.dogDescription.text = dogPassed.dogSpecifications.getDogSpecification(key: "description")
        if self.dogDescription.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            self.dogDescription.text? = "No Description"
        }
        self.dogToggleSwitch.isOn = dogPassed.getEnable()
    }
    
    //MARK: Default Functionality
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dogName.adjustsFontSizeToFitWidth = true
        self.dogDescription.adjustsFontSizeToFitWidth = true
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
