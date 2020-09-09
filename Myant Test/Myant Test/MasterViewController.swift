//
//  MasterViewController.swift
//  Myant Test
//
//  Created by Ghislain Leblanc on 2020-09-09.
//  Copyright © 2020 Leblanc, Ghislain. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [LocationWeatherViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        getCurrentLocation()

        objects.append(LocationWeatherViewModel(city: "Laval", temp: "0", humidity: "0"))
        objects.append(LocationWeatherViewModel(city: "Montréal", temp: "0", humidity: "0"))
        objects.append(LocationWeatherViewModel(city: "Québec", temp: "0", humidity: "0"))
        objects.append(LocationWeatherViewModel(city: "Vancouver", temp: "0", humidity: "0"))
        objects.append(LocationWeatherViewModel(city: "Toronto", temp: "0", humidity: "0"))
        objects.append(LocationWeatherViewModel(city: "Régina", temp: "0", humidity: "0"))
        objects.append(LocationWeatherViewModel(city: "Saskatoon", temp: "0", humidity: "0"))
        objects.append(LocationWeatherViewModel(city: "Edmonton", temp: "0", humidity: "0"))
        objects.append(LocationWeatherViewModel(city: "Ottawa", temp: "0", humidity: "0"))
        objects.append(LocationWeatherViewModel(city: "Victoria", temp: "0", humidity: "0"))

        tableView.reloadData()
    }

    private func getCurrentLocation() {
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        locManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locManager.delegate = self
        locManager.requestLocation()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let object = objects[indexPath.row]
        cell.textLabel!.text = object.city
        return cell
    }
}

extension UITableViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }

        print("Lat: \(location.coordinate.latitude) Long: \(location.coordinate.longitude)")
        retrieveCurrentWeatherAtLat(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        getPlace(for: location) { [weak self] (placemark) in
            print(placemark?.locality ?? "")
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    private func retrieveCurrentWeatherAtLat(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let APIKey = "cd64cd14b81e715a84eaf3730c600661"
        let url = "https://api.openweathermap.org/data/2.5/weather?appid=\(APIKey)"
        let params = ["lat": lat, "lon": lon]
        print("Sending request... \(url)")
        let request = AF.request(url, method: .get, parameters: params, encoding: URLEncoding(destination: .queryString)).responseJSON { (response) in
            print("Got response from server: \(response)")
            switch response.result {
            case .success(let json):
                print("Success: \((json as? [String: Any])?["main"] ?? "")")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        request.resume()
    }

    private func getPlace(for location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in

            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil)
                return
            }

            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }

            completion(placemark)
        }
    }
}
