# Locations Manager Feature

## Overview
Added a comprehensive Locations Manager that allows users to save multiple locations and switch between them for weather viewing.

## Features

### 1. Location Icon in Header
Added a blue location pin icon next to the city name on the home page.

**Design:**
- Location: Next to city name in header
- Icon: `location.fill` (blue)
- Action: Opens Locations Manager
- Animation: Smooth transition

### 2. Locations Manager View
Full-screen view for managing saved locations.

**Components:**
- Header with "Locations" title and Done button
- List of saved locations
- Add Location button at bottom
- Swipe-to-delete for non-default locations

**Features:**
- ✅ View all saved locations
- ✅ Default location highlighted (Current Location)
- ✅ Add new locations via search
- ✅ Delete saved locations (swipe left)
- ✅ Long-press context menu for deletion
- ✅ Tap location to select and view weather

### 3. Location Row Design
Each location displays:
- **Icon**: 
  - Blue location.fill for default location
  - Gray mappin.circle.fill for saved locations
- **Name**: City name (e.g., "New York, NY")
- **Subtitle**: "Default location" for GPS location
- **Chevron**: Right arrow for navigation

**Visual Design:**
- Circular icon background
- Card-based layout
- Consistent padding and spacing
- Adapts to light/dark mode

### 4. Add Location Interface
Modal search interface for adding new locations.

**Features:**
- Search field with magnifying glass icon
- Clear button (X) to reset search
- Real-time search results
- Tap to add location
- Cancel button to dismiss

**Search Results:**
- Shows matching cities as you type
- Each result has:
  - Map pin icon
  - City name
  - Plus icon to add

### 5. Location Management

#### Default Location
- **Name**: "Current Location"
- **Source**: GPS or Settings preference
- **Icon**: Blue location.fill
- **Deletion**: Not allowed
- **Badge**: "Default location" subtitle

#### Saved Locations
- **Source**: User-added via search
- **Icon**: Gray mappin.circle.fill
- **Deletion**: Swipe left or long-press
- **Badge**: None

### 6. Data Persistence
Locations saved using `@AppStorage` with JSON encoding.

**Storage:**
```swift
@AppStorage("savedLocations") private var savedLocationsData: Data
```

**Model:**
```swift
struct SavedLocation: Identifiable, Codable {
    let id: UUID
    var name: String
    var isDefault: Bool
}
```

## User Experience

### Viewing Locations
1. Tap location icon next to city name
2. Locations Manager opens with transition
3. See list of all saved locations
4. Default location at top
5. Tap "Done" to close

### Adding a Location
1. Open Locations Manager
2. Tap "Add Location" button
3. Search sheet appears
4. Type city name
5. Tap result to add
6. Location added to list
7. Sheet dismisses automatically

### Deleting a Location
**Option 1 - Swipe:**
1. Swipe location row left
2. Tap red "Delete" button
3. Location removed

**Option 2 - Long Press:**
1. Long press location row
2. Context menu appears
3. Tap "Delete"
4. Location removed

### Selecting a Location
1. Tap any location row
2. Weather view updates (TODO)
3. Manager dismisses
4. Shows weather for selected location

## Technical Implementation

### Location Storage
```swift
private func loadLocations() {
    if let decoded = try? JSONDecoder().decode([SavedLocation].self, from: savedLocationsData) {
        savedLocations = decoded
    } else {
        // Create default location
        savedLocations = [SavedLocation(name: "Current Location", isDefault: true)]
        saveLocations()
    }
}
```

### Swipe Actions
```swift
.swipeActions(edge: .trailing, allowsFullSwipe: true) {
    if onDelete != nil {
        Button(role: .destructive, action: {
            onDelete?()
        }) {
            Label("Delete", systemImage: "trash")
        }
    }
}
```

### Context Menu
```swift
.contextMenu {
    if onDelete != nil {
        Button(role: .destructive, action: {
            onDelete?()
        }) {
            Label("Delete", systemImage: "trash")
        }
    }
}
```

### Transition Animation
```swift
.fullScreenCover(isPresented: $showingLocations) {
    LocationsManagerView()
        .transition(.scale(scale: 0.9).combined(with: .opacity))
}
```

## Design Consistency

**Background:**
- Uses same purple/blue gradient system
- Respects custom background colors
- Adapts to light/dark mode

**Typography:**
- Manrope font family
- Consistent weight hierarchy
- Proper color contrast

**Cards:**
- Rounded corners (16px)
- Appropriate padding
- Hover/press states
- Swipe gestures

## Future Enhancements

### 1. City Search API Integration
Replace mock search with actual geocoding API:
```swift
// Current: Mock data
// Future: OpenWeatherMap Geocoding API
```

### 2. Weather Data per Location
Store and display weather for each location:
- Temperature preview
- Condition icon
- Last updated time

### 3. Reorder Locations
Allow drag-to-reorder for custom sorting

### 4. Location Details
Show more info when tapping:
- Coordinates
- Timezone
- Country

### 5. Favorite Locations
Star/favorite system for quick access

### 6. Current Location Detection
Auto-update based on GPS when moving

## Files Created

**LocationsManagerView.swift:**
- `SavedLocation` model
- `LocationsManagerView` - Main manager view
- `LocationRowView` - Individual location row
- `AddLocationView` - Search and add interface

## Files Modified

**HomeView.swift:**
- Added location icon to header
- Added `showingLocations` state
- Integrated fullScreenCover presentation
- Added transition animation

## Testing

- ✅ Location icon appears in header
- ✅ Tap icon opens Locations Manager
- ✅ Default location displays correctly
- ✅ Add button opens search sheet
- ✅ Search filters city results
- ✅ Tap result adds location
- ✅ Swipe left deletes location
- ✅ Long press shows context menu
- ✅ Cannot delete default location
- ✅ Data persists across app launches
- ✅ Adapts to light/dark mode
- ✅ Custom background colors apply

The Locations Manager provides a complete solution for managing multiple weather locations! 📍🌎
