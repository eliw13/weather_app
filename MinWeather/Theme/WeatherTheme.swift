//
//  WeatherTheme.swift
//  MinWeather
//
//  Dynamic color theming based on weather conditions
//

import SwiftUI

// MARK: - Weather Theme

struct WeatherTheme {
    let primaryColor: Color
    let secondaryColor: Color
    let backgroundColor: Color
    let accentColor: Color
    let textColor: Color
    let cardBackground: Color
    let cardTextColor: Color // New: specific text color for cards
    let weatherCondition: WeatherCondition
    
    // Weather condition categories
    enum WeatherCondition: String {
        case sunny = "Clear"
        case cloudy = "Clouds"
        case rainy = "Rain"
        case drizzle = "Drizzle"
        case thunderstorm = "Thunderstorm"
        case snowy = "Snow"
        case foggy = "Mist"
        case haze = "Haze"
        case smoke = "Smoke"
        case dust = "Dust"
        case tornado = "Tornado"
        
        var displayName: String {
            switch self {
            case .sunny: return "Sunny"
            case .cloudy: return "Cloudy"
            case .rainy: return "Rainy"
            case .drizzle: return "Drizzle"
            case .thunderstorm: return "Stormy"
            case .snowy: return "Snowy"
            case .foggy: return "Foggy"
            case .haze: return "Hazy"
            case .smoke: return "Smoky"
            case .dust: return "Dusty"
            case .tornado: return "Severe"
            }
        }
    }
    
    // MARK: - Theme Presets
    
    /// Sunny/Clear weather theme (warm yellows and oranges)
    static let sunny = WeatherTheme(
        primaryColor: Color(red: 0.95, green: 0.76, blue: 0.26),      // Golden yellow
        secondaryColor: Color(red: 0.98, green: 0.87, blue: 0.51),    // Light yellow
        backgroundColor: Color(red: 0.96, green: 0.82, blue: 0.40),   // Warm yellow-orange
        accentColor: Color(red: 0.95, green: 0.61, blue: 0.07),       // Deep orange
        textColor: Color.white,
        cardBackground: Color(red: 0.98, green: 0.88, blue: 0.55),    // Light warm yellow
        cardTextColor: Color(red: 0.30, green: 0.25, blue: 0.10),     // Dark brown text
        weatherCondition: .sunny
    )
    
    /// Cloudy weather theme (cool blues and grays)
    static let cloudy = WeatherTheme(
        primaryColor: Color(red: 0.53, green: 0.73, blue: 0.88),      // Light blue
        secondaryColor: Color(red: 0.68, green: 0.82, blue: 0.93),    // Sky blue
        backgroundColor: Color(red: 0.60, green: 0.78, blue: 0.90),   // Cloud blue
        accentColor: Color(red: 0.41, green: 0.58, blue: 0.73),       // Steel blue
        textColor: Color.white,
        cardBackground: Color(red: 0.75, green: 0.88, blue: 0.96),    // Light icy blue
        cardTextColor: Color(red: 0.15, green: 0.20, blue: 0.30),     // Dark blue-gray text
        weatherCondition: .cloudy
    )
    
    /// Rainy weather theme (deep blues and purples)
    static let rainy = WeatherTheme(
        primaryColor: Color(red: 0.26, green: 0.35, blue: 0.55),      // Dark blue
        secondaryColor: Color(red: 0.35, green: 0.45, blue: 0.65),    // Medium blue
        backgroundColor: Color(red: 0.29, green: 0.38, blue: 0.58),   // Rain blue
        accentColor: Color(red: 0.20, green: 0.28, blue: 0.48),       // Deep navy
        textColor: Color.white,
        cardBackground: Color(red: 0.40, green: 0.50, blue: 0.70),    // Lighter rain blue
        cardTextColor: Color.white,                                    // White text (dark bg)
        weatherCondition: .rainy
    )
    
    /// Drizzle theme (lighter rain colors)
    static let drizzle = WeatherTheme(
        primaryColor: Color(red: 0.45, green: 0.55, blue: 0.70),      // Misty blue
        secondaryColor: Color(red: 0.55, green: 0.65, blue: 0.78),    // Light rain blue
        backgroundColor: Color(red: 0.50, green: 0.60, blue: 0.74),   // Drizzle blue
        accentColor: Color(red: 0.38, green: 0.48, blue: 0.63),       // Muted blue
        textColor: Color.white,
        cardBackground: Color(red: 0.65, green: 0.75, blue: 0.85),    // Light drizzle blue
        cardTextColor: Color(red: 0.15, green: 0.20, blue: 0.35),     // Dark blue text
        weatherCondition: .drizzle
    )
    
    /// Thunderstorm theme (dramatic dark purples and grays)
    static let thunderstorm = WeatherTheme(
        primaryColor: Color(red: 0.25, green: 0.23, blue: 0.35),      // Storm purple
        secondaryColor: Color(red: 0.35, green: 0.33, blue: 0.45),    // Dark purple
        backgroundColor: Color(red: 0.28, green: 0.26, blue: 0.38),   // Thunder gray-purple
        accentColor: Color(red: 0.60, green: 0.55, blue: 0.75),       // Lightning purple
        textColor: Color.white,
        cardBackground: Color(red: 0.38, green: 0.36, blue: 0.48),    // Lighter storm purple
        cardTextColor: Color.white,                                    // White text (dark bg)
        weatherCondition: .thunderstorm
    )
    
    /// Snowy weather theme (icy whites and light blues)
    static let snowy = WeatherTheme(
        primaryColor: Color(red: 0.85, green: 0.92, blue: 0.98),      // Ice white-blue
        secondaryColor: Color(red: 0.75, green: 0.85, blue: 0.95),    // Snow blue
        backgroundColor: Color(red: 0.80, green: 0.88, blue: 0.96),   // Frosty blue
        accentColor: Color(red: 0.60, green: 0.75, blue: 0.90),       // Icy blue
        textColor: Color(red: 0.20, green: 0.30, blue: 0.45),         // Dark blue text
        cardBackground: Color(red: 0.92, green: 0.96, blue: 0.99),    // Almost white
        cardTextColor: Color(red: 0.20, green: 0.30, blue: 0.45),     // Dark blue text
        weatherCondition: .snowy
    )
    
    /// Foggy/Misty weather theme (muted grays)
    static let foggy = WeatherTheme(
        primaryColor: Color(red: 0.65, green: 0.68, blue: 0.72),      // Fog gray
        secondaryColor: Color(red: 0.75, green: 0.78, blue: 0.82),    // Light fog
        backgroundColor: Color(red: 0.70, green: 0.73, blue: 0.77),   // Mist gray
        accentColor: Color(red: 0.55, green: 0.58, blue: 0.62),       // Dark fog
        textColor: Color.white,
        cardBackground: Color(red: 0.82, green: 0.85, blue: 0.88),    // Light mist
        cardTextColor: Color(red: 0.25, green: 0.28, blue: 0.32),     // Dark gray text
        weatherCondition: .foggy
    )
    
    /// Hazy weather theme (warm dusty tones)
    static let hazy = WeatherTheme(
        primaryColor: Color(red: 0.82, green: 0.75, blue: 0.65),      // Dusty beige
        secondaryColor: Color(red: 0.88, green: 0.82, blue: 0.73),    // Light haze
        backgroundColor: Color(red: 0.85, green: 0.78, blue: 0.69),   // Warm haze
        accentColor: Color(red: 0.72, green: 0.65, blue: 0.55),       // Deep tan
        textColor: Color.white,
        cardBackground: Color(red: 0.92, green: 0.88, blue: 0.80),    // Light beige
        cardTextColor: Color(red: 0.30, green: 0.25, blue: 0.20),     // Dark brown text
        weatherCondition: .haze
    )
    
    /// Tornado/Severe weather theme (dark menacing colors)
    static let severe = WeatherTheme(
        primaryColor: Color(red: 0.35, green: 0.32, blue: 0.30),      // Storm charcoal
        secondaryColor: Color(red: 0.45, green: 0.42, blue: 0.40),    // Dark gray
        backgroundColor: Color(red: 0.38, green: 0.35, blue: 0.33),   // Severe gray
        accentColor: Color(red: 0.70, green: 0.25, blue: 0.25),       // Warning red
        textColor: Color.white,
        cardBackground: Color(red: 0.48, green: 0.45, blue: 0.43),    // Lighter storm gray
        cardTextColor: Color.white,                                    // White text (dark bg)
        weatherCondition: .tornado
    )
    
    // MARK: - Theme Selection
    
    /// Get theme based on weather condition string from API
    static func theme(for weatherKey: String) -> WeatherTheme {
        guard let condition = WeatherCondition(rawValue: weatherKey) else {
            return .cloudy // Default fallback
        }
        
        switch condition {
        case .sunny:
            return .sunny
        case .cloudy:
            return .cloudy
        case .rainy:
            return .rainy
        case .drizzle:
            return .drizzle
        case .thunderstorm:
            return .thunderstorm
        case .snowy:
            return .snowy
        case .foggy, .smoke:
            return .foggy
        case .haze, .dust:
            return .hazy
        case .tornado:
            return .severe
        }
    }
}

// MARK: - Theme Environment Key

struct WeatherThemeKey: EnvironmentKey {
    static let defaultValue = WeatherTheme.cloudy
}

extension EnvironmentValues {
    var weatherTheme: WeatherTheme {
        get { self[WeatherThemeKey.self] }
        set { self[WeatherThemeKey.self] = newValue }
    }
}

// MARK: - View Modifier

struct WeatherThemedBackground: ViewModifier {
    let theme: WeatherTheme
    @AppStorage("themePreference") private var themePreference: String = "system"
    @Environment(\.colorScheme) private var systemColorScheme
    
    var isDarkMode: Bool {
        switch themePreference {
        case "dark": return true
        case "light": return false
        default: return systemColorScheme == .dark
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Base background color
                    theme.backgroundColor
                        .ignoresSafeArea()
                    
                    // Gradient overlay for depth
                    LinearGradient(
                        colors: [
                            theme.primaryColor.opacity(0.3),
                            theme.secondaryColor.opacity(0.2),
                            theme.backgroundColor.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }
            )
            .preferredColorScheme(themePreference == "system" ? nil : (themePreference == "dark" ? .dark : .light))
    }
}

extension View {
    /// Apply weather-based theme to the view
    func weatherThemedBackground(_ theme: WeatherTheme) -> some View {
        modifier(WeatherThemedBackground(theme: theme))
    }
}
