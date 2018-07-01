//
//  DBProvider.swift
//  oovoo_rider
//
//  Created by Ayman Zeine on 6/29/18.
//  Copyright © 2018 Ayman Zeine. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    
    private static let _instance = DBProvider()
    
    static var Instance: DBProvider {
        return _instance
    }
    
    //reference to database
    var dbRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var javersRef: DatabaseReference {
        return dbRef.child(Constants.JAVERS)
    }
    
    //request reference
    var requestRef: DatabaseReference {
        return dbRef.child(Constants.OOVOO_REQUEST)
    }
    
    //request accepted
    var requestAcceptedRef: DatabaseReference {
        return dbRef.child(Constants.OOVOO_ACCEPTED)
    }
    
    func saveUser(withID: String, email: String, password: String) {
        let data: Dictionary<String, Any> = [Constants.EMAIL:email, Constants.PASSWORD:password, Constants.IS_RIDER: false]
        
        //will send a query for a child with parents -> riders
        //will create entry if not found
        javersRef.child(withID).child(Constants.DATA).setValue(data)
    }
    
    
} //singleton class
