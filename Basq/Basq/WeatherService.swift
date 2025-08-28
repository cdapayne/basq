import Foundation

struct Weather: Decodable {
    let temperature: Double
    let humidity: Double
}

class WeatherService {
    func fetchWeather(zipCode: String) async throws -> Weather {
        // Geocode zip code to latitude and longitude
        let geoURL = URL(string: "https://geocoding-api.open-meteo.com/v1/search?postal_code=\(zipCode)&country=US&format=json")!
        let (geoData, _) = try await URLSession.shared.data(from: geoURL)
        struct GeoResponse: Decodable {
            struct Result: Decodable { let latitude: Double; let longitude: Double }
            let results: [Result]
        }
        let geo = try JSONDecoder().decode(GeoResponse.self, from: geoData)
        guard let first = geo.results.first else { throw URLError(.badServerResponse) }
        
        // Fetch weather using latitude and longitude
        let weatherURL = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(first.latitude)&longitude=\(first.longitude)&current=temperature_2m,relative_humidity_2m&temperature_unit=fahrenheit")!
        let (weatherData, _) = try await URLSession.shared.data(from: weatherURL)
        struct WeatherResponse: Decodable {
            struct Current: Decodable {
                let temperature_2m: Double
                let relative_humidity_2m: Double
            }
            let current: Current
        }
        let response = try JSONDecoder().decode(WeatherResponse.self, from: weatherData)
        return Weather(temperature: response.current.temperature_2m,
                       humidity: response.current.relative_humidity_2m)
    }
}
