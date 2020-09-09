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

    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? DetailViewController
        }

        objects.append(LocationWeatherViewModel(city: "Laval", temp: "0", humidity: "0", lat: CLLocationDegrees(45.6066), long: CLLocationDegrees(73.7124), seaLevel: 0, pressure: 0))
        objects.append(LocationWeatherViewModel(city: "Montréal", temp: "0", humidity: "0", lat: CLLocationDegrees(45.5017), long: CLLocationDegrees(73.5673), seaLevel: 0, pressure: 0))
        objects.append(LocationWeatherViewModel(city: "Québec", temp: "0", humidity: "0", lat: CLLocationDegrees(46.8139), long: CLLocationDegrees(71.2080), seaLevel: 0, pressure: 0))
        objects.append(LocationWeatherViewModel(city: "Vancouver", temp: "0", humidity: "0", lat: CLLocationDegrees(49.2827), long: CLLocationDegrees(123.1207), seaLevel: 0, pressure: 0))
        objects.append(LocationWeatherViewModel(city: "Toronto", temp: "0", humidity: "0", lat: CLLocationDegrees(43.6532), long: CLLocationDegrees(79.3832), seaLevel: 0, pressure: 0))
        objects.append(LocationWeatherViewModel(city: "Régina", temp: "0", humidity: "0", lat: CLLocationDegrees(50.4452), long: CLLocationDegrees(104.6189), seaLevel: 0, pressure: 0))
        objects.append(LocationWeatherViewModel(city: "Saskatoon", temp: "0", humidity: "0", lat: CLLocationDegrees(52.1579), long: CLLocationDegrees(106.6702), seaLevel: 0, pressure: 0))
        objects.append(LocationWeatherViewModel(city: "Edmonton", temp: "0", humidity: "0", lat: CLLocationDegrees(53.5461), long: CLLocationDegrees(113.4938), seaLevel: 0, pressure: 0))
        objects.append(LocationWeatherViewModel(city: "Ottawa", temp: "0", humidity: "0", lat: CLLocationDegrees(45.4215), long: CLLocationDegrees(75.6972), seaLevel: 0, pressure: 0))
        objects.append(LocationWeatherViewModel(city: "Victoria", temp: "0", humidity: "0", lat: CLLocationDegrees(48.4284), long: CLLocationDegrees(123.3656), seaLevel: 0, pressure: 0))

        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateWeather), userInfo: nil, repeats: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func getCurrentLocation() {
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        locManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locManager.delegate = self
        locManager.requestLocation()
    }

    @objc private func updateWeather() {
        for i in 0...9 {
            let model = objects[i]
            retrieveCurrentWeatherAtLat(lat: model.lat, lon: model.long, completion: { [weak self] (jsonDict) in
                self?.objects[i] = LocationWeatherViewModel(city: model.city, temp: "\(jsonDict?["temp"] ?? "")", humidity: "\(jsonDict?["humidity"] ?? "")", lat: model.lat, long: model.long, seaLevel: jsonDict?["sea_level"] as! Int, pressure: jsonDict?["grnd_level"] as! Int)
                self?.tableView.reloadData()
            })
        }
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
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm:ss.SSS"
        cell.textLabel!.text = "\(object.city) \(object.temp) \(object.humidity) \(dateFormatterGet.string(from: Date()))"
        return cell
    }
}

extension UITableViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }

        print("Lat: \(location.coordinate.latitude) Long: \(location.coordinate.longitude)")
        retrieveCurrentWeatherAtLat(lat: location.coordinate.latitude, lon: location.coordinate.longitude) { (json) in

        }
        getPlace(for: location) { [weak self] (placemark) in
            print(placemark?.locality ?? "")
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    func retrieveCurrentWeatherAtLat(lat: CLLocationDegrees, lon: CLLocationDegrees, completion: @escaping ([String: Any]?) -> Void) {
        let APIKey = "cd64cd14b81e715a84eaf3730c600661"
        let url = "https://api.openweathermap.org/data/2.5/weather?appid=\(APIKey)"
        let params = ["lat": lat, "lon": lon]
        print("Sending request... \(url)")
        let request = AF.request(url, method: .get, parameters: params, encoding: URLEncoding(destination: .queryString)).responseJSON { (response) in
            print("Got response from server: \(response)")
            switch response.result {
            case .success(let json):
                print("Success: \((json as? [String: Any])?["main"] ?? "")")
                completion((json as? [String: Any])?["main"] as? [String: Any])
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
