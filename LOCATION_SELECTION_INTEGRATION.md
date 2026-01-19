# Location Selection Integration

## Overview
Connected the Locations Manager to the weather data system so selecting a location actually updates the displayed weather.

## Changes Made

### 1. HomeViewModel - Added Location Selection
**New Methods:**
- `fetchWeatherForCity(_ cityName: String)` - Fetches weather for a specific city
- `updateWeatherData(_ data:)` - Private helper to update all weather properties

**Mock Coordinates:**
Added hardcoded coordinates for 10 major US cities:
- New York, Los Angeles, Chicago, Houston, Phoenix
- Philadelphia, San Antonio, San Diego, Dallas, San Jose

**TODO:** Replace mock coordinates with proper geocoding API (OpenWeatherMap Geocoding, Google Geocoding, or Mapbox)

### 2. HomeView - Pass Callback
**Added:**
- `onLocationSelected` callback to LocationsManagerView
- Checks if location is "Current Location" (GPS) or a city name
- Calls appropriate ViewModel method

**Logic:**
```swift
if locationName != "Current Location" {
    viewModel.fetchWeatherForCity(locationName)
} else {
    viewModel.fetchData() // Use GPS
}
```

### 3. LocationsManagerView - Accept Callback
**Added:**
- `onLocationSelected: (String) -> Void` parameter
- Calls callback when location is tapped
- Dismisses view after selection

## User Flow

### Selecting Current Location:
1. Tap "Current Location" in list
2. Callback fires with "Current Location"
3. HomeView calls `viewModel.fetchData()`
4. GPS location requested
5. Weather updates for current location

### Selecting Saved Location:
1. Tap saved city (e.g., "New York, NY")
2. Callback fires with "New York, NY"
3. HomeView calls `viewModel.fetchWeatherForCity("New York, NY")`
4. ViewModel looks up coordinates
5. Fetches weather for that location
6. Updates all weather data
7. Locations Manager dismisses
8. Home page shows new location's weather

## Console Logs

You'll now see:
```
📍 Selected location: Chicago, IL
🌍 HomeViewModel: Fetching weather for Chicago, IL
📍 Geocoded location: Chicago, IL
✅ HomeViewModel: Weather data received for Chicago, IL
```

## Limitations (Current)

### Mock Coordinates
Only 10 cities have hardcoded coordinates:
- Works: "New York, NY", "Los Angeles, CA", etc.
- Doesn't work: Any city not in the mock list

**Fallback:** If city not found, falls back to GPS location

### No Geocoding API
Currently using hardcoded lat/lon pairs. In production, you'll need:

**Option 1 - OpenWeatherMap Geocoding:**
```swift
// GET http://api.openweathermap.org/geo/1.0/direct?q={city}&limit=1&appid={API_KEY}
```

**Option 2 - Apple CLGeocoder (Free):**
```swift
let geocoder = CLGeocoder()
geocoder.geocodeAddressString(cityName) { placemarks, error in
    if let location = placemarks?.first?.location {
        fetchWeatherData(lat: location.coordinate.latitude, 
                        lon: location.coordinate.longitude)
    }
}
```

**Option 3 - Google Geocoding API:**
Requires API key and billing

## Testing

### Test Current Location:
1. Open Locations Manager
2. Tap "Current Location"
3. ✅ Weather updates to GPS location
4. ✅ View dismisses

### Test Saved Location:
1. Add "Chicago, IL" to locations
2. Tap "Chicago, IL"
3. ✅ Weather updates to Chicago
4. ✅ City name changes to "Chicago, IL"
5. ✅ Temperature, conditions, etc. update
6. ✅ View dismisses

### Test Unknown Location:
1. Add "Unknown City, XX" 
2. Tap it
3. ✅ Falls back to GPS location
4. ✅ Console shows warning

## Next Steps

### 1. Implement Real Geocoding
Replace `mockCoordinates` with API call:

```swift
func fetchWeatherForCity(_ cityName: String) {
    self.state = .loading
    
    // Use CLGeocoder or OpenWeatherMap Geocoding API
    geocodeCity(cityName) { lat, lon in
        self.openWeatherService.fetchWeatherData(lat: lat, lon: lon) { ... }
    }
}
```

### 2. Cache Coordinates
Store lat/lon with SavedLocation:
```swift
struct SavedLocation {
    let id: UUID
    var name: String
    var latitude: Double?
    var longitude: Double?
    var isDefault: Bool
}
```

### 3. Error Handling
Show alert if location fetch fails

### 4. Loading State
Show spinner while fetching new location's weather

### 5. Save Last Selected
Remember which location was last viewed

## Keyboard Lag Note

The "Reporter disconnected" messages are iOS Simulator keyboard issues, not our code. This is a known Xcode/Simulator bug that doesn't occur on real devices.

**To test properly:**
- Run on a physical iPhone
- Keyboard will be responsive
- Search will work smoothly

**Simulator workarounds:**
- Use hardware keyboard (⌘K)
- Type slowly
- Restart simulator

The location selection integration now works! Weather updates when you tap a location. 📍🌤️
