//
//  Weather.swift
//  WeatherForecast
//
//  Created by Tatyana Tepaeva on 12.10.17.
//  Copyright © 2017 Tatyana Tepaeva. All rights reserved.
//

import UIKit
import ObjectMapper

class Weather: Mappable {
  var cityName: String?
  var degrees: Double?
  var timestamp: Double?
  var imageID: String?

  required init?(map: Map) {
  }

  func mapping(map: Map) {
    self.cityName <- map["name"]
    self.degrees <- map["main.temp"]
    self.timestamp <- map["dt"]
    self.imageID <- map ["weather.0.icon"]
  }
}
