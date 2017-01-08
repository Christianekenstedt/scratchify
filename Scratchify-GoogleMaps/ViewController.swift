//
//  ViewController.swift
//  Scratchify-GoogleMaps
//
//  Created by Christian Ekenstedt on 2017-01-04.
//  Copyright © 2017 Christian Ekenstedt. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var scratchImage = UIImage()
    var overlay : GMSGroundOverlay? = nil

    @IBOutlet var mapView: GMSMapView!
    
    let southWest = CLLocationCoordinate2D(latitude: 58.842175, longitude: 16.325684)
    let northEast = CLLocationCoordinate2D(latitude: 59.883425, longitude: 20.10498)
    
    @IBAction func testSaveBtn(_ sender: Any) {
        ScratchEngine.saveUserImage(image: (overlay?.icon!)!)
    }
    @IBAction func testGetBtn(_ sender: Any) {
        ScratchEngine.getUserImage()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNotifications()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization() // If not allowed, request permission to use device location.
        
        
        mapView.isMyLocationEnabled = true // Set device location on map.
        mapView.settings.myLocationButton = true // Add the "My location button" on map.
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // The accuracy of the device location.
        locationManager.distanceFilter = 10 // The filter, when it should trigger a location didUpdateLocations (in meters).
        locationManager.startUpdatingLocation() // Starts the update of locations.
        
        moveCamera()
        ScratchEngine.getUserImage() // Create a new overlay on map.
    }
    
    func moveCamera(){
        let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast) // Set the bounds of the rectangle.
        
        let initPos  = mapView.camera(for: overlayBounds, insets: .zero)! // Set the camera at the bounds.
        mapView.camera = initPos
    }
    
    func initNotifications() {
        NotificationCenter.default.addObserver(self,selector: #selector(ViewController.trigOverlayUpdate),name: NSNotification.Name(rawValue: "updateOverlay"), object: nil)
    }
    
    func trigOverlayUpdate(_ notification: NSNotification){
        if let image = notification.userInfo?["image"] as? UIImage {
            initImage(savedImage: image)
        }
        
    }
    /*
     *  Init the scratch image. A new.
     */
    func initImage(){
        
        let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast) // Set the bounds of the rectangle.
        
        let initPos  = mapView.camera(for: overlayBounds, insets: .zero)! // Set the camera at the bounds.
        mapView.camera = initPos
        
        let topLeft = CLLocationCoordinate2D(latitude: northEast.latitude, longitude: southWest.longitude) // Calculate the North West coordinate
        let bottomRight = CLLocationCoordinate2D(latitude: southWest.latitude , longitude: northEast.longitude) // Calculate the South East coordinate
        
        /* Calculates the difference in meters */
        let w = GMSGeometryDistance(southWest, bottomRight)
        let h = GMSGeometryDistance(topLeft, southWest)
        
        let perc = (w-h)/w // Calculate a aprox. percentage
        
        scratchImage = UIImage(color: UIColor.lightGray,size: CGSize(width: 2000, height: 2000*perc))! // Create the image with a solid color.
        let imV = ScratchImageView(image: scratchImage) // Create an imageView and set the created image.
        
        /* Create the overlay with the image */
        overlay = GMSGroundOverlay(bounds: overlayBounds, icon: imV.image)
        overlay!.bearing = 0
        overlay!.map = mapView // Set the overlay on the current mapView
    }
    
    /*
     * Init image if ther is an already.
     */
    func initImage(savedImage : UIImage) {
        print("Size of image from Db = \(savedImage.size)")
        let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast) // Set the bounds of the rectangle.
        
        let imV = ScratchImageView(image: savedImage) // Create an imageView and set the savedImage.
        
        /* Create the overlay with the image */
        overlay = GMSGroundOverlay(bounds: overlayBounds, icon: imV.image)
        overlay!.bearing = 0
        overlay!.map = mapView // Set the overlay on the current mapView
    }
    
    /*
     *  Function to change, to erase the at a point on the image. The point is the newCoordinate the is passed through as a parameter.
     */
    func changeOverlay(newCoordinate : CLLocationCoordinate2D) {
        
        let newImage = overlay!.icon
        let imV = ScratchImageView(image: newImage) // Creates a ImageView.
        
        let topLeft = CLLocationCoordinate2D(latitude: northEast.latitude, longitude: southWest.longitude)
        
        let difLeftRight = northEast.longitude - topLeft.longitude // Calculate number of degrees longitude that differs between north east and north west coordinate
        let difTopBottom = topLeft.latitude - southWest.latitude // Calculate number of degrees latitude that differs between south west and north west coordinate
        
        /* Calculate the relation between pixels and degree */
        let wDifInPx = (newImage?.size.width)! / CGFloat(difLeftRight)
        let hDifInPx = (newImage?.size.height)! / CGFloat(difTopBottom)
        
        /* Calculate the the differance between the new coordinate and the reference coordinate */
        let newDifH = CGFloat(topLeft.latitude-newCoordinate.latitude)
        let newDifW = CGFloat(newCoordinate.longitude-topLeft.longitude)
        
        /* Create the x and y point */
        let x = (newDifW * wDifInPx)
        var y = (newDifH * hDifInPx)
        
        y = y * 1.005 // Constant 1.005 to the y axis to compensate the shape of earth. (Tveksam, men det blir bättre pricsäkerhet.)
        
        print("x=\(x), y=\(y)")
        let one = CGPoint(x: x, y: y) // From-point
        let two = CGPoint(x: x, y: y) // To-point
        
        imV.erase(from:  one, toPoint: two) // Erase from to point (Just nu tar den bara bort på en punkt.)
        overlay?.icon = imV.image // Set the new image.
    }
    
    /*
     * Triggerd when location is updated.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var userLocation = mapView.myLocation?.coordinate
        
        for l in locations {
            print(l.coordinate)
            userLocation = l.coordinate
        }
        
        if overlay?.icon != nil {
            changeOverlay(newCoordinate: userLocation!) // Update the overlay.
        }
    }
    
    /*
     * Set camera to map region.
     */
    func setMapRegion(){
        if mapView.isMyLocationEnabled {
            if let userLocation = mapView.myLocation?.coordinate {
                let camera = GMSCameraPosition.camera(withLatitude: (userLocation.latitude),longitude: (userLocation.longitude),zoom: 10)
                mapView.camera = camera
            }
        }
    }
}

// LÅNAD EXTENSION! Need to fix.
public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
