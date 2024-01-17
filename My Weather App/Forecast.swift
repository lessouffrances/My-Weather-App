import Foundation

struct Forecast: Codable {
    // Define a nested structure for daily forecast data
    struct Daily: Codable {
        let dt: Date
        
        struct Temp: Codable {
            let min: Double
            let max: Double
        }
        let temp: Temp
        
        let humidity: Int
        // Define a nested structure for weather data
        struct Weather: Codable {
            let description: String
            let icon: String
        }
        let weather: [Weather] // Array of weather conditions
        
        let clouds: Int
        let pop: Double
    }
    let daily: [Daily] // Array of daily forecasts
}
    


