//
//  LocationService.swift
//  WeatherForecast
//
//  Created by Tatyana Tepaeva on 17.10.17.
//  Copyright © 2017 Tatyana Tepaeva. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

class LocationService {

  static let instance = LocationService()
  private (set) var authorized: Driver<Bool>
  private (set) var location: Driver<CLLocation>

  private let locationManager = CLLocationManager()

  private init() {
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer

    authorized = Observable.deferred { [weak locationManager] in
      let status = CLLocationManager.authorizationStatus()
      guard let locationManager = locationManager else {
        return Observable.just(status)
      }
      return locationManager
        .rx.didChangeAuthorizationStatus
        .startWith(status)
      }
      .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
      .map {
        switch $0 {
        case .authorizedWhenInUse:
          return true
        default:
          return false
        }
    }

    location = locationManager.rx.didUpdateLocations
      .asDriver(onErrorJustReturn: [])
      .flatMap {
        return $0.last.map(Driver.just) ?? Driver.empty()
    }

    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
}
