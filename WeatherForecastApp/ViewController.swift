//
//  ViewController.swift
//  WeatherForecastApp
//
//  Created by Tatyana Tepaeva on 18.10.17.
//  Copyright © 2017 Tatyana Tepaeva. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    print("Start!")

    LocationService.instance.authorized.asObservable()
      .subscribe(onNext: { authorized in print(authorized) })
      .disposed(by: disposeBag)

    let location = LocationService.instance.location.asObservable().share()
    location
      .subscribe(onNext: { location in print(location) })
      .disposed(by: disposeBag)

    let geoCoderService = GeoCoderService()
    let city = location
      .flatMapLatest { geoCoderService.getCityName($0) }
      .share()
    city
      .subscribe(onNext: { city in print(city) })
      .disposed(by: disposeBag)
    
    city
      .flatMapLatest { OpenWeatherMapService().retriveWeatherInfo($0) }
      .subscribe(onNext: { weather in print(weather.toJSON()) })
      .disposed(by: disposeBag)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
