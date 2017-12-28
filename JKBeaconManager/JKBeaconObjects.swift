//
//  JKBeaconObjects.swift
//
//  Created by Joe on 2017/12/27.
//  Copyright © 2017年 starwing. All rights reserved.
//

import UIKit
import CoreLocation

public enum JKBeaconManagerAuthorizationRequestType: Int{
    case always
    case whenInUse
}

@objc public enum JKBeaconManagerAuthorizationStatus: Int{
    case notDetermined
    case restricted
    case denied
    case authorizedAlways
    case authorizedWhenInUse
    
    init(status: CLAuthorizationStatus){
        switch status {
        case .notDetermined:
            self = .notDetermined
        case .restricted:
            self = .restricted
        case .denied:
            self = .denied
        case .authorizedAlways:
            self = .authorizedAlways
        case .authorizedWhenInUse:
            self = .authorizedWhenInUse
        }
    }
    
}

@objc public enum JKBluetoothState: Int{
    case on
    case off
}

@objc public enum JKRegionState: Int{
    case unknown
    case inside
    case outside
    
    init(state: CLRegionState){
        switch state {
        case .unknown:
            self = .unknown
        case .inside:
            self = .inside
        case .outside:
            self = .outside
        }
    }
}

public enum JKProximity: Int{
    case immediate
    case near
    case far
    case unknown
    
    init(proximity: CLProximity){
        switch proximity {
        case .unknown:
            self = .unknown
        case .immediate:
            self = .immediate
        case .near:
            self = .near
        case .far:
            self = .far
        }
    }
}

public class JKBeaconKey: NSObject{
    public let proximityUUID: UUID
    public let major: NSNumber
    public let minor: NSNumber
    
    public init(proximityUUID: UUID, major: NSNumber, minor: NSNumber){
        self.proximityUUID = proximityUUID
        self.major = major
        self.minor = minor
        super.init()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? JKBeaconKey else{
            return false
        }
        return self == object
    }
}

func ==(lhs: JKBeaconKey, rhs: JKBeaconKey) -> Bool{
    return lhs.proximityUUID == rhs.proximityUUID && lhs.major == rhs.major && lhs.minor == rhs.minor
}

func !=(lhs: JKBeaconKey, rhs: JKBeaconKey) -> Bool{
    return lhs.proximityUUID != rhs.proximityUUID || lhs.major != rhs.major || lhs.minor != rhs.minor
}

public class JKBeaconProximityKey: JKBeaconKey {
    public let proximity: JKProximity
    
    public init(proximityUUID: UUID, major: NSNumber, minor: NSNumber, proximity: JKProximity){
        self.proximity = proximity
        super.init(proximityUUID: proximityUUID, major: major, minor: minor)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? JKBeaconProximityKey else{
            return false
        }
        return self == object
    }
}

public func ==(lhs: JKBeaconProximityKey, rhs: JKBeaconProximityKey) -> Bool{
    return lhs.proximityUUID == rhs.proximityUUID && lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.proximity == rhs.proximity
}

public func !=(lhs: JKBeaconProximityKey, rhs: JKBeaconProximityKey) -> Bool{
    return lhs.proximityUUID != rhs.proximityUUID || lhs.major != rhs.major || lhs.minor != rhs.minor || lhs.proximity != rhs.proximity
}

public class JKBeacon: JKBeaconKey {
    public var proximity: JKProximity
    public var rssi: Int
    public var accuracy: Double
    
    init(beaconKey: JKBeaconKey, proximity: JKProximity, rssi: Int, accuracy: Double){
        self.proximity = proximity
        self.rssi = rssi
        self.accuracy = accuracy
        super.init(proximityUUID: beaconKey.proximityUUID, major: beaconKey.major, minor: beaconKey.minor)
    }
    
    convenience init(beacon: CLBeacon){
        let beaconKey = JKBeaconKey(proximityUUID: beacon.proximityUUID, major: beacon.major, minor: beacon.minor)
        self.init(beaconKey: beaconKey,
                  proximity: JKProximity(proximity: beacon.proximity),
                  rssi: beacon.rssi,
                  accuracy: beacon.accuracy)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? JKBeacon else{
            return false
        }
        return self == object
    }
}
