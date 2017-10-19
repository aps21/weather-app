//
//  ViewModel.swift
//  WeatherForecast
//
//  Created by Tatyana Tepaeva on 12.10.17.
//  Copyright © 2017 Tatyana Tepaeva. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import AlamofireObjectMapper
import CoreLocation

class ViewModel {
  private struct Constants {
    static let URLPrefix = "https://api.openweathermap.org/"
    static let URLImagePart = "img/w/"
    static let updateFrequency = 300.0 // 5 minutes
  }

  var location: Observable<CLLocation>
  var lastCityName = ""
  var cityName = Observable<String>.empty()
  var degreesValue = Observable<String>.empty()
  var timestamp = Observable<Double>.empty()
  var imageURL = Observable<String>.empty()
  var loading = Variable<Bool>(false)
  var dataIsNil = Variable<Bool>(true)
  var weatherService = OpenWeatherMapService()
  var geoCoderService = GeoCoderService()

  init(location: Driver<CLLocation>) {
    self.location = location.asObservable()
    setup()
  }

  func setup() {
    self.cityName = self.location
      .flatMapLatest { self.geoCoderService.getCityName($0) }
      .do(onNext: { self.lastCityName = $0 })
      .distinctUntilChanged()
      .share()

    let scheduler = Observable<Int>.interval(Constants.updateFrequency, scheduler: MainScheduler.instance)
      .map { _ in self.lastCityName }
      .filter { !$0.isEmpty }

    let weather = Observable.of(self.cityName, scheduler)
      .merge()
      .do(onNext: { _ in
        self.dataIsNil.value = false
        self.loading.value = true
      })
      .flatMapLatest { self.weatherService.retriveWeatherInfo($0) }
      .do(onNext: { _ in self.loading.value = false })
      .share()

    self.degreesValue = weather.map { self.formattedDegrees($0.degrees!) }
    self.timestamp = weather.map { $0.timestamp! }
    self.imageURL = weather.map { self.formattedImageURL($0.imageID!) }
  }

  func formattedImageURL(_ imageID: String) -> String {
    return Constants.URLPrefix + Constants.URLImagePart + imageID
  }

  func formattedDegrees (_ degrees: Double) -> String {
    return String(describing: Int((degrees.rounded())))
  }
}
