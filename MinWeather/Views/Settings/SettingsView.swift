//
//  SettingsView.swift
//  MinWeather
//
//  Settings main view with sections
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        NavigationStack {
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
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

// Reusable Settings Row Component
struct SettingsRowView: View {
    let icon: String
    let title: String
    let subtitle: String
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
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
