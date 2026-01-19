//
//  HomeView.swift
//  MinWeather
//
//  Redesigned with dynamic weather theming and custom fonts
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    @StateObject var viewModel: HomeViewModel
    @State var isViewLoaded: Bool = false
    @State private var isMenuOpen: Bool = false
    @State private var isFahrenheit: Bool = true // Default to Fahrenheit
    @AppStorage("themePreference") private var themePreference: String = "system"
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var showingSettings: Bool = false
    @State private var showingLocations: Bool = false
    @Namespace private var locationTransition
    @State private var isHamburgerMenuOpen: Bool = false // New hamburger menu state
    @State private var testWeatherKey: String? = nil // For testing different weather animations
    @State private var showWeatherTestMenu: Bool = false // Weather test menu sheet
    
    // Get current theme based on weather
    private var currentTheme: WeatherTheme {
        WeatherTheme.theme(for: testWeatherKey ?? viewModel.weatherKey)
    }
    
    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private func displayTemperature(_ celsius: Double) -> Int {
        isFahrenheit ? Int((celsius * 9/5) + 32) : Int(celsius)
    }
    
    private var temperatureUnit: String {
        isFahrenheit ? "°F" : "°C"
    }
    
    var body: some View {
        ZStack {
            VStack {
                switch viewModel.state {
                case .loading: loadingView
                case .loaded: loadedView
                case .error: errorView
                }
            }
            .onAppear {
                viewModel.fetchData()
            }
            .onChange(of: viewModel.state) { _, newValue in
                if newValue == .loaded {
                    withAnimation {
                        isViewLoaded = true
                    }
                }
            }
            .weatherThemedBackground(currentTheme)
            .overlay {
                // Animated weather background BEHIND all content
                AnimatedWeatherBackground(weatherKey: testWeatherKey ?? viewModel.weatherKey)
                    .allowsHitTesting(false) // Don't block user interaction
            }
            .matchedGeometryEffect(id: "weatherView", in: locationTransition, isSource: !showingLocations)
            
            // Hamburger Menu Popup (no dimmed overlay)
            hamburgerMenuBuilder()
            
            // Hamburger button stays on top
            VStack {
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            isHamburgerMenuOpen.toggle()
                        }
                    }) {
                        Image(systemName: isHamburgerMenuOpen ? "xmark" : "line.3.horizontal")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.white)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showWeatherTestMenu) {
            WeatherTestMenuView(testWeatherKey: $testWeatherKey)
        }
        .fullScreenCover(isPresented: $showingLocations) {
            LocationsManagerView(
                namespace: locationTransition,
                onLocationSelected: { locationName in
                    if locationName != "Current Location" {
                        viewModel.fetchWeatherForCity(locationName)
                    } else {
                        viewModel.fetchData()
                    }
                }
            )
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        ZStack {
            // Simple gradient background (not theme-dependent)
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.6, blue: 0.8),
                    Color(red: 0.5, green: 0.7, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Loading content
            VStack(spacing: 24) {
                // Animated cloud icon
                Image(systemName: "cloud.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(Color.white.opacity(0.9))
                    .symbolEffect(.pulse)
                
                // App name
                Text("Strata")
                    .font(.custom("Aldrich-Regular", size: 42))
                    .foregroundStyle(Color.white)
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            }
        }
    }
    
    // MARK: - Error View
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundStyle(currentTheme.accentColor)
            
            Text("SOMETHING WENT WRONG")
                .font(.subtitle)
                .foregroundStyle(currentTheme.textColor)
            
            Text("Please try again later")
                .font(.detailText)
                .foregroundStyle(currentTheme.textColor.opacity(0.7))
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Loaded View
    
    private var loadedView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                headerSection
                currentWeatherSection
                hourlyForecastSection
                detailsGridSection
                weeklyForecastSection
            }
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        // Empty header - hamburger button is now in overlay
        HStack {
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .frame(height: 44) // Maintain spacing
    }
    
    // MARK: - Current Weather Section
    
    private var currentWeatherSection: some View {
        VStack(spacing: 12) {
            // Temperature unit switcher (F/C) - LARGER
            HStack(spacing: 6) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isFahrenheit = false
                    }
                }) {
                    Text("°C")
                        .font(.custom("Amiko-Regular", size: 22))
                        .foregroundStyle(isFahrenheit ? Color.white.opacity(0.5) : Color.white)
                        .fontWeight(isFahrenheit ? .regular : .bold)
                }
                
                Text("|")
                    .font(.custom("Amiko-Regular", size: 22))
                    .foregroundStyle(Color.white.opacity(0.3))
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isFahrenheit = true
                    }
                }) {
                    Text("°F")
                        .font(.custom("Amiko-Regular", size: 22))
                        .foregroundStyle(isFahrenheit ? Color.white : Color.white.opacity(0.5))
                        .fontWeight(isFahrenheit ? .bold : .regular)
                }
            }
            .padding(.bottom, 8)
            
            // Main temperature (no icon above)
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("\(displayTemperature(Double(viewModel.temperature)))")
                    .font(.custom("Aldrich-Regular", size: 140))
                    .foregroundStyle(currentTheme.textColor)
                
                Text("°")
                    .font(.custom("Aldrich-Regular", size: 60))
                    .foregroundStyle(currentTheme.textColor.opacity(0.8))
                    .offset(y: -24)
            }
            .padding(.bottom, 4)
            
            // Location with icon button - LARGER
            HStack(spacing: 6) {
                Text(viewModel.cityName)
                    .font(.custom("Abel-Regular", size: 28))
                    .foregroundStyle(Color.white)
                
                Button(action: {
                    showingLocations = true
                }) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(currentTheme.accentColor)
                }
            }
            
            // Low/High and Feels Like - LARGER & WHITE
            HStack(spacing: 20) {
                // Get today's forecast for high/low
                if let today = viewModel.dailyForecasts.first {
                    HStack(spacing: 6) {
                        Text("L: \(displayTemperature(today.temperatureMin))°")
                            .font(.custom("Abel-Regular", size: 18))
                            .foregroundStyle(Color.white.opacity(0.85))
                        
                        Text("•")
                            .font(.custom("Abel-Regular", size: 18))
                            .foregroundStyle(Color.white.opacity(0.5))
                        
                        Text("H: \(displayTemperature(today.temperatureMax))°")
                            .font(.custom("Abel-Regular", size: 18))
                            .foregroundStyle(Color.white.opacity(0.85))
                    }
                }
                
                Text("•")
                    .font(.custom("Abel-Regular", size: 18))
                    .foregroundStyle(Color.white.opacity(0.5))
                
                Text("Feels like \(displayTemperature(Double(viewModel.feelsLike)))°")
                    .font(.custom("Abel-Regular", size: 18))
                    .foregroundStyle(Color.white.opacity(0.85))
            }
            
            // Date - LARGER & WHITE
            Text(viewModel.dateDescription)
                .font(.custom("Amiko-Regular", size: 16))
                .foregroundStyle(Color.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .opacity(isViewLoaded ? 1 : 0)
        .scaleEffect(isViewLoaded ? 1 : 0.96)
        .animation(.easeIn(duration: 0.3), value: isViewLoaded)
    }
    
    // MARK: - Hourly Forecast Section
    
    private var hourlyForecastSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(currentTheme.cardTextColor.opacity(0.6))
                
                Text("HOURLY FORECAST")
                    .font(.caption)
                    .foregroundStyle(currentTheme.cardTextColor.opacity(0.6))
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(viewModel.hourlyForecasts, id: \.hour) { hourly in
                        VStack(spacing: 10) {
                            Text(hourly.hour)
                                .font(.hourlyForecast)
                                .foregroundStyle(currentTheme.cardTextColor.opacity(0.8))
                            
                            Image(systemName: weatherIconForCode(hourly.weatherCode))
                                .font(.system(size: 28))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(currentTheme.cardTextColor)
                                .frame(height: 32)
                            
                            Text("\(displayTemperature(hourly.temperature))°")
                                .font(.hourlyForecast)
                                .fontWeight(.semibold)
                                .foregroundStyle(currentTheme.cardTextColor)
                        }
                        .frame(width: 60)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
        .background(currentTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
        .opacity(isViewLoaded ? 1 : 0)
        .offset(y: isViewLoaded ? 0 : 8)
        .animation(.easeIn(duration: 0.3).delay(0.1), value: isViewLoaded)
    }
    
    // MARK: - Details Grid Section
    
    private var detailsGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            detailCard(icon: "drop.fill", title: "HUMIDITY", value: "\(viewModel.humidity)%")
            detailCard(icon: "wind", title: "WIND", value: "\(viewModel.windSpeed) mph")
            detailCard(icon: "eye.fill", title: "VISIBILITY", value: "\(viewModel.visibility) mi")
            
            // Current Condition card
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(currentTheme.cardTextColor.opacity(0.6))
                    
                    Text("CONDITION")
                        .font(.caption)
                        .foregroundStyle(currentTheme.cardTextColor.opacity(0.6))
                }
                
                Text(viewModel.weatherDescription)
                    .font(.temperatureSmall)
                    .foregroundStyle(currentTheme.cardTextColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(currentTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 20)
        .opacity(isViewLoaded ? 1 : 0)
        .offset(y: isViewLoaded ? 0 : 8)
        .animation(.easeIn(duration: 0.3).delay(0.15), value: isViewLoaded)
    }
    
    private func detailCard(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(currentTheme.cardTextColor.opacity(0.6))
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(currentTheme.cardTextColor.opacity(0.6))
            }
            
            Text(value)
                .font(.temperatureSmall)
                .foregroundStyle(currentTheme.cardTextColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(currentTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Weekly Forecast Section
    
    private var weeklyForecastSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(currentTheme.cardTextColor.opacity(0.6))
                
                Text("7-DAY FORECAST")
                    .font(.caption)
                    .foregroundStyle(currentTheme.cardTextColor.opacity(0.6))
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.dailyForecasts.enumerated()), id: \.offset) { index, daily in
                    HStack(spacing: 16) {
                        Text(daily.dayOfWeek)
                            .font(.weeklyForecast)
                            .foregroundStyle(currentTheme.cardTextColor)
                            .frame(width: 80, alignment: .leading)
                        
                        Spacer()
                        
                        Image(systemName: weatherIconForCode(daily.weatherCode))
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(currentTheme.cardTextColor)
                            .frame(width: 32)
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Text("\(displayTemperature(daily.temperatureMin))°")
                                .font(.forecastDetail)
                                .foregroundStyle(currentTheme.cardTextColor.opacity(0.6))
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            currentTheme.accentColor.opacity(0.4),
                                            currentTheme.primaryColor.opacity(0.6)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 50, height: 4)
                                .cornerRadius(2)
                            
                            Text("\(displayTemperature(daily.temperatureMax))°")
                                .font(.weeklyForecast)
                                .fontWeight(.semibold)
                                .foregroundStyle(currentTheme.cardTextColor)
                        }
                        .frame(width: 140, alignment: .trailing)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    
                    if index < viewModel.dailyForecasts.count - 1 {
                        Divider()
                            .background(currentTheme.cardTextColor.opacity(0.2))
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .background(currentTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
        .opacity(isViewLoaded ? 1 : 0)
        .offset(y: isViewLoaded ? 0 : 8)
        .animation(.easeIn(duration: 0.3).delay(0.2), value: isViewLoaded)
    }
    
    // MARK: - Hamburger Menu Drawer
    
    @ViewBuilder
    func hamburgerMenuBuilder() -> some View {
        if isHamburgerMenuOpen {
            VStack {
                HStack {
                    // Liquid glass menu popup (Carrot-style)
                    VStack(spacing: 0) {
                        // Weather Animation Tester
                        Button(action: {
                            showWeatherTestMenu.toggle()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                isHamburgerMenuOpen = false
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "paintbrush.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.white)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Test Animations")
                                        .font(.custom("Amiko-Regular", size: 16))
                                        .foregroundStyle(Color.white)
                                    
                                    if let testKey = testWeatherKey {
                                        Text("Testing: \(testKey)")
                                            .font(.custom("Amiko-Regular", size: 11))
                                            .foregroundStyle(Color.white.opacity(0.6))
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Divider()
                            .background(Color.white.opacity(0.15))
                            .padding(.horizontal, 16)
                        
                        // Manage Locations
                        Button(action: {
                            showingLocations = true
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                isHamburgerMenuOpen = false
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.white)
                                    .frame(width: 24)
                                
                                Text("Manage Locations")
                                    .font(.custom("Amiko-Regular", size: 16))
                                    .foregroundStyle(Color.white)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Divider()
                            .background(Color.white.opacity(0.15))
                            .padding(.horizontal, 16)
                        
                        // Settings
                        Button(action: {
                            showingSettings = true
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                isHamburgerMenuOpen = false
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.white)
                                    .frame(width: 24)
                                
                                Text("Settings")
                                    .font(.custom("Amiko-Regular", size: 16))
                                    .foregroundStyle(Color.white)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(width: 220)
                    .background {
                        liquidGlassBackground()
                    }
                    .overlay {
                        // Inner glow border
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                            .padding(0.5) // Inner border
                    }
                    .overlay {
                        // Outer stroke for definition
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .padding(.leading, 20)
                    .padding(.top, 68)
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.8, anchor: .topLeading)
                                .combined(with: .opacity)
                                .combined(with: .offset(x: -10, y: -10)),
                            removal: .scale(scale: 0.8, anchor: .topLeading)
                                .combined(with: .opacity)
                                .combined(with: .offset(x: -10, y: -10))
                        )
                    )
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    @ViewBuilder
    private func liquidGlassBackground() -> some View {
        // iOS 26+ Liquid Glass Effect
        if #available(iOS 26.0, *) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        } else if #available(iOS 18.0, *) {
            // iOS 18 fallback with MeshGradient
            ios18GlassEffect()
        } else {
            // iOS 17 and below fallback
            ios17GlassEffect()
        }
    }
    
    @available(iOS 18.0, *)
    @ViewBuilder
    private func ios18GlassEffect() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
            
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: [
                    .white.opacity(0.4), .white.opacity(0.3), .white.opacity(0.4),
                    .white.opacity(0.2), .white.opacity(0.1), .white.opacity(0.2),
                    .white.opacity(0.3), .white.opacity(0.2), .white.opacity(0.3)
                ]
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .blendMode(.plusLighter)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.5),
                            .clear,
                            .white.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blendMode(.overlay)
        }
    }
    
    @ViewBuilder
    private func ios17GlassEffect() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
            
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.black.opacity(0.05)
                        ],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
        }
    }
    
    private func weatherIconForCode(_ code: Int) -> String {
        switch code {
        case 0: return "sun.max.fill"
        case 1: return "cloud.sun.fill"
        case 2: return "cloud.fill"
        case 3: return "smoke.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51, 53, 55, 56, 57: return "cloud.drizzle.fill"
        case 61, 63, 65, 66, 67, 80, 81, 82: return "cloud.rain.fill"
        case 71, 73, 75, 77, 85, 86: return "cloud.snow.fill"
        case 95, 96, 99: return "cloud.bolt.rain.fill"
        default: return "cloud.fill"
        }
    }
}

#Preview("Sunny") {
    HomeView(viewModel: ViewModelFactory().makeHomeViewModel())
        .environment(\.weatherTheme, .sunny)
}

#Preview("Rainy") {
    HomeView(viewModel: ViewModelFactory().makeHomeViewModel())
        .environment(\.weatherTheme, .rainy)
}

#Preview("Snowy") {
    HomeView(viewModel: ViewModelFactory().makeHomeViewModel())
        .environment(\.weatherTheme, .snowy)
}
