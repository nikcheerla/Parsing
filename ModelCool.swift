//
//  ModelCool.swift
//  Parsing
//
//  Created by Nikhil Cheerla on 1/1/15.
//  Copyright (c) 2015 Haxors. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

class ModelCool: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager();
    var curloc = PFGeoPoint();
    var contentList: [String] = [];
    var ratingsList: [Int] = [];
    init(locate: Bool){
        super.init();
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            println("Location services are not enabled");
        }
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as CLPlacemark
                self.displayLocationInfo(pm);
                self.curloc = PFGeoPoint(location: pm.location);
            } else {
                println("Problem with the data received from geocoder")
            }
        })
    }
    func displayLocationInfo(placemark: CLPlacemark) {
        //stop updating location to save battery life
        locationManager.stopUpdatingLocation()
        println(placemark.locality != nil ? placemark.locality : "")
        println(placemark.postalCode != nil ? placemark.postalCode : "")
        println(placemark.administrativeArea != nil ? placemark.administrativeArea : "")
        println(placemark.country != nil ? placemark.country : "")
    }
    func upload(content: String, radius: Double){
        var clam = PFObject(className:"Clamor")
        clam["content"] = content
        clam["rating"] = 5;
        clam["radius"] = radius;
        clam["Location"] = curloc;
        clam["user"] = PFUser.currentUser();
        clam.save()
    }
    func download(){
        var query = PFQuery(className: "Clamor");
        
        query.orderByAscending("rating");
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                NSLog("Successfully retrieved \(objects.count) scores.")
                // Do something with the found objects
                self.contentList = [];
                self.ratingsList = [];
                for object in objects {
                    var rating = object["rating"] as Int;
                    var content = object["content"] as String;
                    var radius = object["radius"] as Double;
                    var remote = object["Location"] as PFGeoPoint;
                    
                    var dist = remote.distanceInKilometersTo(self.curloc);
                    if(dist < radius){
                        self.contentList.append(content);
                        self.ratingsList.append(rating);
                    }
                }
                println(self.contentList);
                println(self.ratingsList);
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    // MARK: - CoreLocation Delegate Methods
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if ((error) != nil) {
            print(error)
        }
    }
}
