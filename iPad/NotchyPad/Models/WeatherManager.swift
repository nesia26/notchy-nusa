import SwiftUI
import Combine

public struct WeatherInfo {
    public var temperature: Int
    public var weatherCode: Int
    public var conditionIcon: String
    public var conditionText: String
    public var humidity: Int
    public var city: String
}

public class WeatherManager: ObservableObject {
    @Published public var currentWeather: WeatherInfo = WeatherInfo(
        temperature: 30,
        weatherCode: 2,
        conditionIcon: "cloud.sun.fill",
        conditionText: "Partly Cloudy",
        humidity: 78,
        city: "Palembang"
    )
    @Published public var isLoading: Bool = false
    
    public init() {
        fetchWeather()
    }
    
    public func fetchWeather() {
        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=-2.9909&longitude=104.7565&current=temperature_2m,relative_humidity_2m,weather_code&timezone=auto") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let current = json["current"] as? [String: Any] {
                    let temp = Int(round(current["temperature_2m"] as? Double ?? 30.0))
                    let humidity = current["relative_humidity_2m"] as? Int ?? 75
                    let code = current["weather_code"] as? Int ?? 0
                    
                    let (icon, desc) = self?.mapWeatherCode(code) ?? ("cloud.sun.fill", "Partly Cloudy")
                    
                    DispatchQueue.main.async {
                        self?.currentWeather = WeatherInfo(
                            temperature: temp,
                            weatherCode: code,
                            conditionIcon: icon,
                            conditionText: desc,
                            humidity: humidity,
                            city: "Palembang"
                        )
                    }
                }
            } catch {
                // Keep default
            }
        }.resume()
    }
    
    private func mapWeatherCode(_ code: Int) -> (String, String) {
        switch code {
        case 0: return ("sun.max.fill", "Clear Sky")
        case 1, 2: return ("cloud.sun.fill", "Partly Cloudy")
        case 3: return ("cloud.fill", "Overcast")
        case 45, 48: return ("cloud.fog.fill", "Foggy")
        case 51...57: return ("cloud.drizzle.fill", "Drizzle")
        case 61...67: return ("cloud.rain.fill", "Rain")
        case 80, 81, 82: return ("cloud.heavyrain.fill", "Showers")
        case 71...77, 85...86: return ("cloud.snow.fill", "Snow")
        case 95, 96, 99: return ("cloud.bolt.rain.fill", "Thunderstorm")
        default: return ("cloud.sun.fill", "Partly Cloudy")
        }
    }
}
