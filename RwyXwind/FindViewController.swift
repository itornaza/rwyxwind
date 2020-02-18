//
//  FindViewController.swift
//  RwyXwind
//
//  Created by Ioannis Tornazakis on 21/9/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import UIKit
import Darwin
import CoreData

class FindViewController:   UIViewController, UITabBarControllerDelegate {

    // MARK: - Properties
    
    var runway: Runway?
    var weather: Weather?
    var tapRecognizer: UITapGestureRecognizer? = nil
    var pickerData: [[String]] = [[String]]()
    let numberOfRotors: Int = 3
    var heading = Double(360.0)
    
    enum ValidationError: Error {
        case invalidRunwayHeading
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var letterCode: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var calculate: UIButton!
    @IBOutlet weak var iataCodeLabel: UILabel!
    @IBOutlet weak var threeLetters: UILabel!
    @IBOutlet weak var runwayHeadingLabel: UILabel!
    @IBOutlet weak var calculateButtonTouch: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        self.letterCode.delegate = self
        self.picker.delegate = self
        self.picker.dataSource = self
        self.setPickerData()
        self.setTapRecognizer()
        self.initializeWindLimits()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureUI()
    }
    
    // MARK: - Actions
    
    @IBAction func calculateXwind(_ sender: AnyObject) {
        if (self.letterCode.text! == "") {
            // The user has not entered any digit and hit calculate
            alertView("Invalid input", message: "Please, input IATA or ICAO code to continue")
        } else {
            var letterCode: String?
            let codeCategory = self.getCodeCategory(code: self.letterCode.text!)
            if codeCategory == nil {
                // The user entered only 1 or 2 digits
                self.alertView("Airport service error", message: "Input 3 letters for IATA or \n4 letters for ICAO")
            } else {
                letterCode = self.letterCode.text!
                self.startSpinner()
                
                // Get the runway and weather from the letter code (either iata or icao)
                AirportDataClient.sharedInstance().getAirportByCode(letterCode: letterCode!) { runway, error in
                    if error != nil {
                        self.alertView("Airport service error", message: error!)
                    } else {
                        self.runway = runway!
                        self.runway?.hdg = self.heading
                        WeatherClient.sharedInstance().getWeatherByCoordinates(runway!.lat, long: runway!.long) {
                            weather, error in
                              if error != nil {
                                  self.alertView("Weather service error", message: error!)
                              } else {
                                  self.weather = weather!
                                  self.segueToWindViewController()
                              }
                        }
                    }
                    self.stopSpinner()
                }
            }
        }
    }
    
    // MARK: - Tap recognizer callback
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Helpers
    
    func setPickerData() {
        self.pickerData = [
            ["0", "1", "2", "3"],
            ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"],
            ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        ]
    }
    
    func initializeWindLimits() {
        if UserDefaults.standard.object(forKey: WindLimits.Keys.HeadwindLimit) == nil {
            WindLimits.setUserDefaultLimits()
        }
    }
    
    func setTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(FindViewController.handleSingleTap(_:)))
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    /// Valid numbers are: 000 - 360
    func validateRunwayHeading(_ runwayHeading: Int) throws {
        if !(runwayHeading <= 360 && runwayHeading >= 0) {
            throw ValidationError.invalidRunwayHeading
        }
    }
    
    func startSpinner() {
        OperationQueue.main.addOperation {
            self.spinner.isHidden = false
            self.spinner.startAnimating()
        }
    }
    
    func stopSpinner() {
        OperationQueue.main.addOperation {
            self.spinner.isHidden = true
            self.spinner.stopAnimating()
        }
    }
    
    func configureUI() {
        self.stopSpinner()
        self.configureIataCode()
        self.configureLabels()
        self.configurePicker()
        self.configureTabBar()
    }
    
    func configureTabBar() {
        UITabBar.appearance().barTintColor = Theme.sharedInstance().darkGray
    }
    
    func configureLabels() {
        self.iataCodeLabel.textColor = Theme.sharedInstance().yellow
        self.threeLetters.textColor = Theme.sharedInstance().yellow
        self.runwayHeadingLabel.textColor = Theme.sharedInstance().yellow
    }
    
    func configureIataCode() {
        self.letterCode.isAccessibilityElement = true
        self.letterCode.textColor = Theme.sharedInstance().green
        self.letterCode.backgroundColor = Theme.sharedInstance().darkGray
    }
    
    func configurePicker() {
        self.picker.backgroundColor = Theme.sharedInstance().darkGray
        
        // Border
        self.picker.layer.borderColor = UIColor.gray.cgColor
        self.picker.layer.borderWidth = 0.5
        self.picker.layer.cornerRadius = 15
    }
    
    func configureCalculate() {
        self.calculate.backgroundColor = Theme.sharedInstance().darkGray
        
        // Border
        self.calculate.layer.borderColor = UIColor.black.cgColor
        self.calculate.layer.borderWidth = 0.5
        self.calculate.layer.cornerRadius = 5
        
        // Shadow
        self.calculate.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.calculate.layer.shadowRadius = 5
        self.calculate.layer.shadowColor = UIColor.black.cgColor
        self.calculate.layer.shadowOpacity = 1.0
    }
    
    func getCodeCategory(code: String) -> Int? {
        if code.count == 3 {
            return AirportDataClient.Constants.IsIata
        } else if code.count == 4 {
            return AirportDataClient.Constants.IsIcao
        } else {
            return nil
        }
    }
    
    // MARK: - Alerts and segues
    
    /// Throws an alert view to display error messages
    func alertView(_ title: String, message: String) {
        OperationQueue.main.addOperation {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(dismiss)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// Modal segue to the wind view controller using the main thread
    func segueToWindViewController() {
        OperationQueue.main.addOperation {
            let windVC = self.storyboard!.instantiateViewController(withIdentifier: "WindViewController") as!
            WindViewController
            windVC.runway = self.runway
            windVC.weather = self.weather
            self.startSpinner()
            self.present(windVC, animated: false, completion: nil)
        }
    }
}

extension FindViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    /// Font color
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) ->
        NSAttributedString? {
        let titleData = pickerData[component][row]
        let myTitle = NSAttributedString(
            string: titleData,
            attributes: convertToOptionalNSAttributedStringKeyDictionary([
                convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): Theme.sharedInstance().green
            ])
        )
        return myTitle
    }
    
    /// The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.numberOfRotors
    }
    
    
    /// The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    /// The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }
    
    /// didSelectRow
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let rotor1 = Int(pickerData[0][picker.selectedRow(inComponent: 0)])
        let rotor2 = Int(pickerData[1][picker.selectedRow(inComponent: 1)])
        let rotor3 = Int(pickerData[2][picker.selectedRow(inComponent: 2)])
        var runwayHeading = (rotor1! * 100) + (rotor2! * 10) + rotor3!
        do {
            try self.validateRunwayHeading(runwayHeading)
            
            // Both runway headings 0 and 360 are the same and correspond to runway36!
            if runwayHeading == 0 {
                runwayHeading = 360
            }
            self.heading = Double(runwayHeading)
        } catch {
            self.alertView("Invalid input", message: "Runway heading shall be from 000 to 360 degrees")
            
            // Reset the picker to a valid heading keeping the first digit
            self.picker.selectRow(0, inComponent: 1, animated: true)
            self.picker.selectRow(0, inComponent: 2, animated: true)
        }
    }
}

extension FindViewController: UITextFieldDelegate {
    
    /// Validate the iataCode text field to allow only up to letters
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String)
        -> Bool {
        var lettersOnly: Bool = false
        var properLength: Bool = false
        let maxLength: Int = 4  // To handle both IATA and ICAO codes
        
        // Create an `NSCharacterSet` set which includes everything *but* the letters
        let set = CharacterSet(charactersIn:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz").inverted
        
        // At every character in this "inverseSet" contained in the string,
        // split the string up into components which exclude the characters
        // in this inverse set
        let components = string.components(separatedBy: set)
        
        // Rejoin these components
        let filtered = components.joined(separator: "")
        
        // If the original string is equal to the filtered string, i.e. if no
        // inverse characters were present to be eliminated, the input is valid
        // and the statement returns true; else it returns false
        lettersOnly = string == filtered ? true : false
        
        // Limit input to 3 characters
        if range.length + range.location > (self.letterCode.text?.count)! {
            return false
        }
        
        let newLength = (self.letterCode.text?.count)! + string.count - range.length
        properLength = newLength <= maxLength ? true : false
        
        // If only both conditions are met return true
        return lettersOnly && properLength
    }
    
    /// Hide the keyboard after editing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) ->
    [NSAttributedString.Key: Any]? {
	
    guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
