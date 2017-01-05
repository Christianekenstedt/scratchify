//
//  ViewController.swift
//  Scratchify-GoogleMaps
//
//  Created by Christian Ekenstedt on 2017-01-04.
//  Copyright © 2017 Christian Ekenstedt. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var scratchImage = UIImage()
    var overlay : GMSGroundOverlay? = nil

    @IBOutlet var mapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    
        initImage()
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func eraseClicked(_ sender: Any) {
        changeOverlay(newCoordinate: (mapView.myLocation?.coordinate)!)
    }
    func initImage(){
        //let southWest = CLLocationCoordinate2D(latitude: 54.67, longitude: 9.84)
        //let northEast = CLLocationCoordinate2D(latitude: 69.22, longitude: 24.34)
        let southWest = CLLocationCoordinate2D(latitude: 58.842175, longitude: 16.325684)
        let northEast = CLLocationCoordinate2D(latitude: 59.883425, longitude: 20.10498)
        let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
        
        
        let topLeft = CLLocationCoordinate2D(latitude: northEast.latitude, longitude: southWest.longitude)
        let bottomRight = CLLocationCoordinate2D(latitude: southWest.latitude , longitude: northEast.longitude)
        
        var w = GMSGeometryDistance(southWest, bottomRight)
        var h = GMSGeometryDistance(topLeft, southWest)
        
        
        print("width = \(w), height = \(h)")
        
        var perc = (w-h)/w
        print(perc*2000)
        scratchImage = UIImage(color: UIColor.lightGray,size: CGSize(width: 2000, height: 2000*perc))! // att bytas ut!
        let imV = ScratchImageView(image: scratchImage)
        overlay = GMSGroundOverlay(bounds: overlayBounds, icon: imV.image)
        overlay!.bearing = 0
        overlay!.map = mapView
    }
    
    func changeOverlay(newCoordinate : CLLocationCoordinate2D) {
        //let southWest = CLLocationCoordinate2D(latitude: 54.67, longitude: 9.84)
        //let northEast = CLLocationCoordinate2D(latitude: 69.22, longitude: 24.34)
        
        let newImage = overlay!.icon
        let imV = ScratchImageView(image: newImage)
        let sizeOfImage = newImage?.size
        
        
        /* TEST */
        
        let southWest = CLLocationCoordinate2D(latitude: 58.842175, longitude: 16.325684)
        let northEast = CLLocationCoordinate2D(latitude: 59.883425, longitude: 20.10498)
        let topLeft = CLLocationCoordinate2D(latitude: northEast.latitude, longitude: southWest.longitude)
        let bottomRight = CLLocationCoordinate2D(latitude: southWest.latitude , longitude: northEast.longitude)
        
        print("-------------------------------")
        print("size of image = \(sizeOfImage)")
        print("topLeft = \(topLeft)")
        print("topRight = \(northEast)")
        print("bottomLeft = \(southWest)")
        print("bottomRight = \(bottomRight)")
        
        //var uttran = CLLocationCoordinate2D(latitude: 59.197034, longitude: 17.800492)
        //newCoordinate = uttran
        
        let difLeftRight = northEast.longitude - topLeft.longitude
        let difTopBottom = topLeft.latitude - southWest.latitude
        
        print("")
        print("Difference <-> = \(difLeftRight)")
        print("Difference ^v = \(difTopBottom)")
        
        let wDifInPx = (newImage?.size.width)! / CGFloat(difLeftRight)
        let hDifInPx = (newImage?.size.height)! / CGFloat(difTopBottom)
        
        print("Difference <-> = \(wDifInPx) i px")
        print("Difference ^v = \(hDifInPx) i px")
        
        let newDifH = CGFloat(topLeft.latitude-newCoordinate.latitude)
        let newDifW = CGFloat(newCoordinate.longitude-topLeft.longitude)
        
        print("Difference topLeft <-> newCoordinate = \(newDifW) i grader")
        print("Difference topLeft ^v newCoordinate = \(newDifH) i grader")
        
        var x = (newDifW * wDifInPx)
        var y = (newDifH * hDifInPx)
        y = y * 1.005 // ingen aning om detta funkar i längden, ökar y med 0.05 % för bättre pricksäkerhet.
        print("x=\(x), y=\(y)")
        let one = CGPoint(x: x, y: y)
        let two = CGPoint(x: x, y: y)
        
        /* END TEST */

        
        imV.erase(from:  one, toPoint: two)
        overlay?.icon = imV.image
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("did move")
    }


}

// LÅNAD EXTENSION!
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
