/**
 This file contains code for controlling the DetailView embedded in the
 main Camera View, and the cells in the corresponding table
 */

import UIKit

// Table View Cell
class DetailCell: UITableViewCell {
    
    static let reuseIdentifier = "DetailCell"
    
    @IBOutlet weak var objectImageView: UIImageView!
    
    @IBOutlet weak var objectTitleLabel: UILabel!
    
    @IBOutlet weak var objectTotalLabel: UILabel!
    @IBOutlet weak var objectPriceLabel: UILabel!
    @IBOutlet weak var objectQuantityLabel: UILabel!
    
    // Image derived from model name
    var modelName = "" {
        didSet {
            objectTitleLabel.text = modelName.capitalized
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
    
    // format price and quantity
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
    
    // everytime popup shows, update the total label
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTotalLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
    
    // open amazon page if row is pressed
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

}
