//
//  PreferencesViewController.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 11/10/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import UIKit

class PreferencesViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var headwindLimit: UILabel!
    @IBOutlet weak var tailwindLimit: UILabel!
    @IBOutlet weak var crosswindLimit: UILabel!
    @IBOutlet weak var aircraftLabel: UILabel!
    @IBOutlet weak var headwindLabel: UILabel!
    @IBOutlet weak var tailwindLabel: UILabel!
    @IBOutlet weak var crosswindLabel: UILabel!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var headwindSlider: UISlider!
    @IBOutlet weak var tailwindSlider: UISlider!
    @IBOutlet weak var crosswindSlider: UISlider!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureUI()
        self.initializeSlidersValues()
        self.initializeLabelsValues()
    }
    
    // MARK: - Actions
    
    @IBAction func changedHeadwindLimit(_ sender: UISlider) {
        self.headwindLimit.text = "\(Int(sender.value))"
        self.saveLimits()
    }
    
    @IBAction func changedTailwindLimit(_ sender: UISlider) {
        self.tailwindLimit.text = "\(Int(sender.value))"
        self.saveLimits()
    }
    
    @IBAction func changedCrosswindLimit(_ sender: UISlider) {
        self.crosswindLimit.text = "\(Int(sender.value))"
        self.saveLimits()
    }
    
    // MARK: - Methods
    
    func saveLimits() {
        WindLimits.saveWindLimits(
            Int(headwindLimit.text!)!,
            tailwind: Int(tailwindLimit.text!)!,
            crosswind: Int(crosswindLimit.text!)!
        )
    }
    
    func initializeLabelsValues() {
        self.headwindLimit.text = String(WindLimits.getHeadwindLimit())
        self.tailwindLimit.text = String(WindLimits.getTailwindLimit())
        self.crosswindLimit.text = String(WindLimits.getCrosswindLimit())
    }
    
    func initializeSlidersValues() {
        self.headwindSlider.value = Float(WindLimits.getHeadwindLimit())
        self.tailwindSlider.value = Float(WindLimits.getTailwindLimit())
        self.crosswindSlider.value = Float(WindLimits.getCrosswindLimit())
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.setViewBorder()
        self.setFontColors()
        self.setSliderThumbImages()
    }
    
    func setSliderThumbImages() {
        self.headwindSlider.setThumbImage(UIImage(named: "SliderThumb"), for: UIControlState())
        self.tailwindSlider.setThumbImage(UIImage(named: "SliderThumb"), for: UIControlState())
        self.crosswindSlider.setThumbImage(UIImage(named: "SliderThumb"), for: UIControlState())
    }
    
    func setViewBorder() {
        self.placeholderView.layer.borderColor = UIColor.gray.cgColor
        self.placeholderView.layer.borderWidth = 0.5
        self.placeholderView.layer.cornerRadius = 15
    }
    
    func setFontColors() {
        self.aircraftLabel.textColor = Theme.sharedInstance().white
        self.headwindLimit.textColor = Theme.sharedInstance().green
        self.tailwindLimit.textColor = Theme.sharedInstance().green
        self.crosswindLimit.textColor = Theme.sharedInstance().green
    }

}
