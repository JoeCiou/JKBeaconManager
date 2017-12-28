//
//  JKBeaconManagerDelegate.swift
//
//  Created by Joe on 2017/12/27.
//  Copyright © 2017年 starwing. All rights reserved.
//

import UIKit

@objc public protocol JKBeaconManagerDelegate{
    @objc optional func beaconManager(_ manager: JKBeaconManager, didDetermineState state: JKRegionState)
    @objc optional func beaconManager(_ manager: JKBeaconManager, didRangeBeacons beacons: [JKBeacon])
    @objc optional func beaconManager(_ manager: JKBeaconManager, didUpdateNearestBeacon beacon: JKBeacon?)
    @objc optional func beaconManager(_ manager: JKBeaconManager, didChangeAuthorization status: JKBeaconManagerAuthorizationStatus)
    @objc optional func beaconManager(_ manager: JKBeaconManager, didUpdateBluetoothState state: JKBluetoothState)
}
