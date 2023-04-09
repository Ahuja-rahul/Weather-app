//
//  ViewController.swift
//  Weather App
//
//  Created by Rahul Ahuja on 2023-04-04.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    //var weatherResponse: WeatherResoponse?

    
    
    var myData: WeatherResoponse?
    
    var items : [weatherDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupMap()
        addAnnotion(location: CLLocation(latitude: 42.983612, longitude: -81.249725))
        loadItems()
        tableView.dataSource = self
        
    }
    
    
    @IBAction func printButton(_ sender: UIButton) {
        print(myData?.forecast.forecastday[0].day.avgtemp_c ?? "No value")
    }
    

    @IBAction func addLocationTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToLocation", sender: self)
    }
    
    
    func addAnnotion(location: CLLocation){
        let annotion = MyAnnotion(coordinate: location.coordinate,
                                  title: "London",
                                  subtitle: "Forest City",
                                  glyphText: "L")
        
        mapView.addAnnotation(annotion)
    }
    
    func setupMap(){
        mapView.delegate = self
        
        let location = CLLocation(latitude: 42.983612, longitude: -81.249725)
        let radiusInMeters : CLLocationDistance = 1000
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
        
        mapView.setRegion(region, animated: true)
        
        let cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: region)
        mapView.setCameraBoundary(cameraBoundary, animated: true)
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 100000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
    }
    
    private func loadItems(){
        items.append(weatherDetails(title: "Title 1", subtitle: "SUb 1"))
        items.append(weatherDetails(title: "Title 2", subtitle: "SUb 2"))
        items.append(weatherDetails(title: "Title 3", subtitle: "SUb 3"))
        items.append(weatherDetails(title: "Title 4", subtitle: "SUb 4"))
    }
}
    extension ViewController : MKMapViewDelegate{

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifer = "Hello Hello"
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifer)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: 0, y: 10)
            
            //add button to the right side of callout
            let button = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = button
            
            //add image to left side of the callout
            let image = UIImage(systemName: "graduationcap.circle.fill")
            view.leftCalloutAccessoryView = UIImageView(image: image)
            
            // change colour of the pin
            view.markerTintColor = UIColor.cyan
            
            //change colour of title/subtitle/callout image
            view.tintColor = UIColor.red
            
            if let myAnnotion = annotation as? MyAnnotion{
                view.glyphText = myAnnotion.glyphText
            }
            return view
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            performSegue(withIdentifier: "goToDetail", sender: self)
        }
       
        func didAddWeatherData(_ data: WeatherResoponse) {
            myData = data
            print(data)
        }
        
        
        
    }
    
    class MyAnnotion: NSObject, MKAnnotation{
        var coordinate: CLLocationCoordinate2D
        var title: String?
        var subtitle: String?
        var glyphText: String?
        
        
        init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, glyphText: String) {
            self.coordinate = coordinate
            self.title = title
            self.subtitle = subtitle
            self.glyphText = glyphText
            
            super.init()
        }
    }

struct weatherDetails{
    var title: String
    var subtitle: String
}

extension ViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(items[3])
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
        
        let item = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        
        
        content.text = item.title
        content.secondaryText = item.subtitle
        cell.contentConfiguration = content
        return cell
    }
}

