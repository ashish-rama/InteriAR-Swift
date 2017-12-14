//
//  DetailTableViewController.swift
//  ARKitInteraction
//
//  Created by Herbert Li on 11/27/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {
    static let reuseIdentifier = "DetailCell"
    
    @IBOutlet weak var objectImageView: UIImageView!
    
    @IBOutlet weak var objectTitleLabel: UILabel!
    
    @IBOutlet weak var objectTotalLabel: UILabel!
    @IBOutlet weak var objectPriceLabel: UILabel!
    @IBOutlet weak var objectQuantityLabel: UILabel!
    
    var modelName = "" {
        didSet {
            objectTitleLabel.text = modelName.capitalized
            //objectImageView.image = UIImage(named: modelName)
            var name = ""
            switch modelName {
            case "lamp":
                name = "lamp_detail.png"
                break
            case "cup":
                name = "cup_detail.png"
                break
            case "candle":
                name = "candle_detail.png"
                break
            case "chair":
                name = "chair_detail.png"
                break
            case "vase":
                name = "vase_detail.png"
                break
            default:
                name = "cup_detail.png"
                break
            }
            objectImageView.image = UIImage(named: name)
        }
    }
    
    var modelPrice = 0.0 {
        didSet {
            objectPriceLabel.text = String(format: "$%.2f", modelPrice)
            objectTotalLabel.text = String(format: "$%.2f", Double(modelQuantity) * modelPrice)
        }
    }
    
    var modelQuantity = 1 {
        didSet {
            objectQuantityLabel.text = String(format: "%d", modelQuantity)
            objectTotalLabel.text = String(format: "$%.2f", Double(modelQuantity) * modelPrice)
        }
    }
    
}

class DetailTableViewController: UITableViewController {

    @IBOutlet weak var totalLabel: UILabel!
    var placedObjects = [VirtualObject]()
    
    func updateTotalLabel() {
        var sum: Double = 0.0;
        for i in 0..<placedObjects.count {
            let tempObject = placedObjects[i] as VirtualObject
            sum += tempObject.modelPrice * Double(tempObject.modelQuantity)
        }
        totalLabel.text = String(format: "Total: $%.2f", sum)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTotalLabel()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placedObjects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.reuseIdentifier, for: indexPath) as? DetailCell else {
            fatalError("Expected `\(DetailCell.self)` type for reuseIdentifier \(DetailCell.reuseIdentifier). Check the configuration in Main.storyboard.")
        }
        
        cell.modelName = placedObjects[indexPath.row].modelName
        cell.modelPrice = placedObjects[indexPath.row].modelPrice
        cell.modelQuantity = placedObjects[indexPath.row].modelQuantity
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let url = URL(string: placedObjects[indexPath.row].modelURL) else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: tableView.contentSize.width, height: tableView.contentSize.height)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
