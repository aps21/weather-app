//
//  OpenWeatherMapService.swift
//  WeatherForecast
//
//  Created by Tatyana Tepaeva on 17.10.17.
//  Copyright © 2017 Tatyana Tepaeva. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

struct OpenWeatherMapService {
  private struct Constants {
    static let URLPrefix = "https://api.openweathermap.org/"
    static let URLWeatherPostfix = "&units=metric&appid=af3924e2f36400185c4e185703cddcc2"
    static let URLWeatherPart = "data/2.5/weather?q="
  }

  public func retriveWeatherInfo (_ cityName: String) -> Observable<Weather> {
    return Observable.create { observer in
      let URL = Constants.URLPrefix + Constants.URLWeatherPart +
        cityName.replacingOccurrences(of: " ", with: "") + Constants.URLWeatherPostfix
      let request = Alamofire.request(URL).responseObject { (response: DataResponse<Weather>) in
        switch response.result {
        case .success:
          let weather = response.result.value!
          observer.on(.next(weather))
          observer.on(.completed)
        case .failure(let error):
          observer.on(.error(error))
        }
      }
      return Disposables.create {
        request.cancel()
      }
    }
  }
}
