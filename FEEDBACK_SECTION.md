# Feedback Section - Settings Update

## Overview
Added a Feedback section to the Settings page with two action buttons for user feedback and app rating.

## Features Added

### Feedback Section
Located below General and Display settings in the main Settings view.

### 1. Report a Problem
**Purpose**: Allow users to send feedback or report issues

**Icon**: Exclamation bubble (exclamationmark.bubble.fill)
**Title**: "Report a Problem"
**Subtitle**: "Send us feedback"

**Action**: Opens native Mail app with pre-filled email
- **To**: eliwaterkotte@gmail.com
- **Subject**: "MinWeather - Problem Report"
- **Body**: "Please describe the issue you're experiencing:"

**Implementation**:
```swift
private func reportProblem() {
    let email = "eliwaterkotte@gmail.com"
    let subject = "MinWeather - Problem Report"
    let body = "Please describe the issue you're experiencing:"
    
    let urlString = "mailto:\(email)?subject=\(subject)&body=\(body)"
    
    if let url = URL(string: urlString) {
        UIApplication.shared.open(url)
    }
}
```

### 2. Rate on App Store
**Purpose**: Encourage users to leave app reviews

**Icon**: Star (star.fill)
**Title**: "Rate on App Store"
**Subtitle**: "Share your experience"

**Action**: Opens link to rate the app
- **Current**: Opens Google.com (placeholder)
- **Production**: Will be replaced with actual App Store link

**Implementation**:
```swift
private func rateOnAppStore() {
    // TODO: Replace with actual App Store link when published
    if let url = URL(string: "https://www.google.com") {
        UIApplication.shared.open(url)
    }
}
```

## User Experience

### Settings Layout
1. **General** - Units, location, preferences
2. **Display** - Theme and appearance
3. **Report a Problem** - Send feedback via email
4. **Rate on App Store** - Leave a review

### Report a Problem Flow
1. User taps "Report a Problem"
2. Mail app opens with pre-filled email
3. User describes issue
4. User sends email
5. Feedback received at eliwaterkotte@gmail.com

### Rate on App Store Flow
1. User taps "Rate on App Store"
2. Browser/App Store opens (currently Google placeholder)
3. **Future**: Direct link to App Store rating page

## Design Consistency

Both buttons use the same `SettingsRowView` component:
- Gradient icon background (blue to purple)
- Title and subtitle text
- Consistent padding and spacing
- Matches General and Display rows
- Adapts to light/dark mode

## Future Enhancements

### For App Store Rating Button
When the app is published, replace the placeholder with:

**Option 1 - Direct App Store Link**:
```swift
let appStoreURL = "https://apps.apple.com/app/idYOUR_APP_ID"
```

**Option 2 - In-App Review (Recommended)**:
```swift
import StoreKit

private func rateOnAppStore() {
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        SKStoreReviewController.requestReview(in: scene)
    }
}
```

**Option 3 - Write Review Link**:
```swift
let appStoreURL = "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review"
```

### Email Template Customization
Consider adding device/app info to help with debugging:
```swift
let body = """
Please describe the issue you're experiencing:

---
Device Info:
iOS Version: \(UIDevice.current.systemVersion)
Device Model: \(UIDevice.current.model)
App Version: \(appVersion)
"""
```

## Technical Details

### URL Encoding
Email subject and body are properly percent-encoded to handle special characters:
```swift
subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
```

### External Navigation
Uses `UIApplication.shared.open()` to:
- Open Mail app for email
- Open Safari/App Store for links
- Respects user's default apps

### Error Handling
URLs are validated before opening:
```swift
if let url = URL(string: urlString) {
    UIApplication.shared.open(url)
}
```

## Benefits

✅ **Easy Feedback**: One-tap access to report issues
✅ **Encourage Reviews**: Prompts users to rate the app
✅ **Professional**: Looks polished and matches app design
✅ **Flexible**: Easy to update email or App Store link
✅ **User-Friendly**: Familiar icons and clear descriptions
✅ **Consistent**: Uses same design pattern as other settings

## Files Modified

**SettingsView.swift**:
- Added Feedback section with two buttons
- Implemented `reportProblem()` function
- Implemented `rateOnAppStore()` function
- Organized with MARK comments

The feedback section provides a professional way for users to engage with the app and developer! 📧⭐
