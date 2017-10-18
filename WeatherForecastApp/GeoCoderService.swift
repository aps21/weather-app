//
//  GeoCoderService.swift
//  WeatherForecast
//
//  Created by Tatyana Tepaeva on 17.10.17.
//  Copyright © 2017 Tatyana Tepaeva. All rights reserved.
//

import RxSwift
import CoreLocation

struct GeoCoderService {
  var geocoder = CLGeocoder()

  public func getCityName (_ location: CLLocation ) -> Observable<String> {
    return reverseLocation(location).map { $0.locality! }
  }

  private func reverseLocation (_ location: CLLocation ) -> Observable<CLPlacemark> {
    return Observable.create { observer in
      self.geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
        if placemarks != nil {
          let firstLocation = placemarks![0]
          observer.on(.next(firstLocation))
          observer.on(.completed)
        } else if error != nil {
          observer.on(.error(error!))
        } else {
          observer.on(.error(RxError.unknown))
        }
      })
      return Disposables.create {  }
    }
  }
}
