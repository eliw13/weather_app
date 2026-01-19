//
//  BackgroundViewModifier.swift
//  MinWeather
//
//  Created by Thiago Souza on 08/09/24.
//  Updated with Theme Preference and Custom Background Colors support
//

import SwiftUI

struct BackgroundViewModifier: ViewModifier {
    @AppStorage("themePreference") private var themePreference: String = "system"
    @AppStorage("backgroundColorOne") private var backgroundColorOne: String = "purple"
    @AppStorage("backgroundColorTwo") private var backgroundColorTwo: String = "blue"
    @Environment(\.colorScheme) private var systemColorScheme
    
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
    
    // Map color string to Color
    func getColor(from colorId: String) -> Color {
        switch colorId {
        case "purple":
            return .purple
        case "blue":
            return .blue
        case "pink":
            return .pink
        case "teal":
            return .teal
        case "orange":
            return .orange
        case "green":
            return .green
        case "indigo":
            return .indigo
        case "red":
            return .red
        case "yellow":
            return .yellow
        case "cyan":
            return .cyan
        case "mint":
            return .mint
        default:
            return .purple
        }
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            // Base background color
            (isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.12) : Color.white)
                .ignoresSafeArea()
            
            // First color accent (circle)
            Circle()
                .fill(getColor(from: backgroundColorOne).opacity(isDarkMode ? 0.4 : 1))
                .frame(width: 320, height: 320)
                .blur(radius: 128)
                .offset(x: -128, y: 144)
            
            // Second color accent (rectangle)
            Rectangle()
                .fill(getColor(from: backgroundColorTwo).opacity(isDarkMode ? 0.4 : 1))
                .frame(width: 320, height: 320)
                .blur(radius: 128)
                .offset(x: 144, y: -128)
            
            content
                .padding()
                .foregroundStyle(isDarkMode ? .white : .black)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .preferredColorScheme(themePreference == "system" ? nil : (themePreference == "dark" ? .dark : .light))
    }
}
