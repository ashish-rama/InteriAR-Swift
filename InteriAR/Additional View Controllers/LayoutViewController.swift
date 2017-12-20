/**
 New File:
 This file lays out a detailed view associated with each saved layout
 */

import UIKit
import CoreData

class LayoutViewController: UIViewController {
    
    var layout: NSManagedObject?
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var chairT: UILabel!
    @IBOutlet weak var vaseT: UILabel!
    @IBOutlet weak var cupT: UILabel!
    @IBOutlet weak var lampT: UILabel!
    @IBOutlet weak var candleT: UILabel!
    @IBOutlet weak var candleP: UILabel!
    @IBOutlet weak var lampP: UILabel!
    @IBOutlet weak var cupP: UILabel!
    @IBOutlet weak var chairP: UILabel!
    @IBOutlet weak var vaseP: UILabel!
    @IBOutlet weak var chairQ: UILabel!
    @IBOutlet weak var vaseQ: UILabel!
    @IBOutlet weak var cupQ: UILabel!
    @IBOutlet weak var lampQ: UILabel!
    @IBOutlet weak var candleQ: UILabel!
    @IBOutlet weak var roomImage: UIImageView!
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = layout {
            var total: Float = 0.0
            if layout.value(forKeyPath: "name") != nil {
                navigationItem.title = layout.value(forKeyPath: "name") as? String
            } else {
                navigationItem.title = "Unnamed Layout"
            }
            
            // do calculations
            var q: Int = 0
            var p: Float = 0.0
            if layout.value(forKeyPath: "numCup") != nil {
                q = layout.value(forKeyPath: "numCup") as! Int
            }
            if layout.value(forKeyPath: "priceCup") != nil {
                p = layout.value(forKeyPath: "priceCup") as! Float
            }
            var totalT = p * Float(q)
            total += totalT
            cupQ.text = String(format:"%d", q)
            cupP.text = String(format:"$%.2f", p)
            cupT.text = String(format:"$%.2f", totalT)
            
            if layout.value(forKeyPath: "numCandle") != nil {
                q = layout.value(forKeyPath: "numCandle") as! Int
            }
            if layout.value(forKeyPath: "priceCandle") != nil {
                p = layout.value(forKeyPath: "priceCandle") as! Float
            }
            totalT = p * Float(q)
            total += totalT
            candleQ.text = String(format:"%d", q)
            candleP.text = String(format:"$%.2f", p)
            candleT.text = String(format:"$%.2f", totalT)
            
            if layout.value(forKeyPath: "numChair") != nil {
                q = layout.value(forKeyPath: "numChair") as! Int
            }
            if layout.value(forKeyPath: "priceChair") != nil {
                p = layout.value(forKeyPath: "priceChair") as! Float
            }
            totalT = p * Float(q)
            total += totalT
            chairQ.text = String(format:"%d", q)
            chairP.text = String(format:"$%.2f", p)
            chairT.text = String(format:"$%.2f", totalT)
            
            if layout.value(forKeyPath: "numVase") != nil {
                q = layout.value(forKeyPath: "numVase") as! Int
            }
            if layout.value(forKeyPath: "priceVase") != nil {
                p = layout.value(forKeyPath: "priceVase") as! Float
            }
            totalT = p * Float(q)
            total += totalT
            vaseQ.text = String(format:"%d", q)
            vaseP.text = String(format:"$%.2f", p)
            vaseT.text = String(format:"$%.2f", totalT)
            
            if layout.value(forKeyPath: "numLamp") != nil {
                q = layout.value(forKeyPath: "numLamp") as! Int
            }
            if layout.value(forKeyPath: "priceLamp") != nil {
                p = layout.value(forKeyPath: "priceLamp") as! Float
            }
            totalT = p * Float(q)
            total += totalT
            lampQ.text = String(format:"%d", q)
            lampP.text = String(format:"$%.2f", p)
            lampT.text = String(format:"$%.2f", totalT)
            
            totalLabel.text = String(format:"$%.2f", total)
            
            let imageData = layout.value(forKeyPath: "thumbnail") as? Data;
            roomImage.image = UIImage(data: imageData!)
            
            print("Loaded detailed layout")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

