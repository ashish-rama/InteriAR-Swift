/**
 The code from this file was based off of Apple's tutorial:
 Handling 3D Interaction and UI Controls in Augmented Reality
 https://developer.apple.com/documentation/arkit/handling_3d_interaction_and_ui_controls_in_augmented_reality
 The only portion of code that remains unchanged from the original is
 VirtualObjectSelectionViewControllerDelegate.
 The rest was written/modified.
 */

import UIKit

class ObjectCell: UITableViewCell {
    static let reuseIdentifier = "ObjectCell"
    
    @IBOutlet weak var objectTitleLabel: UILabel!
    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var objectDescription: UILabel!
    @IBOutlet weak var objectPrice: UILabel!
    
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
    
    var modelPrice = 0.00 {
        didSet {
            objectPrice.text = "$" + String(format: "%.2f", modelPrice)
        }
    }
    
    var modelDescription = "" {
        didSet {
            objectDescription.text = modelDescription
        }
    }
}

// MARK: - VirtualObjectSelectionViewControllerDelegate

/// A protocol for reporting which objects have been selected.
protocol VirtualObjectSelectionViewControllerDelegate: class {
    func virtualObjectSelectionViewController(_ selectionViewController: VirtualObjectSelectionViewController,
                                              object: VirtualObject)
}

class VirtualObjectSelectionViewController: UITableViewController {
    
    /// The collection of VirtualObjects to select from.
    public var virtualObjects = [VirtualObject]()
    
    weak var delegate: VirtualObjectSelectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: tableView.contentSize.width, height: tableView.contentSize.height)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = virtualObjects[indexPath.row]
        object.modelQuantity += 1

        // clone object to allow multiple instances of each
        // AR object to be placed
        let newObject = object.clone();
        newObject.parentObject = object
        delegate?.virtualObjectSelectionViewController(self, object: newObject)
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return virtualObjects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ObjectCell.reuseIdentifier, for: indexPath) as? ObjectCell else {
            fatalError("Expected `\(ObjectCell.self)` type for reuseIdentifier \(ObjectCell.reuseIdentifier). Check the configuration in Main.storyboard.")
        }
        
        cell.modelName = virtualObjects[indexPath.row].modelName
        cell.modelDescription = virtualObjects[indexPath.row].modelDescription
        cell.modelPrice = virtualObjects[indexPath.row].modelPrice

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = .clear
    }
}
