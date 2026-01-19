# Animated Weather Backgrounds

## Overview
Dynamic, condition-specific animated backgrounds that bring the weather to life behind the UI.

## 🌤️ Weather Animations

### ☀️ Sunny/Clear
**Animation**: Slowly rotating sun
- Large sun icon (300x300)
- Continuous 360° rotation
- 120-second rotation cycle
- White with 8% opacity
- Positioned at top center

**Feel**: Warm, bright, energetic

---

### ☁️ Cloudy
**Animation**: Drifting clouds moving left to right
- 5 clouds of varying sizes (80-150px)
- Continuous horizontal movement
- Each cloud has unique speed (15-25 seconds)
- Staggered start times (2-second delays)
- White with 10% opacity
- Random vertical positions

**Feel**: Calm, overcast, peaceful

---

### 🌧️ Rain
**Animation**: Heavy falling raindrops
- 30 raindrops
- Vertical falling motion (1.5-second cycle)
- Varied lengths (15-30px)
- Random horizontal positions
- Staggered start times
- White with 30% opacity
- 2px width

**Feel**: Wet, moody, dynamic

---

### 🌦️ Drizzle
**Animation**: Light rain
- 15 raindrops (half of heavy rain)
- Slower, gentler fall
- Shorter drops (10-20px)
- Longer delays between starts
- White with 30% opacity

**Feel**: Gentle, misty, light

---

### ⛈️ Thunderstorm
**Animation**: Heavy rain + lightning flashes
- 40 intense raindrops
- Longer drops (20-40px)
- Random lightning flashes
  - Full-screen white flash
  - 30% opacity
  - 0.15-second duration
  - Random intervals (3-8 seconds)
- Fast falling animation (1.5 seconds)

**Feel**: Dramatic, intense, powerful

---

### ❄️ Snow
**Animation**: Falling snowflakes with drift
- 25 snowflakes
- Varied sizes (8-20px)
- Slow falling (8-12 seconds)
- Gentle horizontal swaying
  - ±20px drift
  - 3-second sway cycle
- White with 60% opacity
- Snowflake SF Symbol

**Feel**: Cold, serene, winter wonderland

---

### 🌫️ Fog/Mist/Haze
**Animation**: Drifting fog layers
- 2 overlapping fog layers
- Vertical drift animation
  - Layer 1: ±30px over 8 seconds
  - Layer 2: ±20px over 10 seconds
- Gradient fog (top to bottom fade)
- White with 5-15% opacity
- Different heights (200-250px)

**Feel**: Mysterious, soft, obscured

---

## 🎨 Technical Details

### Performance Optimizations
- `.allowsHitTesting(false)` - Animations don't block user interaction
- Efficient SF Symbols for icons
- Linear animations for smooth performance
- Staggered starts to distribute CPU load

### Layering
```
┌─────────────────────────────┐
│  Hamburger Button (Top)     │
├─────────────────────────────┤
│  Menu Drawer (if open)      │
├─────────────────────────────┤
│  Dimmed Overlay (if open)   │
├─────────────────────────────┤
│  UI Content (Cards, Text)   │
├─────────────────────────────┤
│  Animated Background ◄──────┤ HERE
├─────────────────────────────┤
│  Color Theme Background     │
└─────────────────────────────┘
```

### Animation Types Used
- `.linear()` - Constant speed (clouds, rain, snow fall)
- `.easeInOut()` - Smooth start/stop (fog drift, sway)
- `.repeatForever(autoreverses: false)` - Continuous one-direction
- `.repeatForever(autoreverses: true)` - Back-and-forth motion

### Randomization
Each animation uses randomization for natural feel:
- **Positions**: Spread across screen width
- **Timing**: Staggered starts prevent simultaneous movement
- **Speeds**: Varied durations create depth
- **Sizes**: Different scales add visual interest

## 🔄 Weather Key Mapping

| Weather Key | Animation |
|------------|-----------|
| `"Clear"` | Spinning sun |
| `"Clouds"` | Moving clouds |
| `"Rain"` | Heavy raindrops |
| `"Drizzle"` | Light raindrops |
| `"Thunderstorm"` | Rain + lightning |
| `"Snow"` | Falling snowflakes |
| `"Mist"` | Drifting fog |
| `"Fog"` | Drifting fog |
| `"Haze"` | Drifting fog |
| `"Smoke"` | Drifting fog |
| Default | Moving clouds |

## 💡 Usage

The animated background is automatically applied in HomeView:

```swift
.overlay {
    AnimatedWeatherBackground(weatherKey: viewModel.weatherKey)
        .allowsHitTesting(false)
}
```

No manual configuration needed - it responds to the current weather condition!

## 🎯 Future Enhancements

Potential additions:
- **Tornado**: Rotating spiral effect
- **Dust**: Swirling particles
- **Smoke**: Rising wisps
- **Wind**: Flowing lines
- **Time-of-day variants**: Different sun positions, moon phases
- **Intensity levels**: Light/medium/heavy rain based on precipitation amount
- **User preference**: Toggle animations on/off
- **Performance mode**: Reduced particle count for older devices

---

The animated backgrounds create an immersive, reactive weather experience while maintaining smooth performance and never interfering with user interaction! 🌈
