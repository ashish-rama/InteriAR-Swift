//
//  RootViewController.swift
//  InteriAR
//
//  Created by Ashish Ramachandran on 1/3/18.
//  Copyright © 2018 Ashish Ramachandran. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    // Variables for the main screen navigation controller and view controller
    var rootNavigationController: UINavigationController!
    
    var cameraViewController: CameraViewController!
    var savedLayoutsViewController: SaveTableViewController!
    var menuViewController: MenuViewController!
    
    // Keep track if menu is open
    var menuIsOpen = false
    
    // Keep track which view is already open
    enum MenuType {
        case Camera
        case SavedLayout
    }
    
    var currentMenuType: MenuType = .Camera
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create each view controller for the menu to display
        // Camera View
        cameraViewController = UIStoryboard.cameraViewController()
        cameraViewController.delegate = self
        
        // Saved Layouts
        savedLayoutsViewController = UIStoryboard.saveTableViewController()
        savedLayoutsViewController.delegate = self
        
        // Menu View
        menuViewController = UIStoryboard.menuViewController()
        menuViewController.delegate = self
        view.insertSubview(menuViewController.view, at: 0)
        addChildViewController(menuViewController)
        menuViewController.didMove(toParentViewController: self)
        
        // Create root navigation controller and make child of root view
        rootNavigationController = UINavigationController(rootViewController: cameraViewController)
        view.addSubview(rootNavigationController.view)
        addChildViewController(rootNavigationController)
        rootNavigationController.didMove(toParentViewController: self)
        
        rootNavigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        rootNavigationController?.navigationBar.barTintColor = UIColor(red: 57/255, green: 162/255, blue: 227/255, alpha: 1)
        rootNavigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

// Menu Handling
extension RootViewController: CameraViewControllerDelegate, SaveTableViewControllerDelegate {
    
    func toggleMenu() {
        // Move the root navigation controller
        if !menuIsOpen {
            UIView.animate(withDuration: 0.2, delay: 0,
                animations: {
                    self.rootNavigationController.view.frame.origin.x = (self.rootNavigationController.view.frame.width - self.rootNavigationController.view.frame.width * 0.3)
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.2, delay: 0,
                           animations: {
                            self.rootNavigationController.view.frame.origin.x = 0
            }, completion: nil)
        }
        
        // Toggle option
        menuIsOpen = !menuIsOpen
        
    }
    
}

extension RootViewController: MenuViewControllerDelegate {
    
    func switchViews(menuType: RootViewController.MenuType) {
        // Toggle the menu before switching the views
        self.toggleMenu()
        
        // Pop and push new view controllers to root navigation controller
        if(menuType != currentMenuType) {
            if(menuType == .Camera) {
                rootNavigationController.topViewController?.removeFromParentViewController()
                rootNavigationController.pushViewController(cameraViewController, animated: false)
            } else if(menuType == .SavedLayout) {
                rootNavigationController.topViewController?.removeFromParentViewController()
                rootNavigationController.pushViewController(savedLayoutsViewController, animated: false)
            }
            currentMenuType = menuType
        }
        
    }
    
    
}


// MARK - UIStoryboard extension

private extension UIStoryboard {
    
    static func mainStoryBoard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    // For the menu view controller
    static func menuViewController() -> MenuViewController? {
        return mainStoryBoard().instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
    }
    
    // For each view controller showed by the menu
    // Camera View
    static func cameraViewController() -> CameraViewController? {
        return mainStoryBoard().instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController
    }
    
    // Saved Layouts
    static func saveTableViewController() -> SaveTableViewController? {
        return mainStoryBoard().instantiateViewController(withIdentifier: "SaveTableViewController") as? SaveTableViewController
    }
    
}
