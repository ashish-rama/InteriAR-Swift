/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A `SCNReferenceNode` subclass for virtual objects placed into the AR scene.
 */

import Foundation
import SceneKit
import ARKit

class VirtualObject: SCNReferenceNode {
    
    init(url: URL, modelDescription: String, modelPrice: Double, modelQuantity: Int, modelURL: String) {
        self.modelDescription = modelDescription
        self.modelPrice = modelPrice
        self.modelQuantity = modelQuantity
        self.modelURL = modelURL
        super.init(url: url)!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var modelDescription: String
    var modelPrice: Double
    var modelQuantity: Int
    var modelURL: String
    
    var parentObject: VirtualObject?
    
    /// The model name derived from the `referenceURL`.
    var modelName: String {
        return referenceURL.lastPathComponent.replacingOccurrences(of: ".scn", with: "")
    }
    
    /// Use average of recent virtual object distances to avoid rapid changes in object scale.
    private var recentVirtualObjectDistances = [Float]()
    
    /// Resets the objects poisition smoothing.
    func reset() {
        recentVirtualObjectDistances.removeAll()
    }
    
    /**
     Set the object's position based on the provided position relative to the `cameraTransform`.
     If `smoothMovement` is true, the new position will be averaged with previous position to
     avoid large jumps.
     
     - Tag: VirtualObjectSetPosition
     */
    func setPosition(_ newPosition: float3, relativeTo cameraTransform: matrix_float4x4, smoothMovement: Bool) {
        let cameraWorldPosition = cameraTransform.translation
        var positionOffsetFromCamera = newPosition - cameraWorldPosition
        
        // Limit the distance of the object from the camera to a maximum of 10 meters.
        if simd_length(positionOffsetFromCamera) > 10 {
            positionOffsetFromCamera = simd_normalize(positionOffsetFromCamera)
            positionOffsetFromCamera *= 10
        }
        
        /*
         Compute the average distance of the object from the camera over the last ten
         updates. Notice that the distance is applied to the vector from
         the camera to the content, so it affects only the percieved distance to the
         object. Averaging does _not_ make the content "lag".
         */
        if smoothMovement {
            let hitTestResultDistance = simd_length(positionOffsetFromCamera)
            
            // Add the latest position and keep up to 10 recent distances to smooth with.
            recentVirtualObjectDistances.append(hitTestResultDistance)
            recentVirtualObjectDistances = Array(recentVirtualObjectDistances.suffix(10))
            
            let averageDistance = recentVirtualObjectDistances.average!
            let averagedDistancePosition = simd_normalize(positionOffsetFromCamera) * averageDistance
            simdPosition = cameraWorldPosition + averagedDistancePosition
        } else {
            simdPosition = cameraWorldPosition + positionOffsetFromCamera
        }
    }
    
    /// - Tag: AdjustOntoPlaneAnchor
    func adjustOntoPlaneAnchor(_ anchor: ARPlaneAnchor, using node: SCNNode) {
        // Get the object's position in the plane's coordinate system.
        let planePosition = node.convertPosition(position, from: parent)
        
        // Check that the object is not already on the plane.
        guard planePosition.y != 0 else { return }
        
        // Add 10% tolerance to the corners of the plane.
        let tolerance: Float = 0.1
        
        let minX: Float = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance
        let maxX: Float = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance
        let minZ: Float = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance
        let maxZ: Float = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance
        
        guard (minX...maxX).contains(planePosition.x) && (minZ...maxZ).contains(planePosition.z) else {
            return
        }
        
        // Move onto the plane if it is near it (within 5 centimeters).
        let verticalAllowance: Float = 0.05
        let epsilon: Float = 0.001 // Do not update if the difference is less than 1 mm.
        let distanceToPlane = abs(planePosition.y)
        if distanceToPlane > epsilon && distanceToPlane < verticalAllowance {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = CFTimeInterval(distanceToPlane * 500) // Move 2 mm per second.
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            position.y = anchor.transform.columns.3.y
            SCNTransaction.commit()
        }
    }
}

extension VirtualObject {
    // MARK: Static Properties and Methods
    
    /// Loads all the model objects within `Models.scnassets`.
    static let availableObjects: [VirtualObject] = {
        let modelsURL = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!
        
        let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!
        
        return fileEnumerator.flatMap { element in
            let url = element as! URL
            
            guard url.pathExtension == "scn" else { return nil }
            
            switch (url.lastPathComponent) {
            case "candle.scn":
                return VirtualObject(url: url, modelDescription: "For romantic nights.", modelPrice: 16.00, modelQuantity: 0, modelURL: "https://www.amazon.com/Celestial-Lights-Bright-Battery-Operated/dp/B077VXWJSR/ref=sr_1_15?ie=UTF8&qid=1512546876&sr=8-15&keywords=candle")
            case "chair.scn":
                return VirtualObject(url: url, modelDescription: "A red office chair.", modelPrice: 35.00, modelQuantity: 0, modelURL: "https://www.amazon.com/Poly-Bark-Vortex-Chair-Walnut/dp/B01J7ZEIZ6/ref=sr_1_24?s=home-garden&ie=UTF8&qid=1512546907&sr=1-24&keywords=red+chair")
            case "cup.scn":
                return VirtualObject(url: url, modelDescription: "A cup of java.", modelPrice: 5.00, modelQuantity: 0, modelURL: "https://www.amazon.com/Coffee-Large-sized-Ceramic-Restaurant-Bruntmor/dp/B072FTVD1G/ref=sr_1_7?s=home-garden&ie=UTF8&qid=1512546944&sr=1-7&keywords=coffee+mug")
            case "lamp.scn":
                return VirtualObject(url: url, modelDescription: "A new chic lamp.", modelPrice: 200.00, modelQuantity: 0, modelURL: "https://www.amazon.com/Possini-Euro-Cherry-Finish-Surveyor/dp/B008KZY3DW/ref=sr_1_2_sspa?s=home-garden&ie=UTF8&qid=1512546979&sr=1-2-spons&keywords=lamp&psc=1")
            case "vase.scn":
                return VirtualObject(url: url, modelDescription: "Priceless vase.", modelPrice: 40.00, modelQuantity: 0, modelURL: "https://www.amazon.com/28-Cylinder-Bamboo-Floor-Vase/dp/B000CS1KI6/ref=sr_1_14?s=home-garden&ie=UTF8&qid=1512547022&sr=1-14&keywords=red+vase")
            default:
                return VirtualObject(url: url, modelDescription: "something", modelPrice: 2.00, modelQuantity: 0, modelURL: "")
            }
            
        }
    }()
    
    /// Returns a `VirtualObject` if one exists as an ancestor to the provided node.
    static func existingObjectContainingNode(_ node: SCNNode) -> VirtualObject? {
        if let virtualObjectRoot = node as? VirtualObject {
            return virtualObjectRoot
        }
        
        guard let parent = node.parent else { return nil }
        
        // Recurse up to check if the parent is a `VirtualObject`.
        return existingObjectContainingNode(parent)
    }
}

extension Collection where Iterator.Element == Float, IndexDistance == Int {
    /// Return the mean of a list of Floats. Used with `recentVirtualObjectDistances`.
    var average: Float? {
        guard !isEmpty else {
            return nil
        }
        
        let sum = reduce(Float(0)) { current, next -> Float in
            return current + next
        }
        
        return sum / Float(count)
    }
}

