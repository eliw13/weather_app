//
//  HomeViewModel.swift
//  MinWeather
//
//  Created by Thiago Souza on 09/09/24.
//

import Foundation
import UIKit

class HomeViewModel: ObservableObject, UserLocationProtocol {
    private var locationManager: LocationManager?
    
    @Published private(set) var state: State = .loading
    @Published private(set) var imageName: String = ""
    @Published private(set) var dateDescription: String = ""
    @Published private(set) var cityName: String = ""
    @Published private(set) var temperature: Int = 0
    @Published private(set) var weatherKey: String = ""
    @Published private(set) var weatherDescription: String = ""
    @Published private(set) var weatherCode: Int = 0
    @Published private(set) var humidity: Int = 0
    @Published private(set) var windSpeed: Int = 0
    @Published private(set) var visibility: Int = 0
    @Published private(set) var hourlyForecasts: [FetchWeatherDataResponse.HourlyWeather] = []
    @Published private(set) var dailyForecasts: [FetchWeatherDataResponse.DailyWeather] = []
    @Published private(set) var feelsLike: Int = 0
    
    enum State {
        case loading
        case loaded
        case error
    }
    
    
    private let openWeatherService: OpenWeatherService
    
    init(openWeatherService: OpenWeatherService) {
        self.openWeatherService = openWeatherService
    }
 
    
    func fetchData() {
        self.state = .loading
        self.locationManager = LocationManager(userLocationProtocol: self)
        self.locationManager?.requestPermission()
    }
    
    
    func onUserLocationPermissionGranted() {
        print("✅ HomeViewModel: Permission granted, requesting location")
        self.state = .loading
        self.locationManager?.requestLocation()
    }
    
    func onUserLocationPermissionDenied() {
        self.state = .error
    }
    
    func onUserLocationReceived(latitude: Double, longitude: Double) {
        print("📍 HomeViewModel: Location received - lat: \(latitude), lon: \(longitude)")
        self.state = .loading
        
        self.openWeatherService.fetchWeatherData(lat: latitude, lon: longitude) { response, error in
            if error != nil {
                print("❌ HomeViewModel: Weather API error: \(error!.localizedDescription)")
                self.state = .error
                return
            }
            
            if let data = response {
                print("✅ HomeViewModel: Weather data received for \(data.name)")
                let date = Date(timeIntervalSince1970: TimeInterval(data.dt))
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM d, YYYY"
                
                self.dateDescription = formatter.string(from: date)
                self.cityName = data.name
                self.temperature = Int(data.main.temp)
                self.weatherKey = data.weather.first!.main
                self.weatherDescription = data.weather.first!.description.capitalized
                self.weatherCode = data.weatherCode ?? 0
                self.humidity = data.main.humidity
                self.windSpeed = Int(data.wind.speed)
                self.visibility = Int(Double(data.visibility) / 1609.34) // Convert meters to miles
                self.hourlyForecasts = data.hourly ?? []
                self.dailyForecasts = data.daily ?? []
                self.feelsLike = Int(data.feelsLike ?? data.main.temp)
                
                let imagePrefix = data.weather.first!.icon.last!
                let imageName = "\(imagePrefix)_\(self.weatherKey)"
                
                if (UIImage(named: imageName) != nil) {
                    self.imageName = imageName
                } else {
                    // Workaround for unexpected types
                    self.imageName = "\(imagePrefix)_Clouds"
                }
                
                self.state = .loaded
            } else {
                print("❌ HomeViewModel: No weather data in response")
                self.state = .error
            }
        }
    }
    
    func onUserLocationError() {
        print("❌ HomeViewModel: Location error occurred")
        self.state = .error
    }
    
    // MARK: - Manual Location Selection
    
    func fetchWeatherForCity(_ cityName: String) {
        print("🌍 HomeViewModel: Fetching weather for \(cityName)")
        self.state = .loading
        
        // Comprehensive city coordinates database
        let cityCoordinates: [String: (lat: Double, lon: Double)] = [
            // Major US Cities
            "New York, NY": (40.7128, -74.0060),
            "Los Angeles, CA": (34.0522, -118.2437),
            "Chicago, IL": (41.8781, -87.6298),
            "Houston, TX": (29.7604, -95.3698),
            "Phoenix, AZ": (33.4484, -112.0740),
            "Philadelphia, PA": (39.9526, -75.1652),
            "San Antonio, TX": (29.4241, -98.4936),
            "San Diego, CA": (32.7157, -117.1611),
            "Dallas, TX": (32.7767, -96.7970),
            "San Jose, CA": (37.3382, -121.8863),
            "Austin, TX": (30.2672, -97.7431),
            "Jacksonville, FL": (30.3322, -81.6557),
            "Fort Worth, TX": (32.7555, -97.3308),
            "Columbus, OH": (39.9612, -82.9988),
            "Charlotte, NC": (35.2271, -80.8431),
            "San Francisco, CA": (37.7749, -122.4194),
            "Indianapolis, IN": (39.7684, -86.1581),
            "Seattle, WA": (47.6062, -122.3321),
            "Denver, CO": (39.7392, -104.9903),
            "Boston, MA": (42.3601, -71.0589),
            "Nashville, TN": (36.1627, -86.7816),
            "Detroit, MI": (42.3314, -83.0458),
            "Portland, OR": (45.5152, -122.6784),
            "Memphis, TN": (35.1495, -90.0490),
            "Oklahoma City, OK": (35.4676, -97.5164),
            "Las Vegas, NV": (36.1699, -115.1398),
            "Louisville, KY": (38.2527, -85.7585),
            "Baltimore, MD": (39.2904, -76.6122),
            "Milwaukee, WI": (43.0389, -87.9065),
            "Albuquerque, NM": (35.0844, -106.6504)
        ]
        
        if let coords = cityCoordinates[cityName] {
            self.openWeatherService.fetchWeatherData(lat: coords.lat, lon: coords.lon) { response, error in
                if error != nil {
                    print("❌ HomeViewModel: Weather API error for \(cityName): \(error!.localizedDescription)")
                    self.state = .error
                    return
                }
                
                if let data = response {
                    print("✅ HomeViewModel: Weather data received for \(cityName)")
                    self.updateWeatherData(data)
                } else {
                    print("❌ HomeViewModel: No weather data in response for \(cityName)")
                    self.state = .error
                }
            }
        } else {
            print("⚠️ HomeViewModel: No coordinates found for \(cityName), falling back to GPS")
            self.fetchData() // Fallback to GPS location
        }
    }
    
    private func updateWeatherData(_ data: FetchWeatherDataResponse) {
        let date = Date(timeIntervalSince1970: TimeInterval(data.dt))
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, YYYY"
        
        self.dateDescription = formatter.string(from: date)
        self.cityName = data.name
        self.temperature = Int(data.main.temp)
        self.weatherKey = data.weather.first!.main
        self.weatherDescription = data.weather.first!.description.capitalized
        self.weatherCode = data.weatherCode ?? 0
        self.humidity = data.main.humidity
        self.windSpeed = Int(data.wind.speed)
        self.visibility = Int(Double(data.visibility) / 1609.34)
        self.hourlyForecasts = data.hourly ?? []
        self.dailyForecasts = data.daily ?? []
        self.feelsLike = Int(data.feelsLike ?? data.main.temp)
        
        let imagePrefix = data.weather.first!.icon.last!
        let imageName = "\(imagePrefix)_\(self.weatherKey)"
        
        if (UIImage(named: imageName) != nil) {
            self.imageName = imageName
        } else {
            self.imageName = "\(imagePrefix)_Clouds"
        }
        
        self.state = .loaded
    }
}
