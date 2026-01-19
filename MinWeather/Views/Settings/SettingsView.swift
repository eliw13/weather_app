//
//  SettingsView.swift
//  MinWeather
//
//  Settings main view with sections
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
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
        case "purple": return .purple
        case "blue": return .blue
        case "pink": return .pink
        case "teal": return .teal
        case "orange": return .orange
        case "green": return .green
        case "indigo": return .indigo
        case "red": return .red
        case "yellow": return .yellow
        case "cyan": return .cyan
        case "mint": return .mint
        default: return .purple
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background matching main app
                (isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.12) : Color.white)
                    .ignoresSafeArea()
                
                Circle()
                    .fill(getColor(from: backgroundColorOne).opacity(isDarkMode ? 0.4 : 1))
                    .frame(width: 320, height: 320)
                    .blur(radius: 128)
                    .offset(x: -128, y: 144)
                
                Rectangle()
                    .fill(getColor(from: backgroundColorTwo).opacity(isDarkMode ? 0.4 : 1))
                    .frame(width: 320, height: 320)
                    .blur(radius: 128)
                    .offset(x: 144, y: -128)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // General Settings
                        NavigationLink(destination: GeneralSettingsView()) {
                            SettingsRowView(
                                icon: "gearshape.fill",
                                title: "General",
                                subtitle: "Units, location, preferences"
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // Display Settings
                        NavigationLink(destination: DisplaySettingsView()) {
                            SettingsRowView(
                                icon: "paintbrush.fill",
                                title: "Display",
                                subtitle: "Theme and appearance"
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // Feedback Section
                        VStack(spacing: 12) {
                            // Report a Problem
                            Button(action: {
                                reportProblem()
                            }) {
                                SettingsRowView(
                                    icon: "exclamationmark.bubble.fill",
                                    title: "Report a Problem",
                                    subtitle: "Send us feedback"
                                )
                            }
                            .buttonStyle(.plain)
                            
                            // Rate on App Store
                            Button(action: {
                                rateOnAppStore()
                            }) {
                                SettingsRowView(
                                    icon: "star.fill",
                                    title: "Rate on App Store",
                                    subtitle: "Share your experience"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(themePreference == "system" ? nil : (themePreference == "dark" ? .dark : .light))
    }
    
    // MARK: - Feedback Actions
    
    private func reportProblem() {
        let email = "testemail@gmail.com"
        let subject = "MinWeather - Problem Report"
        let body = "Please describe the issue you're experiencing:"
        
        let urlString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateOnAppStore() {
        // TODO: Replace with actual App Store link when published
        if let url = URL(string: "https://www.google.com") {
            UIApplication.shared.open(url)
        }
    }
}

// Reusable Settings Row Component
struct SettingsRowView: View {
    let icon: String
    let title: String
    let subtitle: String
    @AppStorage("themePreference") private var themePreference: String = "system"
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
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Manrope", size: 17))
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.custom("Manrope", size: 13))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    SettingsView()
}
