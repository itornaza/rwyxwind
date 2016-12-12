//
//  WindLimits.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 11/10/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import Foundation

/**
    Packs functionality for the wind limits and integrates
    with the NSUserDefaults
*/
struct WindLimits {
    
    // MARK: - Properties
    
    struct Keys {
        static let HeadwindLimit = "headwind_limit"
        static let TailwindLimit = "tailwind_limit"
        static let CrosswindLimit = "crosswind_limit"
    }
    
    struct Defaults {
        static let HeadwindDefaultLimit: Int = 35
        static let TailwindDefaultLimit: Int = 8
        static let CrosswindDefaultLimit: Int = 20
    }
    
    // Type methods
    
    static func setUserDefaultLimits() {
        NSUserDefaults.standardUserDefaults().setInteger(
            self.Defaults.HeadwindDefaultLimit,
            forKey: self.Keys.HeadwindLimit
        )
        
        NSUserDefaults.standardUserDefaults().setInteger(
            self.Defaults.TailwindDefaultLimit,
            forKey: self.Keys.TailwindLimit
        )
        
        NSUserDefaults.standardUserDefaults().setInteger(
            self.Defaults.CrosswindDefaultLimit,
            forKey: self.Keys.CrosswindLimit
        )
    }
    
    static func saveWindLimits(headwind: Int, tailwind: Int, crosswind: Int) {
        NSUserDefaults.standardUserDefaults().setInteger(headwind, forKey: self.Keys.HeadwindLimit)
        NSUserDefaults.standardUserDefaults().setInteger(tailwind, forKey: self.Keys.TailwindLimit)
        NSUserDefaults.standardUserDefaults().setInteger(crosswind, forKey: self.Keys.CrosswindLimit)
    }
    
    static func getHeadwindLimit() -> Int{
        return NSUserDefaults.standardUserDefaults().integerForKey(self.Keys.HeadwindLimit)
    }
    
    static func getTailwindLimit() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey(self.Keys.TailwindLimit)
    }
    
    static func getCrosswindLimit()-> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey(self.Keys.CrosswindLimit)
    }
}
