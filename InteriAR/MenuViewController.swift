//
//  MenuViewController.swift
//  InteriAR
//
//  Created by Ashish Ramachandran on 1/3/18.
//  Copyright © 2018 Ashish Ramachandran. All rights reserved.
//

import UIKit

class MenuItemCell: UITableViewCell {
    @IBOutlet weak var menuItemLabel: UILabel!
    @IBOutlet weak var menuItemIcon: UIImageView!
    static let id = "MenuItemCell"
}

protocol MenuViewControllerDelegate: class {
    func switchViews(menuType: RootViewController.MenuType)
}

class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Delegate to the root view controller
    var delegate: MenuViewControllerDelegate?
    
    // menu items to be displayed
    var menuItemsArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Menu items
        menuItemsArray = ["Camera", "Saved Layouts"]
        
        // Create an empty footers
        tableView.tableFooterView = UIView(frame: .zero)
        
        //tableView.reloadData()
        
        //tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
        tableView.separatorInset = UIEdgeInsetsMake(0, 60, 0, 0);
        
    }
    
}

// MARK: Table View Delegate
extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.switchViews(menuType: indexPath.row == 0 ? (RootViewController.MenuType.Camera) :
            (RootViewController.MenuType.SavedLayout))
    }
}


// MARK: Table View Data Source
extension MenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemCell.id, for: indexPath) as! MenuItemCell
        cell.menuItemLabel.text = menuItemsArray[indexPath.row]
        cell.menuItemIcon.image = indexPath.row == 0 ?
            (UIImage(named: "camera.png")) :
            (UIImage(named: "chair.png"))
        
        cell.menuItemIcon.image = cell.menuItemIcon.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.menuItemIcon.tintColor = UIColor.white
        //cell.layoutMargins = UIEdgeInsets.zero
        //cell.separatorInset = UIEdgeInsets.zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.cyan.withAlphaComponent(0.5)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = .clear
    }
    
}
