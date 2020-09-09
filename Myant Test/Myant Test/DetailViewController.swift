//
//  DetailViewController.swift
//  Myant Test
//
//  Created by Ghislain Leblanc on 2020-09-09.
//  Copyright © 2020 Leblanc, Ghislain. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = "City: \(detail.city)\nTemp: \(detail.temp)K\nHumidity: \(detail.humidity)\nPressure: \(detail.pressure)\nSea level pressure: \(detail.seaLevel)"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var detailItem: LocationWeatherViewModel? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

