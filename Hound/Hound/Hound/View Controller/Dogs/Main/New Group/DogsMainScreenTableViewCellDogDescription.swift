//
//  DogsMainScreenTableViewCellDogDescription.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/11/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class DogsMainScreenTableViewCellDogDisplay: UITableViewCell {
    
    //MARK: - IB
    
    
    @IBOutlet private weak var dogIcon: UIImageView!
    
    @IBOutlet private weak var dogName: CustomLabel!
    
    @IBOutlet private weak var nextReminder: CustomLabel!
    
    //MARK: - Properties
    
    var dog: Dog = Dog()
    
    //MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dogName.adjustsFontSizeToFitWidth = true
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //Function used externally to setup dog
    func setup(dogPassed: Dog){
        dog = dogPassed
        
        dogIcon.image = dogPassed.dogTraits.icon
        dogIcon.layer.masksToBounds = true
        if dogIcon.image != DogConstant.defaultIcon{
            dogIcon.layer.cornerRadius = dogIcon.frame.width/2
        }
        
        self.dogName.text = dogPassed.dogTraits.dogName
        
        setupTimeLeftText()
    }
    
    func reloadCell(){
        setupTimeLeftText()
    }
    
    private func setupTimeLeftText(){
        
        let nextReminderBodyWeight: UIFont.Weight = .regular
        let nextReminderImportantWeight: UIFont.Weight = .semibold
        
        if dog.dogRequirments.requirements.count == 0{
            nextReminder.attributedText = NSAttributedString(string: "No Reminders Created", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderImportantWeight)])
        }
        //if paused but has an enabled requirement...
        else if TimingManager.isPaused == true && dog.hasEnabledRequirement == true {
            var allRequirementsEnabled: Bool{
                for requirement in dog.dogRequirments.requirements{
                    if requirement.getEnable() == false {
                        return false
                    }
                }
                return true
            }
            //no disabled reminders, all are enabled
            if allRequirementsEnabled == true {
                nextReminder.attributedText = NSAttributedString(string: "All Reminders Paused", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderImportantWeight)])
            }
            //mix of disabled and enabled reminders
            else {
                nextReminder.attributedText = NSAttributedString(string: "No Active Reminders", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderImportantWeight)])
            }
            
        }
        else if dog.hasEnabledRequirement == false {
            nextReminder.attributedText = NSAttributedString(string: "All Reminders Disabled", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderImportantWeight)])
        }
        else if TimingManager.isPaused == true {
            
            nextReminder.attributedText = NSAttributedString(string: "All Reminders Paused", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderImportantWeight)])
            
        }
        else{
            //has atleast once enabled requirement so soonsetFireDate won't be nil by the end
            var soonestFireDate: Date! = nil
            for requirement in dog.dogRequirments.requirements{
                guard requirement.getEnable() else {
                    continue
                }
                if soonestFireDate == nil {
                    soonestFireDate = requirement.executionDate!
                }
                else {
                    if Date().distance(to: requirement.executionDate!) < Date().distance(to: soonestFireDate){
                        soonestFireDate = requirement.executionDate!
                    }
                }
            }
            
             if Date().distance(to: soonestFireDate!) <= 0 {
                let timeLeftText = " Now"
                
                nextReminder.font = UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderBodyWeight)
                
                nextReminder.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font : nextReminder.font!])
                
                nextReminder.attributedText = nextReminder.text!.addingFontToBeginning(text: "Next Reminder In: ", font: UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderImportantWeight))
            }
            else {
                let timeLeftText = String.convertToReadable(interperateTimeInterval: Date().distance(to: soonestFireDate))
                
                nextReminder.font = UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderBodyWeight)
                
                nextReminder.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font : nextReminder.font!])
                
                nextReminder.attributedText = nextReminder.text!.addingFontToBeginning(text: "Next Reminder In: ", font: UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderImportantWeight))
            }
        }
    }
    
}
