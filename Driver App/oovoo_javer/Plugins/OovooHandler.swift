//
//  OovooHandler.swift
//  oovoo_javer
//
//  Created by Ayman Zeine on 6/30/18.
//  Copyright © 2018 Ayman Zeine. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol OovooController: class {
    func acceptOovoo(lat: Double, long: Double)
    func riderCancelledOovoo()
    func javerCancelledOovoo()
    func updateRiderLocation(lat: Double, long: Double)
}

class OovooHandler {
    private static let _instance = OovooHandler()
    
    weak var delegate: OovooController? //var will not be instantiated until it is needed
    
    var rider = ""
    var javer = ""
    var javer_id = ""
    
    static var Instance: OovooHandler {
        return _instance
    }
    
    func observeRequestsForJaver() {
        
        //rider requested oovoo
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        self.delegate?.acceptOovoo(lat: latitude, long: longitude)
                    }
                }
                if let name = data[Constants.NAME] as? String {
                    self.rider = name
                }
            }
            
            //rider cancelled oovoo
            DBProvider.Instance.requestRef.observe(DataEventType.childRemoved, with: { (snapshot: DataSnapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.rider {
                            self.delegate?.riderCancelledOovoo()
                        }
                    }
                }
            })
        }
        
        //javer accepted oovoo
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.javer {
                        self.javer_id = snapshot.key
                    }
                }
            }
        }
        
        //javer cancelled oovoo
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.javer {
                        self.delegate?.javerCancelledOovoo()
                    }
                }
            }
        }
        
        //rider updating location
        DBProvider.Instance.requestRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let lat = data[Constants.LATITUDE] as? Double {
                    if let long = data[Constants.LONGITUDE] as? Double{
                        self.delegate?.updateRiderLocation(lat: lat, long: long)
                    }
                }
            }
        }
        
    } //request listener
    
    func oovooAccepted(lat: Double, long: Double) {
        let data: Dictionary<String, Any> = [Constants.NAME: javer, Constants.LATITUDE: lat, Constants.LONGITUDE: long]
        
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data)
    }
    
    func cancelOovooForJaver(){
        DBProvider.Instance.requestAcceptedRef.child(javer_id).removeValue()
    }
    
    func updateJaverLocation(lat: Double, long: Double){
        DBProvider.Instance.requestAcceptedRef.child(javer_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE:long])
    }
}
