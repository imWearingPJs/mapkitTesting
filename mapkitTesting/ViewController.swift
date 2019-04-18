
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var startStop: UIButton!
    @IBOutlet weak var locateMe: UIButton!
    
    var locationManager = CLLocationManager()
    var routeCoordinates: [CLLocationCoordinate2D] = []
    var recordRoute = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        doLocationStuff()
    }
    
//    func setupUserTrackingButtonAndScaleView() {
//        mapView.showsUserLocation = true
//
//        let button = MKUserTrackingButton(mapView: mapView)
//        button.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
//        button.layer.borderColor = UIColor.white.cgColor
//        button.layer.borderWidth = 1
//        button.layer.cornerRadius = 5
//        button.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(button)
//
//        let scale = MKScaleView(mapView: mapView)
//        scale.legendAlignment = .trailing
//        scale.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(scale)
//
//        NSLayoutConstraint.activate([button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
//                                     button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
//                                     scale.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -10),
//                                     scale.centerYAnchor.constraint(equalTo: button.centerYAnchor)])
//    }
    
    func setDelegates() {
        mapView.delegate = self
        locationManager.delegate = self
    }
    
    func trackUser() {
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    func doLocationStuff() {
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(viewRegion, animated: false)
        }
        trackUser()
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied ||  CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 50
            
            locationManager.startUpdatingLocation()
        } else {
            print("Please turn on location services or else this will suck")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if recordRoute == true {
            let lat = locations[0].coordinate.latitude
            let long = locations[0].coordinate.longitude
            let userLoc = CLLocationCoordinate2DMake(lat, long)
            routeCoordinates.append(userLoc)
            let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
            mapView.addOverlay(polyline)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3
        return renderer
    }
    
    @IBAction func startStopTapped(_ sender: UIButton) {
        if sender.currentTitle == "Start" {
            sender.setTitle("Stop", for: .normal)
            recordRoute = true
        } else {
            sender.setTitle("Start", for: .normal)
            recordRoute = false
        }
        if recordRoute == false {
            routeCoordinates.removeAll()
            print("coordinates should be empty ", routeCoordinates)
            let overlays = mapView.overlays
            mapView.removeOverlays(overlays)
        }
    }
    
    @IBAction func locateMeTapped(_ sender: Any) {
        trackUser()
    }
    
    @IBAction func detailTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "moveToDetailVC", sender: self)
    }
}
