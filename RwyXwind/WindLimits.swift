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
        UserDefaults.standard.set(
            self.Defaults.HeadwindDefaultLimit,
            forKey: self.Keys.HeadwindLimit
        )
        
        UserDefaults.standard.set(
            self.Defaults.TailwindDefaultLimit,
            forKey: self.Keys.TailwindLimit
        )
        
        UserDefaults.standard.set(
            self.Defaults.CrosswindDefaultLimit,
            forKey: self.Keys.CrosswindLimit
        )
    }
    
    static func saveWindLimits(_ headwind: Int, tailwind: Int, crosswind: Int) {
        UserDefaults.standard.set(headwind, forKey: self.Keys.HeadwindLimit)
        UserDefaults.standard.set(tailwind, forKey: self.Keys.TailwindLimit)
        UserDefaults.standard.set(crosswind, forKey: self.Keys.CrosswindLimit)
    }
    
    static func getHeadwindLimit() -> Int{
        return UserDefaults.standard.integer(forKey: self.Keys.HeadwindLimit)
    }
    
    static func getTailwindLimit() -> Int {
        return UserDefaults.standard.integer(forKey: self.Keys.TailwindLimit)
    }
    
    static func getCrosswindLimit()-> Int {
        return UserDefaults.standard.integer(forKey: self.Keys.CrosswindLimit)
    }
}
