//
//  CLLocationManager+Rx.swift
//  RxExample
//
//  Created by Carlos García on 8/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import CoreLocation
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif

extension Reactive where Base: CLLocationManager {

  /**
   Reactive wrapper for `delegate`.
   
   For more information take a look at `DelegateProxyType` protocol documentation.
   */
  public var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
    return RxCLLocationManagerDelegateProxy.proxy(for: base)
  }

  // MARK: Responding to Location Events

  /**
   Reactive wrapper for `delegate` message.
   */
  public var didUpdateLocations: Observable<[CLLocation]> {
    return RxCLLocationManagerDelegateProxy.proxy(for: base).didUpdateLocationsSubject.asObservable()
  }

  /**
   Reactive wrapper for `delegate` message.
   */
  public var didFailWithError: Observable<Error> {
    return RxCLLocationManagerDelegateProxy.proxy(for: base).didFailWithErrorSubject.asObservable()
  }

  #if os(iOS) || os(macOS)
  /**
   Reactive wrapper for `delegate` message.
   */
  public var didFinishDeferredUpdatesWithError: Observable<Error?> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate
      .locationManager(_:didFinishDeferredUpdatesWithError:)))
      .map { value in
        return try castOptionalOrThrow(Error.self, value[1])
    }
  }
  #endif

  #if os(iOS)

  // MARK: Pausing Location Updates

  /**
   Reactive wrapper for `delegate` message.
   */
  public var didPauseLocationUpdates: Observable<Void> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManagerDidPauseLocationUpdates(_:)))
      .map { _ in
        return ()
    }
  }

  /**
   Reactive wrapper for `delegate` message.
   */
  public var didResumeLocationUpdates: Observable<Void> {
    return delegate.methodInvoked( #selector(CLLocationManagerDelegate.locationManagerDidResumeLocationUpdates(_:)))
      .map { _ in
        return ()
    }
  }

  // MARK: Responding to Heading Events

  /**
   Reactive wrapper for `delegate` message.
   */
  public var didUpdateHeading: Observable<CLHeading> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateHeading:)))
      .map { value in
        return try castOrThrow(CLHeading.self, value[1])
    }
  }

  // MARK: Responding to Region Events

  /**
   Reactive wrapper for `delegate` message.
   */
  public var didEnterRegion: Observable<CLRegion> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didEnterRegion:)))
      .map { value in
        return try castOrThrow(CLRegion.self, value[1])
    }
  }

  /**
   Reactive wrapper for `delegate` message.
   */
  public var didExitRegion: Observable<CLRegion> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didExitRegion:)))
      .map { value in
        return try castOrThrow(CLRegion.self, value[1])
    }
  }

  #endif

  #if os(iOS) || os(macOS)

  /**
   Reactive wrapper for `delegate` message.
   */
  @available(OSX 10.10, *)
  public var didDetermineStateForRegion: Observable<(state: CLRegionState, region: CLRegion)> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didDetermineState:for:)))
      .map { value in
        let stateNumber = try castOrThrow(NSNumber.self, value[1])
        let state = CLRegionState(rawValue: stateNumber.intValue) ?? CLRegionState.unknown
        let region = try castOrThrow(CLRegion.self, value[2])
        return (state: state, region: region)
    }
  }

  /**
   Reactive wrapper for `delegate` message.
   */
  public var monitoringDidFailForRegionWithError: Observable<(region: CLRegion?, error: Error)> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate
      .locationManager(_:monitoringDidFailFor:withError:)))
      .map { value in
        let region = try castOptionalOrThrow(CLRegion.self, value[1])
        let error = try castOrThrow(Error.self, value[2])
        return (region: region, error: error)
    }
  }

  /**
   Reactive wrapper for `delegate` message.
   */
  public var didStartMonitoringForRegion: Observable<CLRegion> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didStartMonitoringFor:)))
      .map { value in
        return try castOrThrow(CLRegion.self, value[1])
    }
  }

  #endif

  #if os(iOS)

  // MARK: Responding to Ranging Events

  /**
   Reactive wrapper for `delegate` message.
   */
  public var didRangeBeaconsInRegion: Observable<(beacons: [CLBeacon], region: CLBeaconRegion)> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didRangeBeacons:in:)))
      .map { value in
        let beacons = try castOrThrow([CLBeacon].self, value[1])
        let region = try castOrThrow(CLBeaconRegion.self, value[2])
        return (beacons: beacons, region: region)
    }
  }

  /**
   Reactive wrapper for `delegate` message.
   */
  public var rangingBeaconsDidFailForRegionWithError: Observable<(region: CLBeaconRegion, error: Error)> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate
      .locationManager(_:rangingBeaconsDidFailFor:withError:)))
      .map { value in
        let region = try castOrThrow(CLBeaconRegion.self, value[1])
        let error = try castOrThrow(Error.self, value[2])
        return (region: region, error: error)
    }
  }

  // MARK: Responding to Visit Events

  /**
   Reactive wrapper for `delegate` message.
   */
  @available(iOS 8.0, *)
  public var didVisit: Observable<CLVisit> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didVisit:)))
      .map { value in
        return try castOrThrow(CLVisit.self, value[1])
    }
  }

  #endif

  // MARK: Responding to Authorization Changes

  /**
   Reactive wrapper for `delegate` message.
   */
  public var didChangeAuthorizationStatus: Observable<CLAuthorizationStatus> {
    return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:)))
      .map { value in
        let number = try castOrThrow(NSNumber.self, value[1])
        return CLAuthorizationStatus(rawValue: Int32(number.intValue)) ?? .notDetermined
    }
  }
}

private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
  guard let returnValue = object as? T else {
    throw RxCocoaError.castingError(object: object, targetType: resultType)
  }

  return returnValue
}

private func castOptionalOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T? {
  if NSNull().isEqual(object) {
    return nil
  }

  guard let returnValue = object as? T else {
    throw RxCocoaError.castingError(object: object, targetType: resultType)
  }

  return returnValue
}
