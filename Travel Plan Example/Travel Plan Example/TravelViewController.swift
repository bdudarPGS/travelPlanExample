//
//  TravelCollectionViewController.swift
//  Travel Plan Example
//
//  Created by Bartosz Dudar on 24.10.2016.
//  Copyright © 2016 Bartosz Dudar. All rights reserved.
//

import UIKit
import CoreData


class TravelViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var loadingIndicator: UIView!
    
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sortingSegmentedControl: UISegmentedControl!
    
    private var chosenTravelObjectType: TravelObjectType = .Train
    private var currentTravelObjects = [TravelObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch chosenTravelObjectType {
        case .Train:
            APIManager.sharedInstance().getTrainObjects()
        case .Bus:
            APIManager.sharedInstance().getBusObjects()
        case .Flight:
            APIManager.sharedInstance().getFlightObjects()
        }
        
        refreshData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TravelViewController.refreshBusData), name: APIBusDataUpdatedNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TravelViewController.refreshTrainData), name: APITrainDataUpdatedNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TravelViewController.refreshFlightData), name: APIFlightDataUpdatedNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TravelViewController.refreshLogoImage), name: APILogoImageUpdatedNotificationName, object: nil)
    }
    
    //MARK:- Refreshing data

    func refreshDataForType(type: TravelObjectType) {
        
        guard chosenTravelObjectType == type else {
            return
        }
        
        let currentlyLoading: Bool
        
        switch type {
        case .Bus:
            currentlyLoading = APIManager.sharedInstance().isUpdatingBuses()
        case .Flight:
            currentlyLoading = APIManager.sharedInstance().isUpdatingFlights()
        case .Train:
            currentlyLoading = APIManager.sharedInstance().isUpdatingTrains()
        }
        
        guard !currentlyLoading else {
            showLoadingIndicator()
            return
        }
        
        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, context = appDelegate.managedObjectContext else {
            return
        }
        
        let request = NSFetchRequest(entityName: "TravelObject")
        request.predicate = NSPredicate(format: "type = %d", chosenTravelObjectType.rawValue)
        
        guard let results = (try? context.executeFetchRequest(request)) as? [TravelObject] else {
            return
        }
        
        let sortedResults: [TravelObject]
        
        if sortingSegmentedControl.selectedSegmentIndex == 1 {
            
            sortedResults = results.sort { $0.travelDuration < $1.travelDuration }
        } else {
            sortedResults = results.sort { $0.departureTime < $1.departureTime }
        }

        currentTravelObjects.removeAll()
        currentTravelObjects.appendContentsOf(sortedResults)

        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView.reloadData()
        }
        hideLoadingIndicator(showEmpty: currentTravelObjects.count == 0)
    }
    
    func refreshData() {
        refreshDataForType(chosenTravelObjectType)
    }
    
    func refreshBusData() {
        refreshDataForType(.Bus)
    }
    
    func refreshTrainData() {
        refreshDataForType(.Train)
    }
    
    func refreshFlightData() {
        refreshDataForType(.Flight)
    }
    
    func refreshLogoImage(notification: NSNotification) {
        
        guard let travelObject = notification.object as? TravelObject, index = currentTravelObjects.indexOf(travelObject) else {
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
        }
    }
    
    //MARK:- Loading state animations
    
    private func showLoadingIndicator() {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.loadingIndicator.hidden = false
            //
            self.collectionView.hidden = true
            self.emptyView.hidden = true

            //
//            UIView.animateWithDuration(0.2, animations: {
//                self.collectionView.alpha = 0
//                self.emptyView.alpha = 0
//                self.loadingIndicator.alpha = 1
//                }, completion: { finished in
//                    self.collectionView.hidden = true
//                    self.emptyView.hidden = true
//            })
        }
    }
    
    private func hideLoadingIndicator(showEmpty showEmpty: Bool) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let viewToShow = showEmpty ? self.emptyView : self.collectionView
            let viewToHide = showEmpty ? self.collectionView : self.emptyView
            
            viewToShow.hidden = false
            //
            self.loadingIndicator.hidden = true
            viewToHide.hidden = true

            //
//            UIView.animateWithDuration(0.2, animations: {
//                self.loadingIndicator.alpha = 0
//                viewToHide.alpha = 0
//                viewToShow.alpha = 1
//                }, completion: { finished in
//                    self.loadingIndicator.hidden = true
//                    viewToHide.hidden = true
//            })
        }
    }
    
    //MARK:- Actions
    
    @IBAction func sortValueChanged() {
        refreshData()
    }
    
    @IBAction func modeValueChanged() {
        
        if let selectedType = TravelObjectType(rawValue: modeSegmentedControl.selectedSegmentIndex) {
            chosenTravelObjectType = selectedType
        } else {
            chosenTravelObjectType = .Flight
        }
        
        switch chosenTravelObjectType {
        case .Flight:
            APIManager.sharedInstance().getFlightObjects()
        case .Bus:
            APIManager.sharedInstance().getBusObjects()
        case .Train:
            APIManager.sharedInstance().getTrainObjects();
        }
        
        refreshData()
    }
}

extension TravelViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentTravelObjects.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TravelObjectCell", forIndexPath: indexPath) as? TravelObjectCell else {
            return UICollectionViewCell()
        }
        
        cell.configureForObject(currentTravelObjects[indexPath.row])
        
        return cell
    }
}

extension TravelViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: view.bounds.width - 16, height: 82)
    }
}
