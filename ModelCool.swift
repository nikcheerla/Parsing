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
    var ids: [String] = [];
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
        clam["comments"] = [];
        clam.save()
    }
    func download(){
        var query = PFQuery(className: "Clamor");
        
        query.orderByDescending("rating");
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                NSLog("Successfully retrieved \(objects.count) scores.")
                // Do something with the found objects
                self.contentList = [];
                self.ratingsList = [];
                self.ids = [];
                for object in objects {
                    var rating = object["rating"] as Int;
                    var content = object["content"] as String;
                    var radius = object["radius"] as Double;
                    var remote = object["Location"] as PFGeoPoint;
                    
                    var dist = remote.distanceInKilometersTo(self.curloc);
                    if(dist < radius){
                        self.contentList.append(content);
                        self.ratingsList.append(rating);
                        self.ids.append(object.objectId);
                    }
                }
                
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    func like(ind : Int){
        var query = PFQuery(className: "Clamor");
        
        if(ind < 0 || ind >= ids.count){
            return;
        }
        var obj = query.getObjectWithId(ids[ind])
        obj.incrementKey("rating");
        obj.save();
    }
    func like(content : String){
        var i = 0;
        for c in contentList {
            if(c == content) {
                like(i);
                return;
            }
            i++;
        }
    }
    func downvote(ind: Int){
        var query = PFQuery(className: "Clamor");
        
        if(ind < 0 || ind >= ids.count){
            return;
        }
        var obj = query.getObjectWithId(ids[ind])
        obj.incrementKey("rating", byAmount: -1);
        obj.save();
    }
    func downvote(content : String){
        var i = 0;
        for c in contentList {
            if(c == content) {
                downvote(i);
                return;
            }
            i++;
        }
    }
    func getComments(ind: Int) -> Array<String>{
        var query = PFQuery(className: "Clamor");
        
        if(ind < 0 || ind >= ids.count){
            return [];
        }
        var obj = query.getObjectWithId(ids[ind]);
        return obj["comments"] as Array<String>;
    }
    func getComments(content: String) -> Array<String>{
        var i = 0;
        for c in contentList {
            if(c == content) {
                return getComments(i);
            }
            i++;
        }
        return [];
    }
    func comment(comment: String, ind: Int){
        var query = PFQuery(className: "Clamor");
        if(ind < 0 || ind >= ids.count){
            return;
        }
        var obj = query.getObjectWithId(ids[ind]);
        var strarr = (obj["comments"] as Array<String>);
        strarr.append(comment);
        obj["comments"] = strarr;
        var obj2 = obj["user"] as PFObject;
        
        var arr = obj2.fetchIfNeeded();
        
        if  ( arr != nil && (arr["comments"] as Array<String>).count != 0){
            strarr = (arr["comments"] as Array<String>);
            strarr.append(comment);
            arr["comments"] = strarr;
        }
        
        
        obj.save();
        obj2.save();
    }
    func comment(com: String, content: String){
        var i = 0;
        for c in contentList {
            if(c == content) {
                comment(com, ind: i);
                return;
            }
            i++;
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
