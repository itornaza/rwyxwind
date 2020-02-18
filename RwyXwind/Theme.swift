//
//  Theme.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 11/10/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit

/**
 * Provides the baseline to support multiple themes in later versions.
 * However, much of the appearance is still defined in storyboard
 */
struct Theme {
    
    // MARK: - Shared Instance
    
    static func sharedInstance() -> Theme {
        struct Singleton {
            static var sharedInstance = Theme()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: - Color Scheme
    
    let darkGray = UIColor(red: 54.0/255.0, green: 54.0/255.0, blue: 54.0/255.0, alpha: 1.0)
    let lightGray = UIColor(red: 126.0/255.0, green: 126.0/255.0, blue: 126.0/255.0, alpha: 1.0)
    let red = UIColor(red: 222.0/255.0, green: 88.0/255.0, blue: 16.0/255.0, alpha: 1.0)
    let yellow = UIColor(red: 242.0/255.0, green: 203.0/255.0, blue: 108.0/255.0, alpha: 1.0)
    let white = UIColor.white
    let green = UIColor.green
    let black = UIColor.black
}
