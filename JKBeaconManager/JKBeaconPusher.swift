//
//  JKBeaconPusher.swift
//
//  Created by Joe on 2017/12/27.
//  Copyright © 2017年 starwing. All rights reserved.
//

import UIKit
import UserNotifications

private let BeaconsNotificationInfoUserDefaultsKey = "beacons_notification_info"
private let BeaconsNotificationHistoryUserDefaultsKey = "beacons_notification_history"

public class JKBeaconPusher: NSObject {
    
    public var pushTimeInterval: TimeInterval = 1800
    
    var notifications = JKBeaconNotificationSerialization.rawData(encodeData: UserDefaults.standard.object(forKey: BeaconsNotificationInfoUserDefaultsKey) as? Data) as? [JKBeaconProximityKey: String]{
        didSet{
            if let data = JKBeaconNotificationSerialization.encodeData(rawData: notifications){
                UserDefaults.standard.set(data, forKey: BeaconsNotificationInfoUserDefaultsKey)
            }
        }
    }
    
    var notificationsHistory = JKBeaconNotificationSerialization.rawData(encodeData: UserDefaults.standard.object(forKey: BeaconsNotificationHistoryUserDefaultsKey) as? Data) as? [JKBeaconProximityKey: Date]{
        didSet{
            if let data = JKBeaconNotificationSerialization.encodeData(rawData: notificationsHistory){
                UserDefaults.standard.set(data, forKey: BeaconsNotificationHistoryUserDefaultsKey)
            }
        }
    }
    
    override init(){
        super.init()
    }
    
    public func requestAuthorization(options: UNAuthorizationOptions = [.alert, .badge, .sound]){
        UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: {_, _ in })
    }
    
    public func registerNotifications(_ notifications: [JKBeaconProximityKey: String]){
        self.notifications = notifications
    }
    
    func didRangeBeacons(_ beacons: [JKBeacon]){
        if let notifications = notifications{
            var _notificationsHistory: [JKBeaconProximityKey: Date] = [:]
            if let notificationsHistory = notificationsHistory{
                _notificationsHistory = notificationsHistory
            }
            
            for beacon in beacons{
                if beacon.proximity == .unknown{
                    continue
                }
                let key = JKBeaconProximityKey(proximityUUID: beacon.proximityUUID,
                                               major: beacon.major,
                                               minor: beacon.minor,
                                               proximity: beacon.proximity)
                if let message = notifications[key]{
                    let currentDate = Date()
                    var needPush = true
                    
                    if let history = _notificationsHistory[key],
                        currentDate.timeIntervalSince1970 - history.timeIntervalSince1970 < pushTimeInterval{
                        needPush = false
                    }
                    if needPush{
                        let content = UNMutableNotificationContent()
                        content.body = message
                        content.sound = UNNotificationSound.default()
                        
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                        let request = UNNotificationRequest(identifier: "BeaconMessage", content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                        
                        _notificationsHistory[key] = currentDate
                    }
                }
            }
            notificationsHistory = _notificationsHistory
        }
    }
}

public struct JKBeaconNotificationSerialization {
    public static func encodeData(rawData: [JKBeaconProximityKey: String]?) -> Data?{
        if let rawData = rawData{
            var encodeData: [String: String] = [:]
            for (key, value) in rawData{
                let keyString = key.proximityUUID.uuidString + "_" + key.major.stringValue + "_" + key.minor.stringValue + "_" + String(key.proximity.rawValue)
                encodeData[keyString] = value
            }
            return NSKeyedArchiver.archivedData(withRootObject: encodeData)
        }else{
            return nil
        }
    }
    
    public static func encodeData(rawData: [JKBeaconProximityKey: Date]?) -> Data?{
        if let rawData = rawData{
            var encodeData: [String: Date] = [:]
            for (key, value) in rawData{
                let keyString = key.proximityUUID.uuidString + "_" + key.major.stringValue + "_" + key.minor.stringValue + "_" + String(key.proximity.rawValue)
                encodeData[keyString] = value
            }
            return NSKeyedArchiver.archivedData(withRootObject: encodeData)
        }else{
            return nil
        }
    }
    
    public static func rawData(encodeData: Data?) -> [JKBeaconProximityKey: Any]?{
        if let encodeData = encodeData,
            let data = NSKeyedUnarchiver.unarchiveObject(with: encodeData) as? [String: Any]{
            
            var rawData: [JKBeaconProximityKey: Any] = [:]
            for (key, value) in data{
                let keyData = key.components(separatedBy: "_")
                let proximityKey = JKBeaconProximityKey(proximityUUID: UUID(uuidString: keyData[0])!,
                                                        major: NSNumber(value: Int(keyData[1])!),
                                                        minor: NSNumber(value: Int(keyData[2])!),
                                                        proximity: JKProximity(rawValue: Int(keyData[3])!)!)
                rawData[proximityKey] = value
            }
            return rawData
        }else{
            return nil
        }
    }
}
