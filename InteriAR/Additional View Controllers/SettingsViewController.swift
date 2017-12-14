//
//  SettingsViewController.swift
//  InteriAR
//
//  Created by Ashish Ramachandran on 12/6/17.
//  Copyright © 2017 Ashish Ramachandran. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var debugModeSwitch: UISwitch!
    @IBOutlet weak var scaleWithPinchGestureSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateSettings()
    }
    
    private func populateSettings() {
        let defaults = UserDefaults.standard
        
        debugModeSwitch.isOn = defaults.bool(for: Setting.debugMode)
        scaleWithPinchGestureSwitch.isOn = defaults.bool(for: Setting.scaleWithPinchGesture)
    }
    
    @IBAction func didChangeSettings(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        switch sender {
        case debugModeSwitch:
            defaults.set(sender.isOn, for: .debugMode)
        case scaleWithPinchGestureSwitch:
            defaults.set(sender.isOn, for: .scaleWithPinchGesture)
        default:
            break
        }
    }
    
    
}



enum Setting: String {
    case debugMode
    case scaleWithPinchGesture
}

extension UserDefaults {
    func bool(for setting: Setting) -> Bool {
        return bool(forKey: setting.rawValue)
    }
    
    func set(_ bool: Bool, for setting: Setting) {
        set(bool, forKey: setting.rawValue)
    }
    
    func integer(for setting: Setting) -> Int {
        return integer(forKey: setting.rawValue)
    }
    
    func set(_ integer: Int, for setting: Setting) {
        set(integer, forKey: setting.rawValue)
    }
}


