//
//  DisplaySettingsView.swift
//  MinWeather
//
//  Display settings: Theme and appearance
//

import SwiftUI

struct DisplaySettingsView: View {
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
                VStack(spacing: 24) {
                    // Theme Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("APPEARANCE")
                            .font(.custom("Manrope", size: 13))
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        VStack(spacing: 0) {
                            ThemePickerRow(
                                selection: $themePreference,
                                systemColorScheme: systemColorScheme
                            )
                        }
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                    }
                    
                    // Background Colors Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("BACKGROUND COLORS")
                            .font(.custom("Manrope", size: 13))
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            Text("Select two colors for your background")
                                .font(.custom("Manrope", size: 15))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            BackgroundColorPicker(
                                colorOne: $backgroundColorOne,
                                colorTwo: $backgroundColorTwo
                            )
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 16)
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("Display")
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(themePreference == "system" ? nil : (themePreference == "dark" ? .dark : .light))
    }
}

// Background Color Picker Component
struct BackgroundColorPicker: View {
    @Binding var colorOne: String
    @Binding var colorTwo: String
    
    // Curated color palette
    let availableColors: [(id: String, name: String, color: Color)] = [
        ("purple", "Purple", .purple),
        ("blue", "Blue", .blue),
        ("pink", "Pink", .pink),
        ("teal", "Teal", .teal),
        ("orange", "Orange", .orange),
        ("green", "Green", .green),
        ("indigo", "Indigo", .indigo),
        ("red", "Red", .red),
        ("yellow", "Yellow", .yellow),
        ("cyan", "Cyan", .cyan),
        ("mint", "Mint", .mint)
    ]
    
    var selectedColors: Set<String> {
        var colors = Set<String>()
        if !colorOne.isEmpty {
            colors.insert(colorOne)
        }
        if !colorTwo.isEmpty {
            colors.insert(colorTwo)
        }
        return colors
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Color Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(availableColors, id: \.id) { colorOption in
                    ColorSelectionButton(
                        colorId: colorOption.id,
                        colorName: colorOption.name,
                        color: colorOption.color,
                        isSelected: selectedColors.contains(colorOption.id),
                        isDisabled: selectedColors.count >= 2 && !selectedColors.contains(colorOption.id),
                        onTap: {
                            handleColorTap(colorOption.id)
                        }
                    )
                }
            }
            
            // Selected colors display
            HStack(spacing: 12) {
                Text("Selected:")
                    .font(.custom("Manrope", size: 14))
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    if let color1 = availableColors.first(where: { $0.id == colorOne }) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(color1.color)
                                .frame(width: 16, height: 16)
                            Text(color1.name)
                                .font(.custom("Manrope", size: 14))
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.primary.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    
                    if let color2 = availableColors.first(where: { $0.id == colorTwo }) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(color2.color)
                                .frame(width: 16, height: 16)
                            Text(color2.name)
                                .font(.custom("Manrope", size: 14))
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.primary.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                
                Spacer()
            }
        }
    }
    
    private func handleColorTap(_ colorId: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedColors.contains(colorId) {
                // Deselect: Remove from selection
                if colorOne == colorId {
                    colorOne = colorTwo.isEmpty ? "" : colorTwo
                    colorTwo = ""
                } else if colorTwo == colorId {
                    colorTwo = ""
                }
            } else {
                // Select: Add to available slot
                if colorOne.isEmpty {
                    colorOne = colorId
                } else if colorTwo.isEmpty {
                    colorTwo = colorId
                } else {
                    // Both slots full, replace the second color
                    colorTwo = colorId
                }
            }
        }
    }
}

// Individual Color Selection Button
struct ColorSelectionButton: View {
    let colorId: String
    let colorName: String
    let color: Color
    let isSelected: Bool
    let isDisabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            if !isDisabled {
                onTap()
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    // Color circle
                    Circle()
                        .fill(color)
                        .frame(width: 50, height: 50)
                        .overlay {
                            Circle()
                                .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                        }
                        .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    // Checkmark overlay
                    if isSelected {
                        Circle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                }
                
                Text(colorName)
                    .font(.custom("Manrope", size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(isDisabled ? Color.secondary.opacity(0.5) : Color.primary)
            }
            .opacity(isDisabled ? 0.5 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

// Theme Picker Row Component
struct ThemePickerRow: View {
    @Binding var selection: String
    let systemColorScheme: ColorScheme
    @State private var showingPicker = false
    
    var isDarkMode: Bool {
        switch selection {
        case "dark":
            return true
        case "light":
            return false
        default:
            return systemColorScheme == .dark
        }
    }
    
    let themeOptions: [(id: String, display: String, description: String, icon: String)] = [
        ("system", "System Default", "Match your device settings", "iphone"),
        ("light", "Light", "Always use light theme", "sun.max.fill"),
        ("dark", "Dark", "Always use dark theme", "moon.fill")
    ]
    
    var currentTheme: (id: String, display: String, description: String, icon: String) {
        themeOptions.first(where: { $0.id == selection }) ?? themeOptions[0]
    }
    
    var body: some View {
        Button(action: {
            showingPicker = true
        }) {
            HStack(spacing: 16) {
                Image(systemName: currentTheme.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.blue)
                    .frame(width: 28)
                
                Text("Theme")
                    .font(.custom("Manrope", size: 16))
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(currentTheme.display)
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
                        ForEach(themeOptions, id: \.id) { option in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selection = option.id
                                }
                                showingPicker = false
                            }) {
                                HStack(spacing: 16) {
                                    // Icon with background
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: option.icon)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(.blue)
                                    }
                                    
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
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundStyle(.blue)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                .navigationTitle("Theme")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingPicker = false
                        }
                        .fontWeight(.semibold)
                    }
                }
                .preferredColorScheme(selection == "system" ? nil : (selection == "dark" ? .dark : .light))
            }
        }
    }
}

#Preview {
    DisplaySettingsView()
}
