//
//  HomeView.swift
//  MinWeather
//
//  Created by Thiago Souza on 07/09/24.
//  Updated with liquid glass morphing menu animation
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    @StateObject var viewModel: HomeViewModel
    @State var isViewLoaded: Bool = false
    @State private var isMenuOpen: Bool = false
    @State private var isFahrenheit: Bool = true // Temperature unit toggle
    @AppStorage("themePreference") private var themePreference: String = "system"
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var showingSettings: Bool = false
    @State private var showingLocations: Bool = false
    @Namespace private var locationTransition
    @State private var selectedLocationName: String?
    
    // Computed property to determine actual dark mode state
    var isDarkMode: Bool {
        switch themePreference {
        case "dark":
            return true
        case "light":
            return false
        default: // "system"
            return systemColorScheme == .dark
        }
    }
    
    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // Helper to convert temperature based on unit
    private func displayTemperature(_ celsius: Double) -> Int {
        if isFahrenheit {
            return Int((celsius * 9/5) + 32)
        } else {
            return Int(celsius)
        }
    }
    
    private var temperatureUnit: String {
        isFahrenheit ? "°F" : "°C"
    }
    
    var body: some View {
        ZStack {
            VStack {
                switch self.viewModel.state {
                case .loading: self.loadingViewBuilder()
                case .loaded: self.loadedViewBuilder()
                case .error: self.errorViewBuilder()
                }
            }
            .onAppear {
                self.viewModel.fetchData()
            }
            .onChange(of: self.viewModel.state, { _, newValue in
                if newValue == .loaded {
                    withAnimation {
                        self.isViewLoaded = true
                    }
                }
            })
            .modifier(BackgroundViewModifier())
            .matchedGeometryEffect(id: "weatherView", in: locationTransition, isSource: !showingLocations)
            
            // Dimmed overlay when menu is open
            if isMenuOpen {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            isMenuOpen = false
                        }
                    }
                    .transition(.opacity)
            }
            
            // Liquid Glass Menu
            menuBuilder()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
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
    
    @ViewBuilder
    func loadingViewBuilder() -> some View {
        var bounceValue = 0
        VStack(alignment: .center) {
            Image(systemName: "cloud.fill")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .symbolEffect(.pulse, options: .speed(1.6))
                .frame(width: 96, height: 96)
            
            Text("LOADING...")
                .font(.custom("Manrope", size: 12))
                .fontWeight(.black)
            
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            bounceValue += 1
        }
    }
    
    @ViewBuilder
    func loadedViewBuilder() -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                loadedHeaderBuilder()
                loadedCurrentWeatherCardBuilder()
                loadedHourlyForecastCardBuilder()
                loadedDetailsCardsBuilder()
                loadedWeeklyForecastCardBuilder()
            }
            .padding(.bottom, 20)
        }
    }
    
    @ViewBuilder
    func errorViewBuilder() -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text("I'M SORRY.")
                .font(.custom("Manrope", size: 24))
                .fontWeight(.black)
            
            Text("SOMETHING WENT WRONG!")
                .font(.custom("Manrope", size: 16))
                .fontWeight(.medium)
            
            Text("TRY AGAIN LATER.")
                .font(.custom("Manrope", size: 16))
                .fontWeight(.black)
        }
        .frame(maxHeight: .infinity)
    }
    
    @ViewBuilder
    func loadedHeaderBuilder() -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(viewModel.cityName)
                        .font(.custom("Manrope", size: 28))
                        .fontWeight(.bold)
                    
                    // Location icon button
                    Button(action: {
                        showingLocations = true
                    }) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.blue)
                    }
                }
                
                Text(viewModel.dateDescription)
                    .font(.custom("Manrope", size: 14))
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Three dots menu button (hidden when menu is open to create morphing effect)
            if !isMenuOpen {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.primary.opacity(0.1))
                        )
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .opacity(self.isViewLoaded ? 1 : 0)
        .offset(y: self.isViewLoaded ? 0 : -8)
        .animation(.easeIn(duration: 0.3), value: self.isViewLoaded)
    }
    
    @ViewBuilder
    func loadedCurrentWeatherCardBuilder() -> some View {
        VStack(spacing: 12) {
            // Small weather icon
            Image(systemName: weatherIconForCode(viewModel.weatherCode))
                .font(.system(size: 40))
                .symbolRenderingMode(.multicolor)
                .frame(height: 44)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(displayTemperature(Double(self.viewModel.temperature)))")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                Text(temperatureUnit)
                    .font(.system(size: 40, weight: .medium, design: .rounded))
                    .offset(y: -12)
            }
            
            Text(self.viewModel.weatherDescription)
                .font(.custom("Manrope", size: 18))
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .opacity(self.isViewLoaded ? 1 : 0)
        .scaleEffect(self.isViewLoaded ? 1 : 0.96)
        .animation(.easeIn(duration: 0.3), value: self.isViewLoaded)
    }
    
    @ViewBuilder
    func loadedHourlyForecastCardBuilder() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                Text("HOURLY FORECAST")
                    .font(.custom("Manrope", size: 14))
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Array(viewModel.hourlyForecasts.enumerated()), id: \.offset) { index, hourly in
                        VStack(spacing: 12) {
                            Text(hourly.hour)
                                .font(.custom("Manrope", size: 15))
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            Image(systemName: weatherIconForCode(hourly.weatherCode))
                                .font(.system(size: 28))
                                .symbolRenderingMode(.multicolor)
                                .frame(height: 32)
                            
                            Text("\(displayTemperature(hourly.temperature))°")
                                .font(.custom("Manrope", size: 17))
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        }
                        .frame(width: 60)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
        .opacity(self.isViewLoaded ? 1 : 0)
        .offset(y: self.isViewLoaded ? 0 : 8)
        .animation(.easeIn(duration: 0.3).delay(0.1), value: self.isViewLoaded)
    }
    
    // Helper function to get SF Symbol for weather code
    func weatherIconForCode(_ code: Int) -> String {
        switch code {
        case 0:
            return "sun.max.fill"
        case 1:
            return "cloud.sun.fill"
        case 2:
            return "cloud.fill"
        case 3:
            return "smoke.fill"
        case 45, 48:
            return "cloud.fog.fill"
        case 51, 53, 55, 56, 57:
            return "cloud.drizzle.fill"
        case 61, 63, 65, 66, 67, 80, 81, 82:
            return "cloud.rain.fill"
        case 71, 73, 75, 77, 85, 86:
            return "cloud.snow.fill"
        case 95, 96, 99:
            return "cloud.bolt.rain.fill"
        default:
            return "cloud.fill"
        }
    }
    
    @ViewBuilder
    func loadedDetailsCardsBuilder() -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            detailCardBuilder(
                icon: "drop.fill",
                title: "HUMIDITY",
                value: "\(self.viewModel.humidity)%"
            )
            
            detailCardBuilder(
                icon: "wind",
                title: "WIND SPEED",
                value: "\(self.viewModel.windSpeed) mph"
            )
            
            detailCardBuilder(
                icon: "eye.fill",
                title: "VISIBILITY",
                value: "\(self.viewModel.visibility) mi"
            )
            
            detailCardBuilder(
                icon: "thermometer.medium",
                title: "FEELS LIKE",
                value: "\(displayTemperature(Double(self.viewModel.feelsLike)))\(temperatureUnit)"
            )
        }
        .padding(.horizontal, 20)
        .opacity(self.isViewLoaded ? 1 : 0)
        .offset(y: self.isViewLoaded ? 0 : 8)
        .animation(.easeIn(duration: 0.3).delay(0.15), value: self.isViewLoaded)
    }
    
    @ViewBuilder
    func loadedWeeklyForecastCardBuilder() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                Text("7-DAY FORECAST")
                    .font(.custom("Manrope", size: 14))
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.dailyForecasts.enumerated()), id: \.offset) { index, daily in
                    HStack(spacing: 16) {
                        // Day of week
                        Text(daily.dayOfWeek)
                            .font(.custom("Manrope", size: 17))
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .frame(width: 50, alignment: .leading)
                        
                        Spacer()
                        
                        // Weather icon
                        Image(systemName: weatherIconForCode(daily.weatherCode))
                            .font(.system(size: 24))
                            .symbolRenderingMode(.multicolor)
                            .frame(width: 40)
                        
                        Spacer()
                        
                        // Temperature range
                        HStack(spacing: 8) {
                            Text("\(displayTemperature(daily.temperatureMin))°")
                                .font(.custom("Manrope", size: 17))
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            // Range indicator
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.blue.opacity(0.5),
                                            Color.orange.opacity(0.5)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 40, height: 4)
                                .cornerRadius(2)
                            
                            Text("\(displayTemperature(daily.temperatureMax))°")
                                .font(.custom("Manrope", size: 17))
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }
                        .frame(width: 140, alignment: .trailing)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    
                    if index < viewModel.dailyForecasts.count - 1 {
                        Divider()
                            .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.bottom, 12)
        }
        .background(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
        .opacity(self.isViewLoaded ? 1 : 0)
        .offset(y: self.isViewLoaded ? 0 : 8)
        .animation(.easeIn(duration: 0.3).delay(0.2), value: self.isViewLoaded)
    }
    
    @ViewBuilder
    func detailCardBuilder(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                Text(title)
                    .font(.custom("Manrope", size: 12))
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
            
            Text(value)
                .font(.custom("Manrope", size: 24))
                .fontWeight(.bold)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Liquid Glass Menu with Morphing Animation
    @ViewBuilder
    func menuBuilder() -> some View {
        if isMenuOpen {
            VStack {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Temperature Unit: Celsius
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isFahrenheit = false
                            }
                        }) {
                            HStack(spacing: 16) {
                                Text("°C")
                                    .font(.custom("Manrope", size: 17))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if !isFahrenheit {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.blue)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Divider()
                            .padding(.horizontal, 12)
                            .opacity(0.5)
                        
                        // Temperature Unit: Fahrenheit
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isFahrenheit = true
                            }
                        }) {
                            HStack(spacing: 16) {
                                Text("°F")
                                    .font(.custom("Manrope", size: 17))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if isFahrenheit {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.blue)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Divider()
                            .padding(.horizontal, 12)
                            .opacity(0.5)
                        
                        // Settings Option
                        Button(action: {
                            showingSettings = true
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                isMenuOpen = false
                            }
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 17))
                                    .foregroundStyle(.primary)
                                    .frame(width: 20)
                                
                                Text("Settings")
                                    .font(.custom("Manrope", size: 17))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(minWidth: 200)
                    .background {
                        // Liquid glass effect with frosted background
                        ZStack {
                            // Base blur layer
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                            
                            // Gradient overlay for liquid glass effect
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.4),
                                            Color.white.opacity(0.1),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .compositingGroup()
                    }
                    .overlay {
                        // Border with gradient for extra shine
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }
                    // Layered shadows for depth
                    .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: 15)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.trailing, 20)
                    .padding(.top, 68)
                }
                
                Spacer()
            }
            // Morphing animation from button to menu
            .transition(
                .asymmetric(
                    insertion: .scale(scale: 0.2, anchor: .topTrailing)
                        .combined(with: .opacity)
                        .combined(with: .offset(x: 15, y: -15)),
                    removal: .scale(scale: 0.2, anchor: .topTrailing)
                        .combined(with: .opacity)
                        .combined(with: .offset(x: 15, y: -15))
                )
            )
        }
    }
}

#Preview {
    HomeView(viewModel: ViewModelFactory().makeHomeViewModel())
}
