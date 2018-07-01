//
//  RiderVC.swift
//  oovoo_rider
//
//  Created by Ayman Zeine on 6/29/18.
//  Copyright © 2018 Ayman Zeine. All rights reserved.
//

import UIKit
import MapKit

class RiderVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, OovooController {
    
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var callOovooBtn: UIButton!
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var javerLocation: CLLocationCoordinate2D?
    
    private var timer = Timer()
    
    private var canCallOovoo = true
    private var riderCancelledRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        
        OovooHandler.Instance.observeMessagesForRider()
        OovooHandler.Instance.delegate = self
    }
    
    private func initializeLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //if we have the coordinates from the manager
        if let location = locationManager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            myMap.setRegion(region, animated: true)
            
            myMap.removeAnnotations(myMap.annotations)
            
            if javerLocation != nil {
                if !canCallOovoo {
                    let javerAnnotation = MKPointAnnotation()
                    javerAnnotation.coordinate = javerLocation!
                    javerAnnotation.title = "Javer location"
                    myMap.addAnnotation(javerAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation!
            annotation.title = "Rider's Location"
            myMap.addAnnotation(annotation)
        }
    }
    
    func updateRiderLocation(){
        OovooHandler.Instance.updateRiderLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }
    
    func canCallOoovoo(delegateCalled: Bool) {
        if delegateCalled {
            callOovooBtn.setTitle("Cancel Oovoo", for: UIControlState.normal)
            canCallOovoo = false
        } else {
            callOovooBtn.setTitle("Call Oovoo", for: UIControlState.normal)
            canCallOovoo = true
        }
    }
    
    func javerAcceptedRequest(requestAccepted: Bool, javerName: String) {
        
        if !riderCancelledRequest {
            if requestAccepted {
                alertTheUser(title: "Oovoo accepted", message: "\(javerName) accepted your request and is on the way!")
            } else {
                OovooHandler.Instance.cancelOovoo()
                timer.invalidate()
                alertTheUser(title: "Oovoo cancelled", message: "\(javerName) cancelled your request")
            }
        }
        
        riderCancelledRequest = false
    }
    
    func updateJaverLocation(lat: Double, long: Double) {
        javerLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    @IBAction func callUber(_ sender: Any) {
        
        if userLocation != nil {
            if canCallOovoo {
                OovooHandler.Instance.requestOovoo(latitude: Double(userLocation!.latitude), longitude: Double(userLocation!.longitude))
                
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(RiderVC.updateRiderLocation), userInfo: nil, repeats: true)
            } else {
                riderCancelledRequest = true
                //cancel uber
                OovooHandler.Instance.cancelOovoo()
                timer.invalidate()
                
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        if AuthProvider.Instance.logOut() {
            if !canCallOovoo {
                OovooHandler.Instance.cancelOovoo()
                timer.invalidate()
            }
            dismiss(animated: true, completion: nil)
        } else {
            alertTheUser(title: "Could not log out.", message: "Could not log out at the moment, try again later.")
        }
    }
    
    private func alertTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}
