import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    @StateObject private var forecastListVM = ForecastListViewModel()
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    // Picker for selecting temperature units (Celsius or Fahrenheit)
                    Picker(selection: $forecastListVM.system, label: Text("Units")) {
                        Text("°C").tag(0)
                        Text("°F").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                    .padding(.vertical)
                    // Search bar for entering location and fetching weather
                    HStack {
                        TextField("Where are you :)", text: $forecastListVM.location,
                                  onCommit: {
                            forecastListVM.getWeatherForecast()
                        })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay (
                                Button(action: {
                                    forecastListVM.location = ""
                                    forecastListVM.getWeatherForecast()
                                }) {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.red)
                                }
                                    . padding(.horizontal),
                                    alignment: .trailing)
                        Button {
                            forecastListVM.getWeatherForecast()
                        } label: {
                            Image(systemName:
                                    "magnifyingglass.circle.fill")
                            .font(.largeTitle)
                        }
                    }
                    // List of daily forecasts
                    List(forecastListVM.forecasts, id: \.day) {day in
                            VStack(alignment: .leading) {
                                Text(day.day)
                                    .fontWeight(.semibold)
                                // Weather details for each day
                                HStack(alignment: .center) {
                                    WebImage(url: day.weatherIconURL)
                                        .resizable()
                                        .placeholder {
                                            Image(systemName: "hourglass")
                                        }
                                        .scaledToFit()
                                        .frame(width: 100)
                                    VStack(alignment: .leading) {
                                        Text(day.overview)
                                            .font(.title3)
                                        HStack {
                                            Text(day.high)
                                            Text(day.low)
                                        }
                                        HStack {
                                            Text(day.clouds)
                                            Text(day.pop)
                                        }
                                        Text(day.humidity)
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                }
                .padding(.horizontal)
                .navigationTitle("My Weather")
                .alert(item: $forecastListVM.appError) { appAlert in
                    // Display alert for errors
                    Alert(title: Text("Error"),
                          message: Text("""
                            \(appAlert.errorString)
                          Please try again later!
                          """
                          ))
                }
            }
            // Loading indicator when fetching data
            if forecastListVM.isLoading {
                ZStack {
                    Color(.white)
                        .opacity(0.3) // Make this box transparent
                        .ignoresSafeArea()
                    ProgressView("Loading Weather")
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemBackground)))
                        .shadow(radius: 10)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
