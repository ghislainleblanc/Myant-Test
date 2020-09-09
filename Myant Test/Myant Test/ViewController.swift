//
//  ViewController.swift
//  Myant Test
//
//  Created by Ghislain Leblanc on 2020-09-09.
//  Copyright © 2020 Leblanc, Ghislain. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class ViewController: UIViewController {
    private let APIKey = "cd64cd14b81e715a84eaf3730c600661"

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

    private func retrieveCurrentWeatherAtLat(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let url = "https://api.openweathermap.org/data/2.5/weather?appid=\(APIKey)"
        let params = ["lat": lat, "lon": lon]
        print("Sending request... \(url)")
        let request = AF.request(url, method: .get, parameters: params, encoding: URLEncoding(destination: .queryString)).responseJSON { (response) in
            print("Got response from server: \(response)")
            switch response.result {
            case .success(let json):
                print("Success: \(json)") //test
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        request.resume()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }

        print("Lat: \(location.coordinate.latitude) Long: \(location.coordinate.longitude)")
        retrieveCurrentWeatherAtLat(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
