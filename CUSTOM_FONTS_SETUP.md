# Custom Fonts Setup Guide

## ✅ Fonts Copied
I've placed the three font files in:
```
/Users/eliwaterkotte/Documents/Git/weather_app/MinWeather/Fonts/
├── Abel-Regular.ttf
├── Aldrich-Regular.ttf
└── Amiko-Regular.ttf
```

## 📝 Step-by-Step Setup in Xcode

### Step 1: Add Fonts to Xcode Project

1. **Open Xcode** with your MinWeather project
2. In the **Project Navigator** (left sidebar), right-click on `MinWeather` folder
3. Select **"Add Files to 'MinWeather'..."**
4. Navigate to: `/Users/eliwaterkotte/Documents/Git/weather_app/MinWeather/Fonts`
5. Select all three .ttf files (hold Cmd and click each):
   - Abel-Regular.ttf
   - Aldrich-Regular.ttf
   - Amiko-Regular.ttf
6. **IMPORTANT**: Check these options:
   - ✅ **Copy items if needed**
   - ✅ **Create groups** (not folder references)
   - ✅ **Add to targets: MinWeather**
7. Click **"Add"**

### Step 2: Add Font Extension to Project

1. In **Project Navigator**, right-click on `MinWeather` folder
2. Select **"Add Files to 'MinWeather'..."**
3. Navigate to: `/Users/eliwaterkotte/Documents/Git/weather_app/MinWeather/Extensions`
4. Select `Font+Extension.swift`
5. Check:
   - ✅ **Add to targets: MinWeather**
6. Click **"Add"**

### Step 3: Update Info.plist

**Option A - Using Xcode Interface (Recommended):**

1. In **Project Navigator**, find and click on **Info.plist**
   - It might be under `MinWeather` folder or at the root
   - If you don't see it, click on the blue project icon at the top, then go to the **Info** tab

2. **Add font entries:**
   - Right-click in the Info.plist editor area
   - Select **"Add Row"**
   - In the new row, type: `Fonts provided by application`
   - Click the disclosure triangle to expand it
   
3. **Add each font:**
   - Click the **+** button to add Item 0
   - Set value to: `Abel-Regular.ttf`
   - Click **+** again for Item 1
   - Set value to: `Aldrich-Regular.ttf`
   - Click **+** again for Item 2
   - Set value to: `Amiko-Regular.ttf`

**Option B - Edit Info.plist as Source Code:**

If you prefer to edit the raw XML:

1. Right-click on **Info.plist**
2. Select **"Open As" → "Source Code"**
3. Add this before the closing `</dict>` tag:

```xml
<key>UIAppFonts</key>
<array>
    <string>Abel-Regular.ttf</string>
    <string>Aldrich-Regular.ttf</string>
    <string>Amiko-Regular.ttf</string>
</array>
```

### Step 4: Verify Fonts Are Added

1. **Clean Build Folder**: 
   - Press `Shift + Cmd + K` or Product → Clean Build Folder
   
2. **Build Project**:
   - Press `Cmd + B` or Product → Build
   
3. **Check for errors**:
   - If fonts aren't found, make sure the .ttf files are in the project navigator with the MinWeather target checked

### Step 5: Test the Fonts

Add this to any SwiftUI view to test:

```swift
VStack {
    Text("72°")
        .font(.temperatureLarge)
    
    Text("Normal, IL")
        .font(.subtitle)
    
    Text("10 AM")
        .font(.hourlyForecast)
}
```

## 🎨 Font Usage Guide

### Aldrich Font (Temperature Display)
Use for large temperature numbers:
```swift
.font(.temperatureXLarge)  // 120pt - Main temp
.font(.temperatureLarge)   // 80pt - Large display
.font(.temperatureMedium)  // 48pt - Medium display
.font(.temperatureSmall)   // 32pt - Small temp
```

### Amiko Font (Subtitles & Info)
Use for location, feels like, descriptions:
```swift
.font(.subtitle)        // 18pt - Location, main subtitles
.font(.secondaryInfo)   // 16pt - Feels like, wind speed
.font(.detailText)      // 14pt - Small details
.font(.caption)         // 12pt - Tiny labels
```

### Abel Font (Forecasts)
Use for hourly and weekly forecasts:
```swift
.font(.forecastHeader)  // 20pt - Section headers
.font(.weeklyForecast)  // 18pt - Daily forecast
.font(.hourlyForecast)  // 16pt - Hourly forecast
.font(.forecastDetail)  // 14pt - Forecast details
```

## 🔍 Troubleshooting

### Fonts Not Showing Up?

1. **Check Target Membership**:
   - Click on each .ttf file in Project Navigator
   - In the right sidebar (File Inspector)
   - Make sure "MinWeather" is checked under Target Membership

2. **Verify Info.plist Entry**:
   - Open Info.plist
   - Confirm you see "Fonts provided by application" with all three fonts listed

3. **Check Font Names**:
   - Font names are case-sensitive
   - Use exactly: `Abel-Regular`, `Aldrich-Regular`, `Amiko-Regular`

4. **Clean and Rebuild**:
   - Shift + Cmd + K (Clean)
   - Cmd + B (Build)
   - Run on simulator/device

### Font Name Finder (if needed)

If fonts still don't work, print all available font names:

```swift
for family in UIFont.familyNames.sorted() {
    print("Family: \(family)")
    for name in UIFont.fontNames(forFamilyName: family) {
        print("  \(name)")
    }
}
```

Look for "Abel", "Aldrich", "Amiko" in the console output.

## ✅ Next Steps

Once fonts are working:
1. Update HomeView to use new fonts
2. Update Settings views with new fonts
3. Update Locations Manager with new fonts
4. Implement dynamic color theming based on weather
5. Add animated backgrounds

The font extension is ready to use throughout your app! 🎉
