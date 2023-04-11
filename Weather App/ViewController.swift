//
//  ViewController.swift
//  Weather App
//
//  Created by Rahul Ahuja on 2023-04-04.
//

import UIKit
import MapKit

class ViewController: UIViewController, LocationScreenDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    var myData: WeatherResoponse?
    var weatherResponseCode: Int?
    var weatherSymbol: String?
    var locationName = ""
    
    func weatherResponseData(_ data: WeatherResoponse) {
        myData = data
        if let myData = myData{
            weatherResponseCode = myData.current.condition.code
            switch(weatherResponseCode){
            case 1000:
                // sunny
                weatherSymbol = "sun.min.fill"
            case 1003:
                // partly cloudy
                weatherSymbol = "cloud"
            case 1006:
            // cloudy
                weatherSymbol = "cloud.fill"
            case 1009:
            // overcast
                weatherSymbol = "smoke.fill"
            case 1153:
            // light drizzle
                weatherSymbol = "cloud.drizzle"
            case 1135:
            // mist
                weatherSymbol = "cloud.drizzle.fill"
            case 1168:
            // Freezing drizzle
                weatherSymbol = "cloud.drizzle.circle.fill"
            case 1183:
            // Light rain
                weatherSymbol = "cloud.rain.fill"
            case 1201:
            // heavy or moderate freezing rain
                weatherSymbol = "cloud.rain.circle.fill"
            case 1195:
            // heavy rain
                weatherSymbol = "cloud.heavyrain.fill"
            case 1213:
            // light snow
                weatherSymbol = "cloud.snow.circle"
            case 1219:
            // moderate snow
                weatherSymbol = "cloud.snow"
            case 1225:
            // heavy snow
                weatherSymbol = "cloud.snow.fill"
              default:
                // statements
                weatherSymbol = "sun.dust.fill"
            }
            let icon = UIImage(systemName: weatherSymbol!)
            let locationName: String = String((myData.location.name))
            let subtitle = "\(myData.current.temp_c)C  (H: \(myData.forecast.forecastday[0].day.maxtemp_c)  L: \(myData.forecast.forecastday[0].day.mintemp_c))"
            let coordinates = CLLocation(latitude: myData.location.lat, longitude: myData.location.lon)
            items.append(weatherDetails(title: locationName, subtitle: subtitle, coodinates: coordinates, icon: icon))
            tableView.reloadData()
        }
    }
    
   
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    //var weatherResponse: WeatherResoponse?

//    let identifired = "gotoMain"
    
    
    
    var items : [weatherDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupMap()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "weatherData")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
        
        let item = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        
        
        content.text = item.title
        content.secondaryText = item.subtitle
        content.image = item.icon
        cell.contentConfiguration = content
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        locationName = item.title
        let region = MKCoordinateRegion(center: item.coodinates.coordinate,
                                                latitudinalMeters: 1000,
                                                longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
                
                let annotation = MyAnnotion(coordinate:
                                                item.coodinates.coordinate,
                                                title: item.title,
                                                subtitle: item.subtitle
                )
       
        
                mapView.removeAnnotations(mapView.annotations)
                mapView.addAnnotation(annotation)
                
                tableView.deselectRow(at: indexPath, animated: true)
        
            }
    
    

    @IBAction func addLocationTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToLocation", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToLocation"{
            let viewController = segue.destination as! LocationScreenViewController
            viewController.delegate = self
            
        }
        if segue.identifier == "goToDetail"{
            let viewController = segue.destination as! DetailScreenViewController
            viewController.locationName = locationName
        }
    }
    
    func setupMap(){
        mapView.delegate = self
        
        let location = CLLocation(latitude: 42.983612, longitude: -81.249725)
        let radiusInMeters : CLLocationDistance = 1000
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
        
        mapView.setRegion(region, animated: true)
        
//        let cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: region)
//        mapView.setCameraBoundary(cameraBoundary, animated: true)
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 100000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
    }
    
//    private func loadItems(){
//        items.append(weatherDetails(title: "Title 1", subtitle: "SUb 1"))
//        
//    }
}
    extension ViewController : MKMapViewDelegate{

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifer = "MyIdentifer"
            //var view: MKAnnotationView
            
            
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifer)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: 0, y: 10)
            
            //add button to the right side of callout
            let button = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = button
            
            //add image to left side of the callout
            let image = UIImage(systemName: "mappin")
            view.leftCalloutAccessoryView = UIImageView(image: image)
            
            // change colour of the pin
            view.markerTintColor = UIColor(red: 0, green: 0, blue: 0.5, alpha: 1.0 )
            
            //change colour of title/subtitle/callout image
            view.tintColor = UIColor.red
            
            return view
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            performSegue(withIdentifier: "goToDetail", sender: self)
            
        }
    }
    
    class MyAnnotion: NSObject, MKAnnotation{
        var coordinate: CLLocationCoordinate2D
        var title: String?
        var subtitle: String?
        
        
        init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
            self.coordinate = coordinate
            self.title = title
            self.subtitle = subtitle
            
            super.init()
        }
    }

struct weatherDetails{
    var title: String
    var subtitle: String
    var coodinates: CLLocation
    var icon: UIImage?
}

