/**
 The code from this file was taken from Apple's tutorial:
 Handling 3D Interaction and UI Controls in Augmented Reality
 https://developer.apple.com/documentation/arkit/handling_3d_interaction_and_ui_controls_in_augmented_reality
 To this file, we added additional buttons, core data stuff, and etc.
 Look for "MARK: added code" and "MARK: end added code" for further details
 */


import ARKit
import SceneKit
import UIKit
import CoreData

// Protocol for CameraViewController Delegate
protocol CameraViewControllerDelegate: class {
    func toggleMenu()
}

class CameraViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet var sceneView: VirtualObjectARView!
    
    @IBOutlet weak var addObjectButton: UIButton!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: added code
    var imageData: Data?
    
    @IBOutlet weak var detailViewButton: UIButton!
    
    @IBOutlet weak var settingViewButtom: UIButton!
    
    // Delegate for menu button pressing
    var delegate: CameraViewControllerDelegate?
    
    // Menu button pressed
    @IBAction func menuButtonPressed(_ sender: Any) {
        delegate?.toggleMenu()
    }
    
    // Save button pressed
    @IBAction func saveLayoutPressed(_ sender: Any) {
        showInputDialog()
    }
    
    
    
    // show the input alert containing name input box
    func showInputDialog() {
        // Creating UIAlertController and setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Save Layout", message: "Enter a layout name", preferredStyle: .alert)
        
        // the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) {
            [unowned self] action in
            
            guard let textField = alertController.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            self.save(name: nameToSave)
        }
        
        // take snapshot of current view when save is pressed
        self.imageData = UIImagePNGRepresentation(self.sceneView.snapshot()) as Data?

        
        // the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        // adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Layout Name"
        }
        
        // adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        // finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    // saves to Core Data
    func save(name: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Layout",
                                                in: managedContext)!
        
        let layout = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // set a bunch of key-value pairs
        layout.setValue(name, forKeyPath: "name")
        print("Set name")
        //let imageData = UIImagePNGRepresentation(generatePhotoThumbnail(image: self.sceneView.snapshot())) as Data?;
        if self.imageData == nil {
            self.imageData = UIImagePNGRepresentation(self.sceneView.snapshot()) as Data?
        }
        layout.setValue(imageData, forKeyPath: "thumbnail")
        print("Set thumbnail")
        
        for a in VirtualObject.availableObjects {
            let v = a as VirtualObject
            switch (v.modelName) {
            case "vase":
                layout.setValue(v.modelPrice, forKeyPath: "priceVase")
                layout.setValue(v.modelQuantity, forKeyPath: "numVase")
                break
            case "chair":
                layout.setValue(v.modelPrice, forKeyPath: "priceChair")
                layout.setValue(v.modelQuantity, forKeyPath: "numChair")
                break
            case "candle":
                layout.setValue(v.modelPrice, forKeyPath: "priceCandle")
                layout.setValue(v.modelQuantity, forKeyPath: "numCandle")
                break
            case "chair":
                layout.setValue(v.modelPrice, forKeyPath: "priceChair")
                layout.setValue(v.modelQuantity, forKeyPath: "numChair")
                break
            case "cup":
                layout.setValue(v.modelPrice, forKeyPath: "priceCup")
                layout.setValue(v.modelQuantity, forKeyPath: "numCup")
                break
            case "lamp":
                layout.setValue(v.modelPrice, forKeyPath: "priceLamp")
                layout.setValue(v.modelQuantity, forKeyPath: "numLamp")
                break
            default:
                layout.setValue(v.modelPrice, forKeyPath: "priceLamp")
                layout.setValue(v.modelQuantity, forKeyPath: "numLamp")
            }
        }
        print("Set Objects")
        
        do {
            try managedContext.save()
            appDelegate.saveContext()
            print("Successfully saved entity")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    // MARK: end added code
    
    // MARK: - UI Elements
    
    var focusSquare = FocusSquare()
    
    // The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.flatMap({ $0 as? StatusViewController }).first!
    }()
    
    // MARK: - ARKit Configuration Properties
    
    /// A type which manages gesture manipulation of virtual content in the scene.
    lazy var virtualObjectInteraction = VirtualObjectInteraction(sceneView: sceneView, statusView: statusViewController)
    
    // Coordinates the loading and unloading of reference nodes for virtual objects.
    let virtualObjectLoader = VirtualObjectLoader()
    
    // Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    
    // A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "com.example.apple-samplecode.arkitexample.serialSceneKitQueue")
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Set up scene content.
        setupCamera()
        sceneView.scene.rootNode.addChildNode(focusSquare)
        
        /*
         The `sceneView.automaticallyUpdatesLighting` option creates an
         ambient light source and modulates its intensity. This sample app
         instead modulates a global lighting environment map for use with
         physically based materials, so disable automatic lighting.
         */
        sceneView.automaticallyUpdatesLighting = false
        if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
            sceneView.scene.lightingEnvironment.contents = environmentMap
        }
        
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showVirtualObjectSelectionViewController))
        // Set the delegate to ensure this gesture is only used when there are no virtual objects in the scene.
        tapGesture.delegate = self
        sceneView.addGestureRecognizer(tapGesture)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start the `ARSession`.
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.pause()
    }
    
    // MARK: - Scene content setup
    
    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }
        
        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    
    // MARK: - Session management
    
    /// Creates a new AR configuration to run on the `session`.
    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        statusViewController.scheduleMessage("Find a surface to place an object", inSeconds: 7.5, messageType: .planeEstimation)
    }
    
    // MARK: - Focus Square
    
    func updateFocusSquare() {
        
        // We should always have a valid world position unless the sceen is just being initialized.
        guard let (worldPosition, planeAnchor, _) = sceneView.worldPosition(fromScreenPosition: screenCenter, objectPosition: focusSquare.lastPosition) else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
            // MARK: added code
            addObjectButton.isHidden = true
            detailViewButton.isHidden = true
            settingViewButtom.isHidden = true
            return
        }
        
        updateQueue.async {
            self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
            let camera = self.session.currentFrame?.camera
            
            if let planeAnchor = planeAnchor {
                self.focusSquare.state = .planeDetected(anchorPosition: worldPosition, planeAnchor: planeAnchor, camera: camera)
            } else {
                self.focusSquare.state = .featuresDetected(anchorPosition: worldPosition, camera: camera)
            }
        }
        // MARK: added code
        addObjectButton.isHidden = false
        detailViewButton.isHidden = false
        settingViewButtom.isHidden = false
        statusViewController.cancelScheduledMessage(for: .focusSquare)
    }
    
    // MARK: - Error handling
    
    func displayErrorMessage(title: String, message: String) {
        // Blur the background.
        blurView.isHidden = false
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.blurView.isHidden = true
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

