//
//  GPSTracker.swift
//
//  Created by jieyi on 9/25/2016 AD.
//  Copyright © Jieyi. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

// MARK: Variable

class GPSTracker: NSObject {
    // MARK: Static Variable

    private static let sharedInstance: CLLocationManager = CLLocationManager()
    static var isStarting: Bool = false

    // MARK: Private Variable

    private var collectionTimes: Int = 0
    private var paramsLocations: [[String:AnyObject]] = []

    private var preference: Preferences?
    private var locationManager: CLLocationManager = GPSTracker.sharedInstance

    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationEnterBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
}

// MARK: - GPS location manager listener

extension GPSTracker: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locations count:", locations.count, "current count:", self.collectionTimes, "timestamp:", manager.location!.timestamp.timeIntervalSince1970, "latitude:", manager.location!.coordinate.latitude, "longitude:", manager.location!.coordinate.longitude)

        for location in locations {
            let theLocation = location.coordinate
            let theAccuracy = location.horizontalAccuracy
            let age = -location.timestamp.timeIntervalSinceNow

            if age > 30 {
                continue
            }

            // Select only valid location and also location with good accuracy.
            if theAccuracy > 0 && theAccuracy < 2000 && (!(theLocation.latitude == 0 && theLocation.longitude == 0)) {
                self.paramsLocations.append([
                        "latitude": theLocation.latitude,
                        "longitude": theLocation.longitude,
                        "accuracy": theAccuracy.horizontalAccuracy,
                        "time": location.timestamp.timestamp.timeIntervalSince1970,
                ])
            }
        }
    }
}

// MARK: - Public Method

extension GPSTracker {

    internal func initSetting() {
        // GPS setting
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = CLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()

        self.preference = Preferences()
    }

    internal func startUpdate() -> Void {
        if GPSTracker.isStarting {
            print("Gps has already started...")
        }
        else {
            GPSTracker.isStarting = true
            self.locationManager.startUpdatingLocation()
        }
    }

    internal func stopUpdate() -> Void {
        if GPSTracker.isStarting {
            self.locationManager.stopUpdatingLocation()
            print("Gps stop scaning now...")
            GPSTracker.isStarting = false
        }
        else {
            print("Gps has already stopped...")
        }

    }
}

// MARK: - Private Method

extension GPSTracker {
    @objc private func applicationEnterBackground() {
        print("------ applicationEnterBackground ------")
        self.initSetting()
        self.startUpdate()

        // Use the BackgroundTaskManager to manage all the background Task
        let shareMemory: ShareMemory = ShareMemory.getInstance
        shareMemory.bgTask = BackgroundTaskManager.getInstance
        shareMemory.bgTask?.beginNewBackgroundTask()
    }

    private func restartLocationUpdates() {
        print("------ restartLocationUpdates ------")
        let shareMemory: ShareMemory = ShareMemory.getInstance
        if nil != shareMemory.timer {
            shareMemory.timer!.invalidate()
            shareMemory.timer = nil
        }

        self.initSetting()
        self.startUpdate()
    }

    private func stopLocationTracking() {
        print("------ stopLocationTracking ------")
        let shareMemory: ShareMemory = ShareMemory.getInstance
        if nil != shareMemory.timer {
            shareMemory.timer!.invalidate()
            shareMemory.timer = nil
        }


        self.initSetting()
        self.stopUpdate()
    }
}
