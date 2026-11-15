//
//  WindViewConrollerAnimations.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 19/2/17.
//  Copyright © 2017 polarbear.gr. All rights reserved.
//

import UIKit

extension WindViewController {
    
    func animateHeadwind() {
        // Animate Arrow
        self.headwindArrow.center.y -= view.bounds.height
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.headwindArrow.center.y += self.view.bounds.height
            self.view.layoutIfNeeded()
            self.headwindArrow.alpha = 1.0
        }, completion: nil)
        
        self.headwindArrowAlert.center.y -= view.bounds.height
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.headwindArrowAlert.center.y += self.view.bounds.height
            self.view.layoutIfNeeded()
            self.headwindArrowAlert.alpha = 1.0
        }, completion: nil)
        
        // Animate Label
        self.headwind.center.y -= view.bounds.height
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.headwind.center.y += self.view.bounds.height
            self.view.layoutIfNeeded()
            self.headwind.alpha = 1.0
        }, completion: nil)
    }
    
    func animateTailWind() {
        // Animate Arrow
        self.tailwindArrow.center.y += view.bounds.height
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.tailwindArrow.center.y -= self.view.bounds.height
            self.view.layoutIfNeeded()
            self.tailwindArrow.alpha = 1.0
        }, completion: nil)
        
        self.tailwindArrowAlert.center.y += view.bounds.height
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.tailwindArrowAlert.center.y -= self.view.bounds.height
            self.view.layoutIfNeeded()
            self.tailwindArrowAlert.alpha = 1.0
        }, completion: nil)
        
        // Animate Label
        self.tailwind.center.y += view.bounds.height
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.tailwind.center.y -= self.view.bounds.height
            self.view.layoutIfNeeded()
            self.tailwind.alpha = 1.0
        }, completion: nil)
    }
    
    func animateRhCrosswind() {
        // Animate Arrow
        self.rhCrosswindArrow.center.x += view.bounds.width
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseOut], animations: {
            self.rhCrosswindArrow.center.x -= self.view.bounds.width
            self.view.layoutIfNeeded()
            self.rhCrosswindArrow.alpha = 1.0
        }, completion: nil)
        
        self.rhCrosswindArrowAlert.center.x += view.bounds.width
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseOut], animations: {
            self.rhCrosswindArrowAlert.center.x -= self.view.bounds.width
            self.view.layoutIfNeeded()
            self.rhCrosswindArrowAlert.alpha = 1.0
        }, completion: nil)
        
        // Animate Label
        self.rhCrosswind.center.x += view.bounds.width
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseOut], animations: {
            self.rhCrosswind.center.x -= self.view.bounds.width
            self.view.layoutIfNeeded()
            self.rhCrosswind.alpha = 1.0
        }, completion: nil)
    }
    
    func animateLhCrosswind() {
        // Animate Arrow
        self.lhCrosswindArrow.center.x -= view.bounds.width
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseOut], animations: {
            self.lhCrosswindArrow.center.x += self.view.bounds.width
            self.view.layoutIfNeeded()
            self.lhCrosswindArrow.alpha = 1.0
        }, completion: nil)
        
        self.lhCrosswindArrowAlert.center.x -= view.bounds.width
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseOut], animations: {
            self.lhCrosswindArrowAlert.center.x += self.view.bounds.width
            self.view.layoutIfNeeded()
            self.lhCrosswindArrowAlert.alpha = 1.0
        }, completion: nil)
        
        // Animate Label
        self.lhCrosswind.center.x -= view.bounds.width
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseOut], animations: {
            self.lhCrosswind.center.x += self.view.bounds.width
            self.view.layoutIfNeeded()
            self.lhCrosswind.alpha = 1.0
        }, completion: nil)
    }
}
