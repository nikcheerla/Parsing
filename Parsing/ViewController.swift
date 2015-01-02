//
//  ViewController.swift
//  Parsing
//
//  Created by Nikhil Cheerla on 1/1/15.
//  Copyright (c) 2015 Haxors. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var field: UITextField!
    let locationManager = CLLocationManager();
    var model: ModelCool = ModelCool(locate: false);
    override func viewDidLoad() {
        super.viewDidLoad();
        model = ModelCool(locate: true);
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func pressed(sender: AnyObject) {
        var content = field.text;
        field.text = "";
        model.upload(content, radius: 0.75);
    }
}

