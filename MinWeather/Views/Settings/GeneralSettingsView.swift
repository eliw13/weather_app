//
//  GeneralSettingsView.swift
//  MinWeather
//
//  General settings: Units and Location
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("temperatureUnit") private var temperatureUnit: String = "fahrenheit"
    @AppStorage("windSpeedUnit") private var windSpeedUnit: String = "mph"
    @AppStorage("distanceUnit") private var distanceUnit: String = "miles"
    @AppStorage("defaultLocation") private var defaultLocation: String = "GPS"
    
    @State private var showingLocationPicker = false
    @State private var customLocation: String = ""
    
    var body: some View {
        ZStack {
            // Background matching main app
            (isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.12) : Color.white)
                .ignoresSafeArea()
            
            Circle()
                .fill(.purple.opacity(isDarkMode ? 0.4 : 1))
                .frame(width: 320, height: 320)
                .blur(radius: 128)
                .offset(x: -128, y: 144)
            
            Rectangle()
                .fill(.blue.opacity(isDarkMode ? 0.4 : 1))
                .frame(width: 320, height: 320)
                .blur(radius: 128)
                .offset(x: 144, y: -128)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Units Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("UNITS")
                            .font(.custom("Manrope", size: 13))
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        VStack(spacing: 0) {
                            // Temperature Unit
                            SettingPickerRow(
                                title: "Temperature",
                                icon: "thermometer.medium",
                                selection: $temperatureUnit,
                                options: [
                                    ("fahrenheit", "°F", "Fahrenheit"),
                                    ("celsius", "°C", "Celsius")
                                ]
                            )
                            
                            Divider()
                                .padding(.horizontal, 16)
                            
                            // Wind Speed Unit
                            SettingPickerRow(
                                title: "Wind Speed",
                                icon: "wind",
                                selection: $windSpeedUnit,
                                options: [
                                    ("mph", "mph", "Miles per hour"),
                                    ("kmh", "km/h", "Kilometers per hour"),
                                    ("ms", "m/s", "Meters per second"),
                                    ("knots", "knots", "Knots")
                                ]
                            )
                            
                            Divider()
                                .padding(.horizontal, 16)
                            
                            // Distance Unit
                            SettingPickerRow(
                                title: "Distance",
                                icon: "ruler",
                                selection: $distanceUnit,
                                options: [
                                    ("miles", "mi", "Miles"),
                                    ("kilometers", "km", "Kilometers")
                                ]
                            )
                        }
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                    }
                    
                    // Location Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("LOCATION")
                            .font(.custom("Manrope", size: 13))
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            Button(action: {
                                showingLocationPicker = true
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: defaultLocation == "GPS" ? "location.fill" : "mappin.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(.blue)
                                        .frame(width: 28)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Default Location")
                                            .font(.custom("Manrope", size: 16))
                                            .fontWeight(.medium)
                                            .foregroundStyle(.primary)
                                        
                                        Text(defaultLocation == "GPS" ? "Current location (GPS)" : defaultLocation)
                                            .font(.custom("Manrope", size: 14))
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(16)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("General")
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView(selectedLocation: $defaultLocation)
        }
    }
}

// Reusable Setting Picker Row
struct SettingPickerRow: View {
    let title: String
    let icon: String
    @Binding var selection: String
    let options: [(id: String, display: String, description: String)]
    
    @State private var showingPicker = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        Button(action: {
            showingPicker = true
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.blue)
                    .frame(width: 28)
                
                Text(title)
                    .font(.custom("Manrope", size: 16))
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(options.first(where: { $0.id == selection })?.display ?? "")
                    .font(.custom("Manrope", size: 16))
                    .foregroundStyle(.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingPicker) {
            NavigationStack {
                ZStack {
                    (isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.12) : Color.white)
                        .ignoresSafeArea()
                    
                    List {
                        ForEach(options, id: \.id) { option in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selection = option.id
                                }
                                showingPicker = false
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(option.display)
                                            .font(.custom("Manrope", size: 17))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.primary)
                                        
                                        Text(option.description)
                                            .font(.custom("Manrope", size: 14))
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selection == option.id {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(.blue)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingPicker = false
                        }
                        .fontWeight(.semibold)
                    }
                }
                .preferredColorScheme(isDarkMode ? .dark : .light)
            }
        }
    }
}

// Location Picker View
struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLocation: String
    @State private var searchText: String = ""
    @State private var isUsingGPS: Bool = true
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                (isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.12) : Color.white)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // GPS Option
                    Button(action: {
                        selectedLocation = "GPS"
                        dismiss()
                    }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(.blue.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "location.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Location")
                                    .font(.custom("Manrope", size: 17))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                
                                Text("Use GPS to get your location")
                                    .font(.custom("Manrope", size: 14))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedLocation == "GPS" {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding(16)
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    
                    // Custom Location Search
                    VStack(alignment: .leading, spacing: 12) {
                        Text("OR ENTER A LOCATION")
                            .font(.custom("Manrope", size: 13))
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            
                            TextField("Search for a city...", text: $searchText)
                                .font(.custom("Manrope", size: 16))
                                .textFieldStyle(.plain)
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(12)
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                selectedLocation = searchText
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundStyle(.blue)
                                    
                                    Text("Set location to \"\(searchText)\"")
                                        .font(.custom("Manrope", size: 16))
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                        .foregroundStyle(.blue)
                                }
                                .padding(16)
                                .background(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Choose Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

#Preview {
    GeneralSettingsView()
}
