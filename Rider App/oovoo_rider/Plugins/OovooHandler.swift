//
//  OovooHandler.swift
//  oovoo_rider
//
//  Created by Ayman Zeine on 6/30/18.
//  Copyright © 2018 Ayman Zeine. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol OovooController: class {
    
    func canCallOoovoo(delegateCalled: Bool)
    func javerAcceptedRequest(requestAccepted: Bool, javerName: String)
    func updateJaverLocation(lat: Double, long: Double)
}

class OovooHandler {
    private static let _instance = OovooHandler()
    
    weak var delegate: OovooController?
    
    var rider = ""
    var javer = ""
    var rider_id = ""
    
    static var Instance: OovooHandler {
        return _instance
    }
    
    func observeMessagesForRider(){
        //rider requested oovoo
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.rider_id = snapshot.key
                        self.delegate?.canCallOoovoo(delegateCalled: true)
                    }
                }
            }
        }
        
        //rider cancelled oovoo
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.rider_id = snapshot.key
                        self.delegate?.canCallOoovoo(delegateCalled: false)
                    }
                }
            }
        }
        
        //javer has accepted the oovoo
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if self.javer == "" {
                        self.javer = name //adding driver name to var in db
                        self.delegate?.javerAcceptedRequest(requestAccepted: true, javerName: self.javer)
                    }
                }
            }
        }
        
        //javer cancelled the request
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) {(snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.javer {
                        self.javer = ""
                        self.delegate?.javerAcceptedRequest(requestAccepted: false, javerName: name)
                    }
                }
            }
        }
        
        //javer updating location
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childChanged) {(snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.javer {
                        if let lat = data[Constants.LATITUDE] as? Double {
                            if let long = data[Constants.LONGITUDE] as? Double {
                                self.delegate?.updateJaverLocation(lat: lat, long: long)
                            }
                        }
                    }
                }
            }
        }
        
    }

    
    func requestOovoo(latitude: Double, longitude: Double) {
        let data: Dictionary<String, Any> = [Constants.NAME: rider, Constants.LATITUDE: latitude, Constants.LONGITUDE: longitude]
        
        DBProvider.Instance.requestRef.childByAutoId().setValue(data)
    } //request oovoo
    
    func cancelOovoo(){
        DBProvider.Instance.requestRef.child(rider_id).removeValue()
    }
    
    func updateRiderLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestRef.child(rider_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long])
    }
    
} //singleton class
