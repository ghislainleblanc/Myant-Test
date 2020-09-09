//
//  ViewController.swift
//  Myant Test
//
//  Created by Ghislain Leblanc on 2020-09-09.
//  Copyright © 2020 Leblanc, Ghislain. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        getCurrentLocation()
    }

    private func getCurrentLocation() {
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        locManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locManager.delegate = self
        locManager.requestLocation()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }

        print("Lat: \(location.coordinate.latitude) Long: \(location.coordinate.longitude)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
