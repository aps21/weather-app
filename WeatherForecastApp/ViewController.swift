//
//  ViewController.swift
//  WeatherForecast
//
//  Created by Tatyana Tepaeva on 12.10.17.
//  Copyright © 2017 Tatyana Tepaeva. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import Kingfisher

class ViewController: UIViewController {
  var viewModel: ViewModel!
  let disposeBag = DisposeBag()

  @IBOutlet weak var degreesLabel: UILabel!
  @IBOutlet weak var cityNameLabel: UILabel!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var imageView: UIImageView!
  var locationService = LocationService.instance

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    setup()
  }

  func setup() {
    viewModel = ViewModel(location: locationService.location)
    self.viewModel.cityName
      .bind(to: self.cityNameLabel.rx.text)
      .disposed(by: self.disposeBag)
    self.viewModel.degreesValue
      .bind(to: self.degreesLabel.rx.text)
      .disposed(by: self.disposeBag)
    self.viewModel.loading.asObservable()
      .bind(to: self.activityIndicator.rx.isAnimating)
      .disposed(by: self.disposeBag)
    self.viewModel.imageURL
      .subscribe { observableUrl in
        let url = URL(string: observableUrl.element!)
        self.imageView.kf.setImage(with: url)
        return
      }
      .disposed(by: self.disposeBag)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
