/**
 This file lays out a table view of saved layouts
 */

import UIKit
import CoreData

class SaveCell: UITableViewCell {
    static let reuseIdentifier = "SaveCell"
    
    @IBOutlet weak var imageThumbnail: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
}


class SaveTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var layouts: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Layout")
        do {
            layouts = try managedContext.fetch(fetchRequest)
            print("Loaded all layouts")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return layouts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let layout = layouts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SaveCell", for: indexPath) as! SaveCell
        cell.nameLabel?.text = layout.value(forKeyPath: "name") as? String
        let imageData = layout.value(forKeyPath: "thumbnail") as? Data;
        cell.imageView?.image = UIImage(data: imageData!)
        
        //        let dateFormatter = DateFormatter()
        //        let dateData = layout.value(forKeyPath: "date") as? Date;
        //        let timeString = "\(dateFormatter.string(from: dateData!))"
        //        cell.dateLabel.text = timeString
        return cell
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: tableView.contentSize.width, height: tableView.contentSize.height)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let objectToDelete = layouts[indexPath.row]
            layouts.remove(at: indexPath.row)
            managedContext.delete(objectToDelete)
            
            do {
                try managedContext.save()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch let error {
                print("Could not save Deletion \(error)")
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier ?? "") {
        case "showLayout":
            guard let navViewController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let layoutViewController = navViewController.topViewController as? LayoutViewController else {
                fatalError("Can't load LayoutViewController")
            }
            
            guard let selectedLayoutCell = sender as? SaveCell else {
                fatalError("Unexpected sender: \(sender ?? "")")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedLayoutCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedLayout = layouts[indexPath.row]
            layoutViewController.layout = selectedLayout
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "")")
        }
    }
    
}

