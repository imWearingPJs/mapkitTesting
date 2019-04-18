
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var startStop: UIButton!
    @IBOutlet weak var locateMe: UIButton!
    @IBOutlet weak var locationButton: MKUserTrackingButton!
    
    var locationManager = CLLocationManager()
    var routeCoordinates: [CLLocationCoordinate2D] = []
    var recordRoute = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        doLocationStuff()
    }
    
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
