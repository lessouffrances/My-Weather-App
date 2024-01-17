import CoreLocation
import Foundation
import SwiftUI

class ForecastListViewModel: ObservableObject {
    struct AppError: Identifiable {
        let id = UUID().uuidString // ensure each error is identifiable
        let errorString: String
    }
    @Published var forecasts: [ForecastViewModel] = []
    var appError: AppError? = nil
    @Published var isLoading: Bool = false
    @AppStorage("location") var storageLocation: String = ""
    @Published var location = ""
    @AppStorage("system") var system: Int = 0 {
        didSet {
            // Update the system property for each forecast when it changes
            for i in 0..<forecasts.count {
                forecasts[i].system = system
            }
        }
    }
    // Initializer to set up the ViewModel
    init() {
        location = storageLocation
        getWeatherForecast()
    }
    // Function to fetch weather forecast data
    func getWeatherForecast() {
        storageLocation = location
        // Check if the location is empty
        if location == "" {
            forecasts = []
        } else {
            isLoading = true
            // Create an instance of the shared API service
            let apiService = APIService.shared
            CLGeocoder().geocodeAddressString(location) { (placemarks, error) in
                if let error = error as? CLError {
                    // Handle geocoding errors
                    switch error.code {
                    case .locationUnknown, .geocodeFoundNoResult, .geocodeFoundPartialResult:
                        self.appError = AppError(errorString: NSLocalizedString("Unable to determine location from this", comment: ""))
                    case .network:
                        self.appError = AppError(errorString: NSLocalizedString("Please check your network conection", comment: ""))
                    default:
                        // all other errors
                        self.appError = AppError(errorString: error.localizedDescription)
                    }
                    self.isLoading = false
                    print(error.localizedDescription)
                }
                // If geocoding is successful, get the latitude and longitude
                if let lat = placemarks?.first?.location?.coordinate.latitude,
                   let lon = placemarks?.first?.location?.coordinate.longitude {
                    // Make a request to the OpenWeatherMap API using the API service
                    apiService.getJSON(urlString: "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&exclude=current,minutely,hourly,alerts&appid=637a2fdec6e22b0d50cf853392f2d05d",
                                       dateDecodingStrategy: .secondsSince1970) { (result: Result<Forecast,APIService.APIError>)
                        in
                        switch result {
                        case .success(let forecast):
                            // Update the UI with the fetched forecast data
                            DispatchQueue.main.async {
                                self.isLoading = false
                                self.forecasts = forecast.daily.map { ForecastViewModel(forecast: $0, system: self.system)}
                            }
                        case .failure(let apiError):
                            // Handle API errors
                            self.isLoading = false
                            switch apiError {
                            case .error(let errorString):
                                self.appError = AppError(errorString: errorString)
                                print(errorString)
                            }
                        }
                    }
                }
            }
        }
    }
}
