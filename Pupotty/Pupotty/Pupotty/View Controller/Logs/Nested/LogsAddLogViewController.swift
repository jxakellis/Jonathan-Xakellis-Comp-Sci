//
//  LogsAddLogViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/30/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsAddLogViewControllerDelegate {
    func didDeleteKnownLog(sender: Sender, parentDogName: String, requirementUUID: String?, logUUID: String)
    func didAddKnownLog(sender: Sender, parentDogName: String, newKnownLog: KnownLog)
    func didUpdateKnownLog(sender: Sender, parentDogName: String, requirementUUID: String?, updatedKnownLog: KnownLog)
}

class LogsAddLogViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, MakeDropDownDataSourceProtocol {
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - MakeDropDownDataSourceProtocol
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, makeDropDownIdentifier: String) {
        if makeDropDownIdentifier == "dropDownParentDogName"{
            let customCell = cell as! DropDownDefaultTableViewCell
            customCell.adjustConstraints(newValue: 8.0)
            
            if selectedParentDogIndexPath == indexPath{
                customCell.didToggleSelect(newSelectionStatus: true)
            }
            else {
                customCell.didToggleSelect(newSelectionStatus: false)
            }
            
            customCell.label.text = dogManager.dogs[indexPath.row].dogTraits.dogName
        }
        else if makeDropDownIdentifier == "dropDownLogType"{
            let customCell = cell as! DropDownDefaultTableViewCell
            customCell.adjustConstraints(newValue: 8.0)
            
            if selectedLogTypeIndexPath == indexPath{
                customCell.didToggleSelect(newSelectionStatus: true)
            }
            else {
                customCell.didToggleSelect(newSelectionStatus: false)
            }
            
            customCell.label.text = KnownLogType.allCases[indexPath.row].rawValue
        }
        else {
            fatalError()
        }
    }
    
    func numberOfRows(forSection: Int, makeDropDownIdentifier: String) -> Int {
        if makeDropDownIdentifier == "dropDownParentDogName"{
            return dogManager.dogs.count
        }
        else if makeDropDownIdentifier == "dropDownLogType"{
            return KnownLogType.allCases.count
        }
        else {
            fatalError()
        }
    }
    
    func numberOfSections(makeDropDownIdentifier: String) -> Int {
        if makeDropDownIdentifier == "dropDownParentDogName"{
            return 1
        }
        else if makeDropDownIdentifier == "dropDownLogType"{
            return 1
        }
        else {
            fatalError()
        }
    }
    
    func selectItemInDropDown(indexPath: IndexPath, makeDropDownIdentifier: String) {
        if makeDropDownIdentifier == "dropDownParentDogName"{
            let selectedCell = dropDownParentDogName.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell
            selectedCell.didToggleSelect(newSelectionStatus: true)
            
            if selectedParentDogIndexPath != indexPath{
                shouldPromptSaveWarning = true
            }
            self.selectedParentDogIndexPath = indexPath
            
            parentDogName.text = dogManager.dogs[indexPath.row].dogTraits.dogName
            self.dropDownParentDogName.hideDropDown()
        }
        else if makeDropDownIdentifier == "dropDownLogType"{
            let selectedCell = dropDownLogType.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell
            selectedCell.didToggleSelect(newSelectionStatus: true)
            
            if selectedLogTypeIndexPath != indexPath{
                shouldPromptSaveWarning = true
            }
            self.selectedLogTypeIndexPath = indexPath
            
            logType.text = KnownLogType.allCases[indexPath.row].rawValue
            self.dropDownLogType.hideDropDown()
        }
        else {
            fatalError()
        }
    }
    
    //MARK: - IB
    
    @IBOutlet private weak var containerForAll: UIView!
    @IBOutlet private weak var pageTitle: UINavigationItem!
    @IBOutlet private weak var trashIcon: UIBarButtonItem!
    
    //@IBOutlet private weak var logDisclaimer: CustomLabel!
    
    @IBOutlet weak var parentDogName: BorderedLabel!
    
    @IBOutlet private weak var logType: BorderedLabel!
    
    @IBOutlet private weak var logNote: UITextField!
    
    @IBOutlet private weak var logDate: UIDatePicker!
    
    @IBOutlet private weak var addLogButton: ScaledButton!
    
    @IBOutlet private weak var addLogButtonBackground: ScaledButton!
    
    @IBOutlet private weak var cancelAddLogButton: ScaledButton!
    
    @IBOutlet private weak var cancelAddLogButtonBackground: ScaledButton!
    
    @IBAction private func willDeleteLog(_ sender: Any) {
        let removeDogConfirmation = GeneralAlertController(title: "Are you sure you want to delete this log?", message: nil, preferredStyle: .alert)
        
        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            self.delegate.didDeleteKnownLog(sender: Sender(origin: self, localized: self), parentDogName: self.parentDogName.text!, requirementUUID: self.updatingKnownLogInformation!.1?.uuid ?? nil, logUUID: self.updatingKnownLogInformation!.2.uuid)
            self.navigationController?.popViewController(animated: true)
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeDogConfirmation.addAction(alertActionRemove)
        removeDogConfirmation.addAction(alertActionCancel)
        
        AlertPresenter.shared.enqueueAlertForPresentation(removeDogConfirmation)
    }
    
    @IBAction private func willAddLog(_ sender: Any) {
        self.dismissKeyboard()
        
        
        //updating log
        if updatingKnownLogInformation != nil{
            let exsistingLog = updatingKnownLogInformation!.2
            let updatedLog = exsistingLog.copy() as! KnownLog
            updatedLog.date = logDate.date
            updatedLog.note = logNote.text ?? ""
            updatedLog.logType = KnownLogType(rawValue: logType.text!)!
            updatedLog.creationDate = Date()
            
            delegate.didUpdateKnownLog(sender: Sender(origin: self, localized: self), parentDogName: parentDogName.text!, requirementUUID: updatingKnownLogInformation?.1?.uuid ?? nil, updatedKnownLog: updatedLog)
            self.navigationController?.popViewController(animated: true)
        }
        //adding log
        else {
            do {
                if logType.text == nil || logType.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                    throw KnownLogTypeError.blankLogType
                }
                else {
                    let newLog = KnownLog(date: logDate.date, note: logNote.text ?? "", logType: KnownLogType(rawValue: logType.text!)!)
                    delegate.didAddKnownLog(sender: Sender(origin: self, localized: self), parentDogName: parentDogName.text!, newKnownLog: newLog)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            catch {
                ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
            }
           
        }
        
        
        
    }
    
    @IBAction private func willCancel(_ sender: Any) {
        
        self.dismissKeyboard()
        
        if shouldPromptSaveWarning == true || initalLogNote != logNote.text{
            let unsavedInformationConfirmation = GeneralAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)
            
            let alertActionExit = UIAlertAction(title: "Yes, I don't want to save changes", style: .default) { (UIAlertAction) in
                self.navigationController?.popViewController(animated: true)
            }
            
            let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            unsavedInformationConfirmation.addAction(alertActionExit)
            unsavedInformationConfirmation.addAction(alertActionCancel)
            
            AlertPresenter.shared.enqueueAlertForPresentation(unsavedInformationConfirmation)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction private func didUpdateDatePicker(_ sender: Any) {
        self.dismissKeyboard()
        shouldPromptSaveWarning = true
    }
    
    
    
    //MARK: - Properties
    
    var dogManager: DogManager! = nil
    
    ///information for updating log, parentDogName, requirement?, knownLog
    var updatingKnownLogInformation: (String, Requirement?, KnownLog)? = nil
    
    var delegate: LogsAddLogViewControllerDelegate! = nil
    
    ///will show warning about information not being saved by hitting cancel button
    private var shouldPromptSaveWarning: Bool = false
    private var initalLogNote: String? = nil
    
    ///drop down for changing the parent dog name
    private let dropDownParentDogName = MakeDropDown()
    
    ///index path of selected parent dog name in drop down
    private var selectedParentDogIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    ///drop down for changing the log type
    private let dropDownLogType = MakeDropDown()
    
    ///index path of selected log type in drop down
    private var selectedLogTypeIndexPath: IndexPath? = nil
    
    ///height of the cells in the drop down table view
    private var dropDownRowHeight: CGFloat = 40
    
    
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard dogManager != nil && dogManager.dogs.count != 0 else {
            if dogManager == nil{
                print("dogManager can't be nil for LogsAddLogViewController")
            }
            else if dogManager.dogs.count == 0{
                print("dogManager has to have a dog for LogsAddLogViewController")
            }
            //self.performSegue(withIdentifier: "unwindToLogsViewController", sender: self)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        view.sendSubviewToBack(containerForAll)
        
        containerForAll.bringSubviewToFront(cancelAddLogButton)
        containerForAll.bringSubviewToFront(addLogButton)
        
        setupToHideKeyboardOnTapOnView()
        
        setupValues()
        
        setUpGestures()
        
        
        logNote.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpDropDowns()
    }
    
    ///Sets up gestureRecognizer for dog selector drop down
    private func setUpGestures(){
        //adding a log
        if updatingKnownLogInformation == nil{
            self.parentDogName.isUserInteractionEnabled = true
            let parentDogNameTapGesture = UITapGestureRecognizer(target: self, action: #selector(parentDogNameTapped))
            parentDogNameTapGesture.delegate = self
            parentDogNameTapGesture.cancelsTouchesInView = false
            self.parentDogName.addGestureRecognizer(parentDogNameTapGesture)
            
            self.logType.isUserInteractionEnabled = true
            let logTypeTapGesture = UITapGestureRecognizer(target: self, action: #selector(logTypeTapped))
            logTypeTapGesture.delegate = self
            logTypeTapGesture.cancelsTouchesInView = false
            self.logType.addGestureRecognizer(logTypeTapGesture)
        }
        //updating a rlog
        else {
            self.parentDogName.isUserInteractionEnabled = false
            self.parentDogName.isEnabled = false
            
            self.logType.isUserInteractionEnabled = true
            let logTypeTapGesture = UITapGestureRecognizer(target: self, action: #selector(logTypeTapped))
            logTypeTapGesture.delegate = self
            logTypeTapGesture.cancelsTouchesInView = false
            self.logType.addGestureRecognizer(logTypeTapGesture)
        }
        
        
        let dropDownHideTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissAll))
        dropDownHideTap.delegate = self
        dropDownHideTap.cancelsTouchesInView = false
        containerForAll.addGestureRecognizer(dropDownHideTap)
    }
    
    @objc private func dismissAll(){
        self.dismissKeyboard()
        self.dropDownParentDogName.hideDropDown()
        self.dropDownLogType.hideDropDown()
    }
    
    
    @objc private func parentDogNameTapped(){
        self.dismissKeyboard()
        self.dropDownLogType.hideDropDown()
        
        var numDogToShow: CGFloat {
            if dogManager.dogs.count > 5 {
                return 5.5
            }
            else {
                return CGFloat(dogManager.dogs.count)
            }
        }
        self.dropDownParentDogName.showDropDown(height: self.dropDownRowHeight * CGFloat(numDogToShow))
    }
    
    @objc private func logTypeTapped(){
        self.dismissKeyboard()
        self.dropDownParentDogName.hideDropDown()
        
        self.dropDownLogType.showDropDown(height: self.dropDownRowHeight * 6.5)
    }
    
    ///Sets up the values of different variables that is found out from information passed
    private func setupValues(){
        //updating log
        if updatingKnownLogInformation != nil{
            pageTitle!.title = "Edit Log"
            trashIcon.isEnabled = true
            
            parentDogName.text = updatingKnownLogInformation!.0
            
            logType.text = updatingKnownLogInformation!.2.logType.rawValue
            logType.isEnabled = true
            
            selectedLogTypeIndexPath = IndexPath(row: KnownLogType.allCases.firstIndex(of: KnownLogType(rawValue: logType.text!)!)!, section: 0)
            
            logDate.date = updatingKnownLogInformation!.2.date
            
            logNote.text = updatingKnownLogInformation!.2.note
            initalLogNote = logNote.text
        }
        //not updating
        else {
            parentDogName.text = dogManager.dogs[0].dogTraits.dogName
            parentDogName.isEnabled = true
            trashIcon.isEnabled = false
            
            logType.text = ""
            logType.isEnabled = true
            
            selectedLogTypeIndexPath = nil
            
            logDate.date = Date.roundDate(targetDate: Date(), roundingInterval: 60.0*5, roundingMethod: .up)
            
            initalLogNote = logNote.text
        }
        
    }
    
    //MARK: - Drop Down Functions
    
    private func setUpDropDowns(){
        dropDownParentDogName.makeDropDownIdentifier = "dropDownParentDogName"
        dropDownParentDogName.cellReusableIdentifier = "dropDownCell"
        dropDownParentDogName.makeDropDownDataSourceProtocol = self
        dropDownParentDogName.setUpDropDown(viewPositionReference: parentDogName.frame, offset: 2.0)
        dropDownParentDogName.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDownParentDogName.setRowHeight(height: self.dropDownRowHeight)
        self.view.addSubview(dropDownParentDogName)
        
        dropDownLogType.makeDropDownIdentifier = "dropDownLogType"
        dropDownLogType.cellReusableIdentifier = "dropDownCell"
        dropDownLogType.makeDropDownDataSourceProtocol = self
        dropDownLogType.setUpDropDown(viewPositionReference: logType.frame, offset: 2.0)
        dropDownLogType.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDownLogType.setRowHeight(height: self.dropDownRowHeight)
        self.view.addSubview(dropDownLogType)
    }
    
}
