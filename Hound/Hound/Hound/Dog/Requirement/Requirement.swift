//
//  Requirementt.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

///Enum full of cases of possible errors from Requirement
enum RequirementError: Error {
    case nameBlank
    case nameInvalid
    case descriptionInvalid
    case intervalInvalid
}

enum RequirementStyle: String {
    case oneTime = "oneTime"
    case countDown = "countDown"
    case weekly = "weekly"
    case monthly = "monthly"
}

enum RequirementMode {
    case oneTime
    case countDown
    case weekly
    case monthly
    case snooze
}

protocol RequirementTraitsProtocol {
    
    ///Dog that hold this requirement, used for logs
    var masterDog: Dog? { get set }
    
    var uuid: String { get set }
    
    ///Replacement for requirementName, a way for the user to keep track of what the requirement is for
    var requirementType: ScheduledLogType { get set }
    
    ///If the requirement's type is custom, this is the name for it
    var customTypeName: String? { get set }
    
    ///If not .custom type then just .type name, if custom and has customTypeName then its that string
    var displayTypeName: String { get }
    
    ///An array of all dates that logs when the timer has fired, whether by snooze, regular timing convention, etc. ANY TIME
    //var logs: [KnownLog] { get set }
}

protocol RequirementComponentsProtocol {
    ///The components needed for a countdown based timer
    var countDownComponents: CountDownComponents { get set }
    
    ///The components needed if an timer is snoozed
    var snoozeComponents: SnoozeComponents { get set }
    
    ///The components needed if for time of day based timer
    var timeOfDayComponents: TimeOfDayComponents { get set }
    
    ///Figures out whether the requirement is in snooze, count down, time of day, or another timer mode. Returns enum case corrosponding
    var timerMode: RequirementMode { get }
    
    ///An enum that indicates whether the requirement is in countdown format or time of day format
    var timingStyle: RequirementStyle { get }
    ///Function to change timing style and adjust data corrosponding accordingly.
    mutating func changeTimingStyle(newTimingStyle: RequirementStyle)
}

protocol RequirementTimingComponentsProtocol {
    ///Similar to executionDate but instead of being a log of everytime the time has fired it is either the date the timer has last fired or the date it should be basing its execution off of, e.g. 5 minutes into the timer you change the countdown from 30 minutes to 15, you don't want to log an execution as there was no one but you want to start the timer fresh and have it count down from the moment it was changed.
    var executionBasis: Date { get }
    
    ///Changes executionBasis to the specified value, note if the Date is equal to the current date (i.e. newExecutionBasis == Date()) then resets all components intervals elapsed to zero.
    mutating func changeExecutionBasis(newExecutionBasis: Date, shouldResetIntervalsElapsed: Bool)
    
    ///If an timer is dismissed when it fires and alerts the user, the requirement will remain inactive until interacted with again. Similar to being disabled except it will sit on the home screen just doing nothing
    var isActive: Bool { get }
    
    ///Changes the active status and accompanying information
    mutating func changeActiveStatus(newActiveStatus: Bool)
    
    ///True if the presentation of the timer (when it is time to present) has been handled and sent to the presentation handler, prevents repeats of the timer being sent to the presenation handler over and over.
    var isPresentationHandled: Bool { get set }
    
    ///The date at which the requirement should fire, i.e. go off to the user and display an alert
    var executionDate: Date? { get }
    
    ///Calculated time interval remaining that taking into account factors to produce correct value for conditions and parameters
    var intervalRemaining: TimeInterval? { get }
    
    ///Called when a timer is fired/executed and an option to deal with it is selected by the user, if the reset is trigger by a user doing an action that constitude a reset, specify as so, but if doing something like changing the value of some component it was did not exeute to user. If didExecuteToUse is true it does the same thing as false except it appends the current date to the array of logs which keeps tracks of each time a requirement is formally executed.
    mutating func timerReset(shouldLogExecution: Bool, knownLogType: KnownLogType?, customTypeName: String?)
}

class Requirement: NSObject, NSCoding, NSCopying, RequirementTraitsProtocol, RequirementComponentsProtocol, RequirementTimingComponentsProtocol, EnableProtocol {
    
    //MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Requirement()
        
        copy.uuid = self.uuid
        copy.requirementType = self.requirementType
        copy.customTypeName = self.customTypeName
        //copy.logs = self.logs
        
        copy.countDownComponents = self.countDownComponents.copy() as! CountDownComponents
        copy.timeOfDayComponents = self.timeOfDayComponents.copy() as! TimeOfDayComponents
        copy.timeOfDayComponents.masterRequirement = copy
        copy.oneTimeComponents = self.oneTimeComponents.copy() as! OneTimeComponents
        copy.oneTimeComponents.masterRequirement = copy
        copy.snoozeComponents = self.snoozeComponents.copy() as! SnoozeComponents
        copy.storedTimingStyle = self.timingStyle
        
        copy.storedIsActive = self.isActive
        copy.isPresentationHandled = self.isPresentationHandled
        copy.storedExecutionBasis = self.executionBasis
        
        copy.isEnabled = self.isEnabled
        
        return copy
    }
    
    //MARK: - NSCoding
    
    override init() {
        super.init()
        self.timeOfDayComponents.masterRequirement = self
        self.oneTimeComponents.masterRequirement = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        self.uuid = aDecoder.decodeObject(forKey: "uuid") as! String
        self.requirementType = ScheduledLogType(rawValue: aDecoder.decodeObject(forKey: "requirementType") as! String)!
        self.customTypeName = aDecoder.decodeObject(forKey: "customTypeName") as? String
        
        
        if UIApplication.previousAppBuild <= 1228{
            print("grandfather in depreciated requirements logs")
            let depreciatedLogs: [KnownLog] = aDecoder.decodeObject(forKey: "logs") as? [KnownLog] ?? []
            
        
            if depreciatedLogs.count > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.masterDog == nil {
                        print("master dog nil")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                            if self.masterDog != nil {
                                print("backup requirement logs decode success")
                                for log in depreciatedLogs{
                                    self.masterDog?.dogTraits.logs.append(log)
                                }
                            }
                            else {
                                print("backup requirement logs decode fail")
                            }
                        }
                    }
                    else {
                        print("primary requirement logs decode success")
                        for log in depreciatedLogs{
                            self.masterDog?.dogTraits.logs.append(log)
                        }
                    }
                }
            }
           
        }
        else {
            //print("too new")
            //print(UIApplication.previousAppBuild)
        }
        
        
        self.countDownComponents = aDecoder.decodeObject(forKey: "countDownComponents") as! CountDownComponents
        self.timeOfDayComponents = aDecoder.decodeObject(forKey: "timeOfDayComponents") as! TimeOfDayComponents
        self.timeOfDayComponents.masterRequirement = self
        self.oneTimeComponents = aDecoder.decodeObject(forKey: "oneTimeComponents") as? OneTimeComponents ?? OneTimeComponents()
        self.oneTimeComponents.masterRequirement = self
        self.snoozeComponents = aDecoder.decodeObject(forKey: "snoozeComponents") as! SnoozeComponents
        self.storedTimingStyle = RequirementStyle(rawValue: aDecoder.decodeObject(forKey: "timingStyle") as! String)!
        
        self.storedIsActive = aDecoder.decodeBool(forKey: "isActive")
        self.isPresentationHandled = aDecoder.decodeBool(forKey: "isPresentationHandled")
        self.storedExecutionBasis = aDecoder.decodeObject(forKey: "executionBasis") as! Date
        
        self.isEnabled = aDecoder.decodeBool(forKey: "isEnabled")
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(uuid, forKey: "uuid")
        aCoder.encode(requirementType.rawValue, forKey: "requirementType")
        aCoder.encode(customTypeName, forKey: "customTypeName")
        //aCoder.encode(logs, forKey: "logs")
        
        aCoder.encode(countDownComponents, forKey: "countDownComponents")
        aCoder.encode(timeOfDayComponents, forKey: "timeOfDayComponents")
        aCoder.encode(oneTimeComponents, forKey: "oneTimeComponents")
        aCoder.encode(snoozeComponents, forKey: "snoozeComponents")
        aCoder.encode(storedTimingStyle.rawValue, forKey: "timingStyle")
        
        aCoder.encode(storedIsActive, forKey: "isActive")
        aCoder.encode(isPresentationHandled, forKey: "isPresentationHandled")
        aCoder.encode(storedExecutionBasis, forKey: "executionBasis")
        
        aCoder.encode(isEnabled, forKey: "isEnabled")
    }
    
    //MARK: - RequirementTraitsProtocol
    
    var masterDog: Dog? = nil
    
    var uuid: String = UUID().uuidString
    
    var requirementType: ScheduledLogType = RequirementConstant.defaultType
    
    var customTypeName: String? = nil
    
    var displayTypeName: String {
        if requirementType == .custom && customTypeName != nil {
            return customTypeName!
        }
        else {
            return requirementType.rawValue
        }
    }
    
    //var logs: [KnownLog] = []
    
    //MARK: - RequirementComponentsProtocol
    
    var countDownComponents: CountDownComponents = CountDownComponents()
    
    var timeOfDayComponents: TimeOfDayComponents = TimeOfDayComponents()
    
    var oneTimeComponents: OneTimeComponents = OneTimeComponents()
    
    var snoozeComponents: SnoozeComponents = SnoozeComponents()
    
    var timerMode: RequirementMode {
        if snoozeComponents.isSnoozed == true{
            return .snooze
        }
        else if timingStyle == .countDown {
            return .countDown
        }
        else if timingStyle == .weekly {
            return .weekly
        }
        else if timingStyle == .monthly {
            return .monthly
        }
        else if timingStyle == .oneTime{
            return .oneTime
        }
        else {
            fatalError()
        }
    }
    
    private var storedTimingStyle: RequirementStyle = .countDown
    var timingStyle: RequirementStyle { return storedTimingStyle }
    func changeTimingStyle(newTimingStyle: RequirementStyle){
        guard newTimingStyle != storedTimingStyle else {
            return
        }
        
        self.timerReset(shouldLogExecution: false)
        
        storedTimingStyle = newTimingStyle
    }
    
    //MARK: - RequirementTimingComponentsProtocol
    
    private var storedExecutionBasis: Date = Date()
    var executionBasis: Date { return storedExecutionBasis }
    func changeExecutionBasis(newExecutionBasis: Date, shouldResetIntervalsElapsed: Bool){
        storedExecutionBasis = newExecutionBasis
        
        //If resetting the executionBasis to the current time (and not changing it to another executionBasis of some other requirement) then resets interval elasped as timers would have to be fresh
        if shouldResetIntervalsElapsed == true {
            snoozeComponents.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
            countDownComponents.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
        }
        
    }
    
    private var storedIsActive: Bool = true
    var isActive: Bool { return storedIsActive }
    
    func changeActiveStatus(newActiveStatus: Bool){
        //newActiveStatus different from the one stored
        if newActiveStatus != storedIsActive{
            //transitioning to active
            if newActiveStatus == true{
                self.timerReset(shouldLogExecution: false)
            }
            //transitioning to inactive
            else {
                isPresentationHandled = false
                storedIsActive = false
            }
        }
    }
    
    var isPresentationHandled: Bool = false
    
    var intervalRemaining: TimeInterval? {
        //snooze
        if timerMode == .snooze {
            return snoozeComponents.executionInterval - snoozeComponents.intervalElapsed
        }
        else if timerMode == .oneTime {
            return Date().distance(to: oneTimeComponents.executionDate!)
        }
        //countdown
        else if timerMode == .countDown{
            return countDownComponents.executionInterval - countDownComponents.intervalElapsed
        }
        else if timerMode == .weekly || timerMode == .monthly {
            //if the previousTimeOfDay is closer to the present than executionBasis returns nil, indicates missed alarm
            if self.executionBasis.distance(to: self.timeOfDayComponents.previousTimeOfDay(requirementExecutionBasis: self.executionBasis)) > 0 {
                return nil
            }
            else{
                return Date().distance(to: self.timeOfDayComponents.nextTimeOfDay(requirementExecutionBasis: self.executionBasis))
            }
        }
        else {
            //HDLL
            fatalError("not implemented timerMode for intervalRemaining, Requirement")
            //return -1
        }
    }
    
    var executionDate: Date? {
        guard self.getEnable() == true else {
            return nil
        }
        
        //Snoozing
        if self.timerMode == .snooze{
            return Date.executionDate(lastExecution: executionBasis, interval: intervalRemaining!)
        }
        //Time of Day Alarm
        else if timerMode == .weekly || timerMode == .monthly {
            //If the intervalRemaining is nil than means there is no time left
            if intervalRemaining == nil {
                return Date()
            }
            else {
                return timeOfDayComponents.nextTimeOfDay(requirementExecutionBasis: self.executionBasis)
            }
        }
        else if timerMode == .countDown{
            return Date.executionDate(lastExecution: executionBasis, interval: intervalRemaining!)
        }
        else if timerMode == .oneTime{
            return oneTimeComponents.executionDate
        }
        else {
            fatalError("not implemented timerMode for executionDate, requirement")
        }
    }
    
    func timerReset(shouldLogExecution: Bool, knownLogType: KnownLogType? = nil, customTypeName: String? = nil){
        
        //changeActiveStatus already calls timerReset if transitioning from inactive to active so circumvent this by directly accessing storedIsActive
        if isActive == false {
            storedIsActive = true
        }
        
        if shouldLogExecution == true {
            if knownLogType == nil {
                fatalError()
            }
            masterDog?.dogTraits.logs.append(KnownLog(date: Date(), logType: knownLogType!, customTypeName: customTypeName))
            
            if masterDog == nil {
                print("masterDog nil, couldn't log")
            }
        }
        
        self.changeExecutionBasis(newExecutionBasis: Date(), shouldResetIntervalsElapsed: true)
        
        self.isPresentationHandled = false
        
        snoozeComponents.timerReset()
        
        if timingStyle == .countDown {
            self.countDownComponents.timerReset()
        }
        else if timingStyle == .weekly || timingStyle == .monthly{
            self.timeOfDayComponents.timerReset()
        }
        else {
            self.oneTimeComponents.timerReset()
        }
        
    }
    
    //MARK: - EnableProtocol
    
    ///Whether or not the requirement  is enabled, if disabled all requirements will not fire, if parentDog isEnabled == false will not fire
    private var isEnabled: Bool = DogConstant.defaultEnable
    
    ///Changes isEnabled to newEnableStatus, note if toggling from false to true the execution basis is changed to the current Date()
    func setEnable(newEnableStatus: Bool) {
        if isEnabled == false && newEnableStatus == true {
            timerReset(shouldLogExecution: false)
        }
        isEnabled = newEnableStatus
    }
    
    func willToggle() {
        isEnabled.toggle()
    }
    
    func getEnable() -> Bool{
        return isEnabled
    }
    
}



