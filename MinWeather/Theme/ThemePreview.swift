//
//  ThemePreview.swift
//  MinWeather
//
//  Preview all weather themes for testing
//

import SwiftUI

struct ThemePreviewView: View {
    let themes: [(name: String, theme: WeatherTheme)] = [
        ("Sunny", .sunny),
        ("Cloudy", .cloudy),
        ("Rainy", .rainy),
        ("Drizzle", .drizzle),
        ("Thunderstorm", .thunderstorm),
        ("Snowy", .snowy),
        ("Foggy", .foggy),
        ("Hazy", .hazy),
        ("Severe", .severe)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(themes, id: \.name) { item in
                    ThemeCard(name: item.name, theme: item.theme)
                }
            }
            .padding()
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.12))
    }
}

struct ThemeCard: View {
    let name: String
    let theme: WeatherTheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Theme preview
            ZStack {
                // Background with gradient
                theme.backgroundColor
                
                LinearGradient(
                    colors: [
                        theme.primaryColor.opacity(0.3),
                        theme.secondaryColor.opacity(0.2),
                        theme.backgroundColor.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Sample content
                VStack(spacing: 12) {
                    Text("72°")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(theme.textColor)
                    
                    Text(name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(theme.textColor)
                    
                    HStack(spacing: 16) {
                        VStack {
                            Text("Primary")
                                .font(.caption)
                            Circle()
                                .fill(theme.primaryColor)
                                .frame(width: 40, height: 40)
                        }
                        
                        VStack {
                            Text("Secondary")
                                .font(.caption)
                            Circle()
                                .fill(theme.secondaryColor)
                                .frame(width: 40, height: 40)
                        }
                        
                        VStack {
                            Text("Accent")
                                .font(.caption)
                            Circle()
                                .fill(theme.accentColor)
                                .frame(width: 40, height: 40)
                        }
                    }
                    .foregroundStyle(theme.textColor.opacity(0.8))
                }
                .padding()
            }
            .frame(height: 250)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    ThemePreviewView()
}
