//
//  OpenWeatherService.swift
//  MinWeather
//
//  Created by Thiago Souza on 08/09/24.
//

import Foundation
import Alamofire
import CoreLocation

struct FetchWeatherDataResponse: Codable {
    let name: String
    let weather: [WeatherItem]
    let main: WeatherMain
    let wind: Wind
    let visibility: Int
    let dt: Int
    let hourly: [HourlyWeather]?
    let daily: [DailyWeather]?
    let weatherCode: Int?
    let feelsLike: Double?
    
    struct WeatherItem: Codable {
        let main: String
        let description: String
        let icon: String
    }

    struct WeatherMain: Codable {
        let temp: Double
        let humidity: Int
    }

    struct Wind: Codable {
        let speed: Double
    }
    
    struct HourlyWeather: Codable {
        let time: String
        let temperature: Double
        let weatherCode: Int
        
        var hour: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            if let date = formatter.date(from: time) {
                let hourFormatter = DateFormatter()
                hourFormatter.dateFormat = "ha"
                return hourFormatter.string(from: date).lowercased()
            }
            return time
        }
    }
    
    struct DailyWeather: Codable {
        let date: String
        let temperatureMin: Double
        let temperatureMax: Double
        let weatherCode: Int
        
        var dayOfWeek: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: self.date) {
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "EEE"
                return dayFormatter.string(from: date)
            }
            return date
        }
    }
}

// Open-Meteo API Response structures
struct OpenMeteoResponse: Codable {
    let latitude: Double
    let longitude: Double
    let current: CurrentWeather
    let hourly: HourlyWeather?
    let daily: DailyWeather?
    
    struct CurrentWeather: Codable {
        let time: String
        let temperature_2m: Double
        let relative_humidity_2m: Int
        let weather_code: Int
        let wind_speed_10m: Double
        let apparent_temperature: Double
        let visibility: Double?
    }
    
    struct HourlyWeather: Codable {
        let time: [String]
        let temperature_2m: [Double]
        let weather_code: [Int]
    }
    
    struct DailyWeather: Codable {
        let time: [String]
        let temperature_2m_max: [Double]
        let temperature_2m_min: [Double]
        let weather_code: [Int]
    }
}

class OpenWeatherService {
    private let openMeteoBaseUrl = "https://api.open-meteo.com/v1"
    private let session: Session
    private let geocoder = CLGeocoder()
    
    init(session: Session = .default) {
        self.session = session
    }
    
    func fetchWeatherData(lat: Double, lon: Double, completion: @escaping (FetchWeatherDataResponse?, Error?) -> Void) {
        // Use Apple's CLGeocoder for reverse geocoding (more reliable)
        let location = CLLocation(latitude: lat, longitude: lon)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            // Get city name and state abbreviation from geocoder
            let placemark = placemarks?.first
            let city = placemark?.locality ?? 
                      placemark?.subLocality ?? 
                      placemark?.administrativeArea ?? 
                      "Unknown Location"
            
            // Add state abbreviation if available
            let cityName: String
            if let stateAbbreviation = placemark?.administrativeArea {
                cityName = "\(city), \(stateAbbreviation)"
            } else {
                cityName = city
            }
            
            print("📍 Geocoded location: \(cityName)")
            
            // Now fetch weather data
            let weatherParams = [
                "latitude": "\(lat)",
                "longitude": "\(lon)",
                "current": "temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,apparent_temperature,visibility",
                "hourly": "temperature_2m,weather_code",
                "daily": "temperature_2m_max,temperature_2m_min,weather_code",
                "temperature_unit": "celsius",
                "wind_speed_unit": "mph",
                "forecast_days": "7",
                "timezone": "auto"
            ]
            
            let weatherUrl = "\(self.openMeteoBaseUrl)/forecast?\(weatherParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&"))"
            
            self.session.request(weatherUrl)
                .validate()
                .responseDecodable(of: OpenMeteoResponse.self) { weatherResponse in
                    switch weatherResponse.result {
                    case .success(let meteoData):
                        // Convert Open-Meteo response to our existing format
                        let converted = self.convertToWeatherResponse(meteoData: meteoData, cityName: cityName)
                        completion(converted, nil)
                    case .failure(let error):
                        print("❌ Open-Meteo API error: \(error)")
                        completion(nil, error)
                    }
                }
        }
    }
    
    private func convertToWeatherResponse(meteoData: OpenMeteoResponse, cityName: String) -> FetchWeatherDataResponse {
        let weatherCode = meteoData.current.weather_code
        let (weatherMain, weatherDescription, iconCode) = self.interpretWMOCode(weatherCode)
        
        // Convert hourly data (get next 12 hours starting from current hour)
        var hourlyForecasts: [FetchWeatherDataResponse.HourlyWeather] = []
        if let hourly = meteoData.hourly {
            // Get current date components to find the current hour
            let now = Date()
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: now)
            
            // Parse the hourly times to find the index of the current hour
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            
            var startIndex = 0
            for (index, timeString) in hourly.time.enumerated() {
                if let date = formatter.date(from: timeString) {
                    let hour = calendar.component(.hour, from: date)
                    // Check if this is the current hour or later
                    if date >= now || (calendar.isDate(date, inSameDayAs: now) && hour >= currentHour) {
                        startIndex = index
                        break
                    }
                }
            }
            
            // Get the next 12 hours from the start index
            let endIndex = min(startIndex + 12, hourly.time.count)
            for i in startIndex..<endIndex {
                let hourlyWeather = FetchWeatherDataResponse.HourlyWeather(
                    time: hourly.time[i],
                    temperature: hourly.temperature_2m[i],
                    weatherCode: hourly.weather_code[i]
                )
                hourlyForecasts.append(hourlyWeather)
            }
        }
        
        // Convert daily data (get next 7 days)
        var dailyForecasts: [FetchWeatherDataResponse.DailyWeather] = []
        if let daily = meteoData.daily {
            let maxDays = min(7, daily.time.count)
            for i in 0..<maxDays {
                let dailyWeather = FetchWeatherDataResponse.DailyWeather(
                    date: daily.time[i],
                    temperatureMin: daily.temperature_2m_min[i],
                    temperatureMax: daily.temperature_2m_max[i],
                    weatherCode: daily.weather_code[i]
                )
                dailyForecasts.append(dailyWeather)
            }
        }
        
        return FetchWeatherDataResponse(
            name: cityName,
            weather: [
                FetchWeatherDataResponse.WeatherItem(
                    main: weatherMain,
                    description: weatherDescription,
                    icon: iconCode
                )
            ],
            main: FetchWeatherDataResponse.WeatherMain(
                temp: meteoData.current.temperature_2m,
                humidity: meteoData.current.relative_humidity_2m
            ),
            wind: FetchWeatherDataResponse.Wind(
                speed: meteoData.current.wind_speed_10m
            ),
            visibility: Int((meteoData.current.visibility ?? 10000)),
            dt: Int(Date().timeIntervalSince1970),
            hourly: hourlyForecasts,
            daily: dailyForecasts,
            weatherCode: weatherCode,
            feelsLike: meteoData.current.apparent_temperature
        )
    }
    
    // WMO Weather interpretation codes
    // https://open-meteo.com/en/docs
    private func interpretWMOCode(_ code: Int) -> (main: String, description: String, icon: String) {
        switch code {
        case 0:
            return ("Clear", "clear sky", "01d")
        case 1:
            return ("Clouds", "mainly clear", "02d")
        case 2:
            return ("Clouds", "partly cloudy", "03d")
        case 3:
            return ("Clouds", "overcast", "04d")
        case 45, 48:
            return ("Fog", "foggy", "50d")
        case 51, 53, 55:
            return ("Drizzle", "drizzle", "09d")
        case 56, 57:
            return ("Drizzle", "freezing drizzle", "09d")
        case 61, 63, 65:
            return ("Rain", "rain", "10d")
        case 66, 67:
            return ("Rain", "freezing rain", "13d")
        case 71, 73, 75:
            return ("Snow", "snow", "13d")
        case 77:
            return ("Snow", "snow grains", "13d")
        case 80, 81, 82:
            return ("Rain", "rain showers", "09d")
        case 85, 86:
            return ("Snow", "snow showers", "13d")
        case 95:
            return ("Thunderstorm", "thunderstorm", "11d")
        case 96, 99:
            return ("Thunderstorm", "thunderstorm with hail", "11d")
        default:
            return ("Clouds", "cloudy", "03d")
        }
    }
}

