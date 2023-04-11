//
//  DetailScreenViewController.swift
//  Weather App
//
//  Created by Rahul Ahuja on 2023-04-08.
//

import UIKit
import CoreLocation

class DetailScreenViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var locationNameView: UILabel!
    
    @IBOutlet weak var currentTempView: UILabel!
    
    @IBOutlet weak var conditionView: UILabel!
    
    @IBOutlet weak var highTempView: UILabel!
    
    @IBOutlet weak var lowTempView: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var items : [weatherList] = []
    
    var locationName: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        loadWeather(locationName)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "weatherData")
        
       

        // Do any additional setup after loading the view.
    }
    
    
    let locationManager = CLLocationManager()

    var weatherSymbol = ""
    var weatherCode = 0
    var tempType = ""
    var tempInC = ""
    var tempInF = ""
    var delegate: LocationScreenDelegate?
    var responseData: WeatherResoponse?

    
    
    
    
    private func loadWeather(_ search: String?){
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
                DispatchQueue.main.async {
                    self.tempInC = "\(weatherResponse.current.temp_c)C"
                    self.tempInF = "\(weatherResponse.current.temp_f)F"
                    self.currentTempView.text = "\(weatherResponse.current.temp_c)C"
                    self.locationNameView.text = weatherResponse.location.name
                    self.conditionView.text = "Condition: \(weatherResponse.current.condition.text)"
                    self.highTempView.text = "High:  \(weatherResponse.forecast.forecastday[0].day.maxtemp_c)C"
                    self.lowTempView .text = "Low:  \(weatherResponse.forecast.forecastday[0].day.mintemp_c)C"
            
                }
            }
            self.popuateTable()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        dataTask.resume()
        
    }
    
    private func getURL(query: String) -> URL? {
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
    
    
    @IBAction func onDoneTapped(_ sender: Any) {
        dismiss(animated: true)
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

    func popuateTable(){
        
        for i in 0...6 {
            switch(responseData?.forecast.forecastday[i].day.condition.code){
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
            if let data = responseData{
                let icon = UIImage(systemName: weatherSymbol)
                let title = "\(data.forecast.forecastday[i].date)"

                let subtitle = "H: \(data.forecast.forecastday[i].day.maxtemp_c)  L: \(data.forecast.forecastday[i].day.mintemp_c)"

                items.append(weatherList(title: title, subtitle: subtitle, icon: icon))

            }
        }
    }
}

struct weatherList{
    var title: String
    var subtitle: String
    var icon: UIImage?
}
