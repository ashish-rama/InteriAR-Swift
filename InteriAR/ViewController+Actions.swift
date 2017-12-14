/**
 The code from this file was taken from Apple's tutorial:
 Handling 3D Interaction and UI Controls in Augmented Reality
 https://developer.apple.com/documentation/arkit/handling_3d_interaction_and_ui_controls_in_augmented_reality
 To this file, we added additional segues: showDetail and showSettings
 as well as their corresponding logic
 Look for "MARK: added code" for further details
 */


import UIKit
import SceneKit

extension ViewController: UIGestureRecognizerDelegate {
    
    enum SegueIdentifier: String {
        case showObjects
        case showDetail
        case showSettings
    }
    
    // MARK: - Interface Actions
    
    /// Displays the `VirtualObjectSelectionViewController` from the `addObjectButton` or in response to a tap gesture in the `sceneView`.
    @IBAction func showVirtualObjectSelectionViewController() {
        // Ensure adding objects is an available action and we are not loading another object (to avoid concurrent modifications of the scene).
        guard !addObjectButton.isHidden && !virtualObjectLoader.isLoading else { return }
        
        statusViewController.cancelScheduledMessage(for: .contentPlacement)
        performSegue(withIdentifier: SegueIdentifier.showObjects.rawValue, sender: addObjectButton)
    }
    
    /// Determines if the tap gesture for presenting the `VirtualObjectSelectionViewController` should be used.
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return virtualObjectLoader.loadedObjects.isEmpty
    }
    
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /// - Tag: restartExperience
    func restartExperience() {
        guard isRestartAvailable, !virtualObjectLoader.isLoading else { return }
        isRestartAvailable = false

        statusViewController.cancelAllScheduledMessages()

        virtualObjectLoader.removeAllVirtualObjects()
        
        addObjectButton.setImage(#imageLiteral(resourceName: "add"), for: [])
        addObjectButton.setImage(#imageLiteral(resourceName: "addPressed"), for: [.highlighted])

        resetTracking()

        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
        
        // MARK: added code
        for i in 0..<VirtualObject.availableObjects.count {
            let tempObject = VirtualObject.availableObjects[i] as VirtualObject
            tempObject.modelQuantity = 0
        }
        
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    
    // MARK: - UIPopoverPresentationControllerDelegate

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // All menus should be popovers (even on iPhone).
        if let popoverController = segue.destination.popoverPresentationController, let button = sender as? UIButton {
            popoverController.delegate = self
            popoverController.sourceView = button
            popoverController.sourceRect = button.bounds
        }
        
        // MARK: added code
        guard let identifier = segue.identifier,
              let segueIdentifer = SegueIdentifier(rawValue: identifier),
              segueIdentifer == .showObjects || segueIdentifer == .showDetail ||
                segueIdentifer == .showSettings else { return }
        
        if segueIdentifer == .showObjects {
            let objectsViewController = segue.destination as! VirtualObjectSelectionViewController
            objectsViewController.virtualObjects = VirtualObject.availableObjects
            objectsViewController.delegate = self
        } else if segueIdentifer == .showDetail {
            let detailViewController = segue.destination as! DetailTableViewController
            detailViewController.placedObjects = VirtualObject.availableObjects
        }
    }
    
}
