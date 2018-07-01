//
//  JaverVC.swift
//  oovoo_javer
//
//  Created by Ayman Zeine on 6/29/18.
//  Copyright © 2018 Ayman Zeine. All rights reserved.
//

import UIKit
import MapKit

class JaverVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, OovooController  {

    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var acceptOovooBtn: UIButton!
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var riderLocation: CLLocationCoordinate2D?
    
    private var timer = Timer()
    
    private var acceptedOovoo = false
    private var javerCancelled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        
        OovooHandler.Instance.delegate = self
        OovooHandler.Instance.observeRequestsForJaver()
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
            
            if riderLocation != nil {
                if acceptedOovoo {
                    let riderAnnotation = MKPointAnnotation()
                    riderAnnotation.coordinate = riderLocation!
                    riderAnnotation.title = "Rider's location"
                    myMap.addAnnotation(riderAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation!
            annotation.title = "Javer's Location"
            myMap.addAnnotation(annotation)
        }
        
    }
    
    func updateRiderLocation(lat: Double, long: Double) {
        riderLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    func acceptOovoo(lat: Double, long: Double) {
        
        if !acceptedOovoo {
            oovooRequest(title: "Oovoo Request", message: "You have a request for an uber at this location: \(lat) \(long)", requestAlive: true)
        }
    }
    
    func riderCancelledOovoo() {
        if !javerCancelled {
            //cancel oovoo from javer perspective
            OovooHandler.Instance.cancelOovooForJaver()
            self.acceptedOovoo = false
            self.acceptOovooBtn.isHidden = true
            oovooRequest(title: "Oovoo Cancelled", message: "The rider cancelled their request", requestAlive: false)
        }
    }
    
    @IBAction func cancelOovoo(_ sender: Any) {
        if acceptedOovoo {
            javerCancelled = true
            acceptOovooBtn.isHidden = true
            OovooHandler.Instance.cancelOovooForJaver()
            timer.invalidate()
        }
    }
    
    @objc func updateJaverLocation(){
        OovooHandler.Instance.updateJaverLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }
    
    func javerCancelledOovoo() {
        acceptedOovoo = false
        acceptOovooBtn.isHidden = true
        timer.invalidate()
    }
    
    @IBAction func logOut(_ sender: Any) {
        if AuthProvider.Instance.logOut() {
            if acceptedOovoo {
                acceptOovooBtn.isHidden = true
                OovooHandler.Instance.cancelOovooForJaver()
                timer.invalidate()
            }
            dismiss(animated: true, completion: nil)
        } else {
            oovooRequest(title: "Could not log out.", message: "Could not log out at the moment, try again later.", requestAlive: false)
        }
    }
    
    private func oovooRequest(title: String, message: String, requestAlive: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if requestAlive {
            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (alertAction: UIAlertAction) in
                
                self.acceptedOovoo = true
                self.acceptOovooBtn.isHidden = false
                
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(JaverVC.updateJaverLocation), userInfo: nil, repeats: true)
                
                //inform rider that oovoo javer accepted the request
                OovooHandler.Instance.oovooAccepted(lat: Double(self.userLocation!.latitude), long: Double(self.userLocation!.longitude))
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            alert.addAction(accept)
            alert.addAction(cancel)
        } else {
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func alertTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    

}
