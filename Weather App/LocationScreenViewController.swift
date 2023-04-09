//
//  LocationScreenViewController.swift
//  Weather App
//
//  Created by Rahul Ahuja on 2023-04-08.
//

import UIKit
import CoreLocation

class LocationScreenViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var weatherConditionLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    let locationManager = CLLocationManager()

    var weatherSymbol = ""
    var weatherCode = 0
    var tempType = ""
    var tempInC = ""
    var tempInF = ""
    
    //R
    weak var delegate: LocationScreenViewControllerDelegate?
    var responseData: WeatherResoponse?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //searchTextField.delegate = self
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func onLocationTapped(_ sender: UIButton) {
        let latitude = locationManager.location!.coordinate.latitude
        let longitude = locationManager.location!.coordinate.longitude
        loadWeather(search: "\(latitude),\(longitude)")
        searchTextField.text = ""
    }
    
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: searchTextField.text)
    }
    
    //R
    @IBAction func onSaveTapped(_ sender: UIBarButtonItem) {
        if let responseData = self.responseData {
                    delegate?.didAddWeatherData(responseData)
                }
                dismiss(animated: true)
            }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        loadWeather(search: textField.text)
        
        return true
    }
    
    
    
    private func loadWeather(search: String?){
        guard let search = search else{
            return
        }
        
        guard let url = getURL(query: search) else {
            print("Could not get URL")
            return
        }
        
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) {data, response, error in
            print("Network call complete")
            
            guard error == nil else{
                print("Received Error")
                return
            }
            
            guard let data = data else{
                print("No data found")
                return
            }
            if let weatherResponse = self.parseJson(data: data){
                self.responseData = weatherResponse
//                print(weatherResponse.location.name)
//                print(weatherResponse.current.temp_c)
//                print(weatherResponse.forecast.forecastday[6].day.avgtemp_c)
                //self.weatherResponseCode = weatherResponse.current.condition.code
                DispatchQueue.main.async {
                    self.locationLabel.text = weatherResponse.location.name
                    self.weatherConditionLabel.text = weatherResponse.current.condition.text
                    self.tempInC = "\(weatherResponse.current.temp_c)C"
                    self.tempInF = "\(weatherResponse.current.temp_f)F"
                    self.temperatureLabel.text = self.tempInC
                    
                }
            }
        }
        dataTask.resume()
    }
    
    private func getURL(query: String) -> URL? {
//      ,
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "forecast.json"
        let apiKey = "2e35e4136d7a4152b9b200010230804"
        
        guard let url = "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(query)&days=7&aqi=no&alerts=no"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
                return nil
            }
        return URL(string: url)
    }
    
    private func parseJson(data: Data) -> WeatherResoponse? {
        let decoder = JSONDecoder()
        var weather: WeatherResoponse?
        do{
            weather = try decoder.decode(WeatherResoponse.self, from: data)
        } catch {
            print("Error decoding")
        }
        return weather
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}
//R
protocol LocationScreenViewControllerDelegate: AnyObject {
    func didAddWeatherData(_ data: WeatherResoponse)
}


struct WeatherResoponse: Decodable {
    let location: Location
    let current: Weather
    let forecast: Forecast
}
struct Location: Decodable{
    let name: String
}

struct Weather: Decodable {
    let temp_c : Float
    let temp_f : Float
    let condition: WeatherCondition
}
struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}

struct Forecast: Decodable{
    let forecastday: [Forecastday]
}
struct Forecastday: Decodable{
    let day: Day
}
struct Day: Decodable{
    let maxtemp_c: Float
    let maxtemp_f: Float
    let mintemp_c: Float
    let mintemp_f: Float
    let avgtemp_c: Float
    let avgtemp_f: Float
}

