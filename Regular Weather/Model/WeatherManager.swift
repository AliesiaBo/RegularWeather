import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    let api = ""
    var weatherURL: String {
        return "https://api.openweathermap.org/data/2.5/weather?appid=\(api)&units=metric"
    }
    
    var delegate: WeatherManagerDelegate?
    
    //MARK: - Fetch Weather By City
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    //MARK: - Fetch Weather By Location
    
    func fetchWeather (latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    //MARK: - Asking Request & Getting Weather
    
    func performRequest(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                let safeData = data,
                let weather = self.parseJSON(safeData)
            else { self.delegate?.didFailWithError(error: error!); return }
            
            self.delegate?.didUpdateWeather(self, weather: weather)
        }
        
        task.resume()
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            let temp = decodedData.main.temp
            let name = decodedData.name
            let description = decodedData.weather[0].description
            let country = decodedData.sys.country
            
            let id = decodedData.weather[0].id
            
            let weather = WeatherModel(conditionId: id, cityName: name, countryName: country, descrptionStatut: description, temperature: temp)
            
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
