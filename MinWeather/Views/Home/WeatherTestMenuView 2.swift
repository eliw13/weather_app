//
//  WeatherTestMenuView.swift
//  MinWeather
//
//  Weather animation tester menu
//

import SwiftUI

struct WeatherTestMenuView: View {
    @Binding var testWeatherKey: String?
    @Environment(\.dismiss) private var dismiss
    
    let weatherOptions: [(emoji: String, name: String, key: String)] = [
        ("🌤️", "Clear/Sunny", "Clear"),
        ("☁️", "Cloudy", "Clouds"),
        ("🌧️", "Rain", "Rain"),
        ("🌦️", "Drizzle", "Drizzle"),
        ("⛈️", "Thunderstorm", "Thunderstorm"),
        ("❄️", "Snow", "Snow"),
        ("🌫️", "Fog/Mist", "Mist")
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(weatherOptions, id: \.key) { option in
                        Button(action: {
                            testWeatherKey = option.key
                            dismiss()
                        }) {
                            HStack {
                                Text(option.emoji)
                                    .font(.system(size: 24))
                                
                                Text(option.name)
                                    .font(.custom("Amiko-Regular", size: 18))
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if testWeatherKey == option.key {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Test Weather Animations")
                }
                
                Section {
                    Button(action: {
                        testWeatherKey = nil
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset to Actual Weather")
                                .font(.custom("Amiko-Regular", size: 18))
                        }
                        .foregroundStyle(testWeatherKey == nil ? .gray : .blue)
                    }
                    .disabled(testWeatherKey == nil)
                }
            }
            .navigationTitle("Test Animations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
