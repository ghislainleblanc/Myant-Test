//
//  LocationWeatherViewModel.swift
//  Myant Test
//
//  Created by Ghislain Leblanc on 2020-09-09.
//  Copyright © 2020 Leblanc, Ghislain. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationWeatherViewModel {
    var city: String
    var temp: String
    var humidity: String
    var lat: CLLocationDegrees
    var long: CLLocationDegrees
}
