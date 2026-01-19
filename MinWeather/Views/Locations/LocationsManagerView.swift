//
//  LocationsManagerView.swift
//  MinWeather
//
//  Manage saved locations
//

import SwiftUI

struct SavedLocation: Identifiable, Codable {
    let id: UUID
    var name: String
    var isDefault: Bool
    
    init(id: UUID = UUID(), name: String, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.isDefault = isDefault
    }
}

struct LocationsManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("themePreference") private var themePreference: String = "system"
    @AppStorage("backgroundColorOne") private var backgroundColorOne: String = "purple"
    @AppStorage("backgroundColorTwo") private var backgroundColorTwo: String = "blue"
    @AppStorage("savedLocations") private var savedLocationsData: Data = Data()
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var savedLocations: [SavedLocation] = []
    @State private var showingAddLocation = false
    @State private var selectedLocation: SavedLocation?
    
    let namespace: Namespace.ID
    let onLocationSelected: (String) -> Void
    
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
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Locations")
                        .font(.custom("Manrope", size: 34))
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.custom("Manrope", size: 17))
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)
                
                // Locations List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(savedLocations) { location in
                            LocationRowView(
                                location: location,
                                onDelete: location.isDefault ? nil : {
                                    deleteLocation(location)
                                },
                                onTap: {
                                    selectLocation(location)
                                }
                            )
                            .matchedGeometryEffect(id: location.isDefault ? "weatherView" : "location_\(location.id)", in: namespace, isSource: showingAddLocation == false)
                        }
                    }
                    .padding(20)
                }
                
                // Add Location Button
                Button(action: {
                    showingAddLocation = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                        
                        Text("Add Location")
                            .font(.custom("Manrope", size: 17))
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(themePreference == "system" ? nil : (themePreference == "dark" ? .dark : .light))
        .onAppear {
            loadLocations()
        }
        .sheet(isPresented: $showingAddLocation) {
            AddLocationView(onAdd: { newLocation in
                addLocation(newLocation)
            })
        }
    }
    
    // MARK: - Location Management
    
    private func loadLocations() {
        if let decoded = try? JSONDecoder().decode([SavedLocation].self, from: savedLocationsData) {
            savedLocations = decoded
        } else {
            // Create default location
            savedLocations = [
                SavedLocation(name: "Current Location", isDefault: true)
            ]
            saveLocations()
        }
    }
    
    private func saveLocations() {
        if let encoded = try? JSONEncoder().encode(savedLocations) {
            savedLocationsData = encoded
        }
    }
    
    private func addLocation(_ location: SavedLocation) {
        savedLocations.append(location)
        saveLocations()
    }
    
    private func deleteLocation(_ location: SavedLocation) {
        savedLocations.removeAll { $0.id == location.id }
        saveLocations()
    }
    
    private func selectLocation(_ location: SavedLocation) {
        print("📍 Selected location: \(location.name)")
        onLocationSelected(location.name)
        dismiss()
    }
}

// Location Row View
struct LocationRowView: View {
    let location: SavedLocation
    let onDelete: (() -> Void)?
    let onTap: () -> Void
    
    @AppStorage("themePreference") private var themePreference: String = "system"
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var showingDeleteButton = false
    
    var isDarkMode: Bool {
        switch themePreference {
        case "dark":
            return true
        case "light":
            return false
        default:
            return systemColorScheme == .dark
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Location Icon
                ZStack {
                    Circle()
                        .fill(location.isDefault ? Color.blue.opacity(0.15) : Color.primary.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: location.isDefault ? "location.fill" : "mappin.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(location.isDefault ? .blue : .primary)
                }
                
                // Location Name
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.custom("Manrope", size: 17))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    if location.isDefault {
                        Text("Default location")
                            .font(.custom("Manrope", size: 13))
                            .foregroundStyle(.secondary)
                    }
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
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            if onDelete != nil {
                Button(role: .destructive, action: {
                    onDelete?()
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if onDelete != nil {
                Button(role: .destructive, action: {
                    onDelete?()
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

// Add Location View
struct AddLocationView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("themePreference") private var themePreference: String = "system"
    @AppStorage("backgroundColorOne") private var backgroundColorOne: String = "purple"
    @AppStorage("backgroundColorTwo") private var backgroundColorTwo: String = "blue"
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var searchText: String = ""
    @State private var searchResults: [String] = []
    @FocusState private var isSearchFocused: Bool
    
    let onAdd: (SavedLocation) -> Void
    
    var isDarkMode: Bool {
        switch themePreference {
        case "dark":
            return true
        case "light":
            return false
        default:
            return systemColorScheme == .dark
        }
    }
    
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
                (isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.12) : Color.white)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Search Field
                    VStack(spacing: 12) {
                        SearchFieldView(
                            searchText: $searchText,
                            isSearchFocused: $isSearchFocused,
                            isDarkMode: isDarkMode,
                            onSearch: performSearch
                        )
                        
                        // Search Button
                        if !searchText.isEmpty && searchResults.isEmpty {
                            Button(action: {
                                performSearch(searchText)
                                isSearchFocused = false
                            }) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                    Text("Search")
                                        .font(.custom("Manrope", size: 16))
                                        .fontWeight(.semibold)
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Search Results
                    SearchResultsView(
                        searchText: searchText,
                        searchResults: searchResults,
                        isDarkMode: isDarkMode,
                        onAddLocation: { locationName in
                            addLocation(locationName)
                        }
                    )
                    
                    Spacer()
                }
            }
            .background(
                ZStack {
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
                }
            )
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .preferredColorScheme(themePreference == "system" ? nil : (themePreference == "dark" ? .dark : .light))
        }
    }
    
    private func performSearch(_ query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        // Mock search results for now
        // TODO: Implement actual city search API
        let cities = [
            "New York, NY", "Los Angeles, CA", "Chicago, IL",
            "Houston, TX", "Phoenix, AZ", "Philadelphia, PA",
            "San Antonio, TX", "San Diego, CA", "Dallas, TX",
            "San Jose, CA", "Austin, TX", "Jacksonville, FL",
            "Fort Worth, TX", "Columbus, OH", "Charlotte, NC",
            "San Francisco, CA", "Indianapolis, IN", "Seattle, WA",
            "Denver, CO", "Boston, MA", "Nashville, TN",
            "Detroit, MI", "Portland, OR", "Memphis, TN",
            "Oklahoma City, OK", "Las Vegas, NV", "Louisville, KY",
            "Baltimore, MD", "Milwaukee, WI", "Albuquerque, NM"
        ]
        
        searchResults = cities.filter { $0.lowercased().contains(query.lowercased()) }
    }
    
    private func addLocation(_ locationName: String) {
        let newLocation = SavedLocation(name: locationName, isDefault: false)
        onAdd(newLocation)
        dismiss()
    }
}

#Preview {
    @Previewable @Namespace var namespace
    LocationsManagerView(namespace: namespace, onLocationSelected: { _ in })
}

// MARK: - Search Field Component
struct SearchFieldView: View {
    @Binding var searchText: String
    var isSearchFocused: FocusState<Bool>.Binding
    let isDarkMode: Bool
    let onSearch: (String) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search for a city...", text: $searchText)
                .font(.custom("Manrope", size: 16))
                .textFieldStyle(.plain)
                .focused(isSearchFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .submitLabel(.search)
                .onSubmit {
                    onSearch(searchText)
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isSearchFocused.wrappedValue = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Search Results Component
struct SearchResultsView: View {
    let searchText: String
    let searchResults: [String]
    let isDarkMode: Bool
    let onAddLocation: (String) -> Void
    
    var body: some View {
        if !searchText.isEmpty {
            ScrollView {
                VStack(spacing: 12) {
                    if searchResults.isEmpty {
                        Text("No cities found")
                            .font(.custom("Manrope", size: 15))
                            .foregroundStyle(.secondary)
                            .padding(.top, 40)
                    } else {
                        ForEach(searchResults, id: \.self) { result in
                            Button(action: {
                                onAddLocation(result)
                            }) {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundStyle(.blue)
                                    
                                    Text(result)
                                        .font(.custom("Manrope", size: 16))
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "plus.circle")
                                        .foregroundStyle(.blue)
                                }
                                .padding(16)
                                .background(isDarkMode ? Color.white.opacity(0.08) : Color.primary.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
