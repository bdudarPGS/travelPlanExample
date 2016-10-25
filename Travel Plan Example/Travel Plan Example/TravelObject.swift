//
//  TravelObject.swift
//  Travel Plan Example
//
//  Created by Bartosz Dudar on 24.10.2016.
//  Copyright © 2016 Bartosz Dudar. All rights reserved.
//

import Foundation
import CoreData

@objc(TravelObjectType)
enum TravelObjectType: Int {
    case Train
    case Flight
    case Bus
}

@objc(TravelObject)
class TravelObject: NSManagedObject {
    
    static let UnavailabelDuration: NSTimeInterval = -1
    
    //MARK:- JSON Mapping
    
    static func fromJson(dictionary: [String: AnyObject], inContext context: NSManagedObjectContext) -> TravelObject? {
        
        guard let identifier = dictionary["id"] as? Int,
            logoURL = dictionary["provider_logo"] as? String,
            arrivalTime = dictionary["arrival_time"] as? String,
            departureTime = dictionary["departure_time"] as? String,
            stopsCount = dictionary["number_of_stops"] as? Int else {
                return nil
        }
        
        let newObject = NSEntityDescription.insertNewObjectForEntityForName("TravelObject", inManagedObjectContext: context) as! TravelObject
        
        newObject.arrivalTimeString = arrivalTime
        newObject.departureTimeString = departureTime
        newObject.identifier = identifier
        newObject.stopsCount = stopsCount
        newObject.logoURL = logoURL.stringByReplacingOccurrencesOfString("{size}", withString: "63")
        
        let priceString: String
        
        if let priceFromJson = dictionary["price_in_euros"] as? String {
            priceString = priceFromJson
        } else if let priceFromJson = dictionary["price_in_euros"] as? Double {
            priceString = String(format: "%.2f", priceFromJson)
        } else {
            priceString = "N/A"
        }
        
        newObject.price = priceString
        
        return newObject
    }
    
    //MARK:- Travel duration methods

    var travelDuration: NSTimeInterval {
        
        guard let arrivalTimeString = arrivalTimeString,
            departureTimeString = departureTimeString,
            departureTime = timeStringToInterval(departureTimeString),
            var arrivalTime = timeStringToInterval(arrivalTimeString) else {
            return TravelObject.UnavailabelDuration
        }
        
        if arrivalTime < departureTime {
            arrivalTime = arrivalTime + (24 * 60 * 60)
        }
        
        return arrivalTime - departureTime
    }
    
    var travelDurationString: String {
        
        let travelDuration = self.travelDuration
        
        guard travelDuration != TravelObject.UnavailabelDuration else {
            return "N/A"
        }
        
        let hourValue = travelDuration / (60 * 60)
        let minuteValue = (travelDuration % (60 * 60)) / 60
        
        return "\(Int(hourValue))h \(Int(minuteValue))m"
    }
    
    var departureTime: NSTimeInterval {
        
        guard let departureTimeString = departureTimeString, interval = timeStringToInterval(departureTimeString)else {
            return TravelObject.UnavailabelDuration
        }
        
        return interval
    }

    private func timeStringToInterval(durationString: String) -> NSTimeInterval? {
        
        let timeStringComponents = durationString.componentsSeparatedByString(":")
        
        guard timeStringComponents.count == 2 else {
            return nil
        }
        
        guard let hourValue = Double(timeStringComponents[0]), minuteValue = Double(timeStringComponents[1]) else {
            return nil
        }
        
        return 60 * 60 * hourValue + 60 * minuteValue
    }
}
