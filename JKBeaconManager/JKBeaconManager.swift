//
//  JKBeaconManager.swift
//
//  Created by Joe on 2017/12/27.
//  Copyright © 2017年 starwing. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

/*
 若有多個beacon region則混合處理
 */
public class JKBeaconManager: NSObject, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    
    public weak var delegate: JKBeaconManagerDelegate?
    public let pusher: JKBeaconPusher = JKBeaconPusher()
    public var regionState: JKRegionState{
        if beaconRegionsState.values.contains(where: { $0 == .unknown}){
            return .unknown
        }else if beaconRegionsState.values.contains(where: { $0 == .inside}){
            return .inside
        }else{
            return .outside
        }
    }
    public var beacons: [JKBeacon]{
        return beaconRegionsBeacons.values.reduce([], { $0 + $1 })
    }
    public var specificBeaconKeys: [JKBeaconKey]? = nil
    
    let locationManager: CLLocationManager = CLLocationManager()
    var peripheralManager: CBPeripheralManager!
    var beaconRegions: [CLBeaconRegion] = []
    var beaconRegionsState: [CLBeaconRegion: JKRegionState] = [:]
    var beaconRegionsBeacons: [CLBeaconRegion: [JKBeacon]] = [:]
    var nearestBeacon: JKBeacon?{
        didSet{
            if oldValue != nearestBeacon{
                delegate?.beaconManager?(self, didUpdateNearestBeacon: nearestBeacon)
            }
        }
    }
    
    public convenience init(beaconUUID: String){
        self.init(beaconUUIDs: [beaconUUID])
    }
    
    public init(beaconUUIDs: [String]){
        for uuid in beaconUUIDs{
            let region = CLBeaconRegion(proximityUUID: UUID(uuidString: uuid)!, identifier: "Beacon\(uuid)")
            region.notifyOnEntry = true
            beaconRegions.append(region)
        }
        super.init()
        
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: false])
    }
    
    public func requestAuthorization(_ authorization: JKBeaconManagerAuthorizationRequestType) {
        if authorization == .always{
            locationManager.requestAlwaysAuthorization()
        }else if authorization == .whenInUse{
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    public func startListen() {
        for region in beaconRegions{
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager.startRangingBeacons(in: region)
            locationManager.startMonitoring(for: region)
        }
    }
    
    public func stopListen() {
        for region in beaconRegions{
            locationManager.stopRangingBeacons(in: region)
            locationManager.stopMonitoring(for: region)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let specificBeaconKeys = specificBeaconKeys{
            beaconRegionsBeacons[region] = beacons.map({ JKBeacon(beacon: $0) }).filter({ specificBeaconKeys.contains($0) })
        }else{
            beaconRegionsBeacons[region] = beacons.map({ JKBeacon(beacon: $0) })
        }
        
        let beacons = self.beacons
        delegate?.beaconManager?(self, didRangeBeacons: beacons)
        pusher.didRangeBeacons(beacons)
        
        if let delegateObject = delegate as? NSObject,
            delegateObject.responds(to: #selector(JKBeaconManagerDelegate.beaconManager(_:didUpdateNearestBeacon:))){
            nearestBeacon = beacons.filter({ $0.rssi != 0 }).max(by: { $0.rssi < $1.rssi })
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        locationManager.requestState(for: region)
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if let region = region as? CLBeaconRegion{
            beaconRegionsState[region] = JKRegionState(state: state)
        }
        delegate?.beaconManager?(self, didDetermineState: regionState)
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.beaconManager?(self, didChangeAuthorization: JKBeaconManagerAuthorizationStatus(status: status))
    }
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        let state: JKBluetoothState = peripheral.state == .poweredOn ? .on: .off
        delegate?.beaconManager?(self, didUpdateBluetoothState: state)
    }
}
