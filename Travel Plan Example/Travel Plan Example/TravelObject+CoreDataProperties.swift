//
//  TravelObject+CoreDataProperties.swift
//  Travel Plan Example
//
//  Created by Bartosz Dudar on 24.10.2016.
//  Copyright © 2016 Bartosz Dudar. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TravelObject {

    @NSManaged var arrivalTimeString: String?
    @NSManaged var departureTimeString: String?
    @NSManaged var identifier: NSNumber?
    @NSManaged var stopsCount: NSNumber?
    @NSManaged var logoURL: String?
    @NSManaged var price: String?
    @NSManaged var type: NSNumber?
    @NSManaged var logoImageData: NSData?

}
