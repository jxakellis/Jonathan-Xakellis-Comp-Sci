//
//  DogsRequirementNavigationViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsRequirementNavigationViewControllerDelegate {
    func didUpdateRequirements(newRequirementList: [Requirement])
}

class DogsRequirementNavigationViewController: UINavigationController, DogsRequirementTableViewControllerDelegate {
    
    //MARK: Properties
    
    //This delegate is used in order to connect the delegate from the sub table view to the master embedded view, i.e. connect DogsRequirementTableViewController delegate to DogsAddDogViewController
    var passThroughDelegate: DogsRequirementNavigationViewControllerDelegate! = nil
    
    //MARK: DogsRequirementTableViewControllerDelegate
    
    func didUpdateRequirements(newRequirementList: [Requirement]) {
        passThroughDelegate.didUpdateRequirements(newRequirementList: newRequirementList)
    }
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sets DogsRequirementTableViewController delegate to self, this is required to pass through the data to DogsAddDogViewController as this navigation controller is in the way.
        let dogsRequirementTableViewController = self.viewControllers[self.viewControllers.count-1] as! DogsRequirementTableViewController
        dogsRequirementTableViewController.delegate = self
    }
}
