//
//  DisplaySettingsView.swift
//  MinWeather
//
//  Display settings: Theme and appearance
//

import SwiftUI

struct DisplaySettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
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
                    // Theme Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("THEME")
                            .font(.custom("Manrope", size: 13))
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 16) {
                                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.blue)
                                    .frame(width: 28)
                                
                                Text("Dark Mode")
                                    .font(.custom("Manrope", size: 16))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $isDarkMode)
                                    .labelsHidden()
                            }
                            .padding(16)
                        }
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                    }
                    
                    // More display options can be added here later
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("Display")
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    DisplaySettingsView()
}
