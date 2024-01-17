import Foundation
// ViewModel for formatting and presenting forecast data
struct ForecastViewModel {
    let forecast: Forecast.Daily
    var system: Int // System for temperature unit conversion (0 for Celsius, 1 for Fahrenheit)
    
    // Static date formatter for consistent date representation
    private static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM, d"
        return dateFormatter
    }
    
    // Static number formatter for percentage representation
    private static var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        return numberFormatter
    }
    
    // Static number formatter for temperature representation
    private static var numberFormatter_temp: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }
    
    // Function to convert temperature based on the selected system
    func convert(_ temp: Double) -> Double {
        let celsius = temp - 273.15
        if system == 0 {
            return celsius
        } else {
            return celsius * 9 / 5 + 32
        }
    }
    var day: String {
        return Self.dateFormatter.string(from: forecast.dt)
    }
    
    var overview: String {
        forecast.weather[0].description.capitalized
    }
    
    var high: String {
        return "H: \(Self.numberFormatter_temp.string(for: convert(forecast.temp.max)) ?? "0")°"
    }
    
    var low: String {
        return "L: \(Self.numberFormatter_temp.string(for: convert(forecast.temp.min)) ?? "0")°"
    }
    
    var pop: String {
        return "pop: \(Self.numberFormatter.string(for: forecast.pop) ?? "0%")"
    }
    
    var clouds: String {
        return "Clouds: \(forecast.clouds)%"
    }
    
    var humidity: String {
        return "Humidity \(forecast.humidity)%"
    }
    var weatherIconURL: URL {
        let urlString = "https://openweathermap.org/img/wn/\(forecast.weather[0].icon)@2x.png"
        return URL(string: urlString)!
    }
}
