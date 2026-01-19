//
//  AnimatedWeatherBackground.swift
//  MinWeather
//
//  Animated backgrounds based on weather conditions
//

import SwiftUI

struct AnimatedWeatherBackground: View {
    let weatherKey: String
    
    var body: some View {
        ZStack {
            // Select animation based on weather
            switch weatherKey {
            case "Clear":
                SunnyBackground()
            case "Clouds":
                CloudyBackground()
            case "Rain":
                RainyBackground()
            case "Drizzle":
                DrizzleBackground()
            case "Thunderstorm":
                ThunderstormBackground()
            case "Snow":
                SnowyBackground()
            case "Mist", "Fog", "Haze", "Smoke":
                FoggyBackground()
            default:
                CloudyBackground()
            }
        }
    }
}

// MARK: - Sunny Background (Spinning Sun)

struct SunnyBackground: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Large spinning sun in top right
            Image(systemName: "sun.max.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 280, height: 280)
                .foregroundStyle(Color.white.opacity(0.15)) // Increased from 0.08
                .rotationEffect(.degrees(rotation))
                .position(x: UIScreen.main.bounds.width - 80, y: 120) // Top right position
                .onAppear {
                    withAnimation(.linear(duration: 120).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
        }
    }
}

// MARK: - Cloudy Background (Moving Clouds)

struct CloudyBackground: View {
    @State private var cloudPositions: [CGFloat] = []
    let cloudCount = 5
    
    var body: some View {
        ZStack {
            ForEach(0..<cloudCount, id: \.self) { index in
                Image(systemName: "cloud.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: CGFloat.random(in: 80...150))
                    .foregroundStyle(Color.white.opacity(0.18)) // Increased from 0.1
                    .position(
                        x: cloudPositions.indices.contains(index) ? cloudPositions[index] : -100,
                        y: CGFloat.random(in: 100...400)
                    )
            }
        }
        .onAppear {
            cloudPositions = (0..<cloudCount).map { _ in -150 }
            animateClouds()
        }
    }
    
    func animateClouds() {
        for index in 0..<cloudCount {
            let delay = Double(index) * 2.0
            let duration = Double.random(in: 15...25)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    cloudPositions[index] = UIScreen.main.bounds.width + 150
                }
            }
        }
    }
}

// MARK: - Rainy Background (Falling Raindrops)

struct RainyBackground: View {
    @State private var raindrops: [Raindrop] = []
    let raindropCount = 25 // Reduced from 30 for better performance
    
    var body: some View {
        ZStack {
            ForEach(raindrops) { drop in
                RaindropView(drop: drop)
            }
        }
        .drawingGroup() // Optimize rendering by combining into single layer
        .onAppear {
            createRaindrops()
        }
    }
    
    func createRaindrops() {
        raindrops = (0..<raindropCount).map { index in
            Raindrop(
                id: index,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: -800...(-100)), // Start well off-screen
                length: CGFloat.random(in: 15...30),
                delay: Double(index) * 0.06 // Adjusted for fewer drops
            )
        }
    }
}

struct Raindrop: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    let length: CGFloat
    let delay: Double
}

struct RaindropView: View {
    let drop: Raindrop
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.3))
            .frame(width: 2, height: drop.length)
            .position(x: drop.x, y: drop.y + yOffset)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + drop.delay) {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        yOffset = UIScreen.main.bounds.height + 100
                    }
                }
            }
    }
}

// MARK: - Drizzle Background (Light Rain)

struct DrizzleBackground: View {
    @State private var raindrops: [Raindrop] = []
    let raindropCount = 12 // Reduced from 15
    
    var body: some View {
        ZStack {
            ForEach(raindrops) { drop in
                RaindropView(drop: drop)
            }
        }
        .drawingGroup() // Performance optimization
        .onAppear {
            createRaindrops()
        }
    }
    
    func createRaindrops() {
        raindrops = (0..<raindropCount).map { index in
            Raindrop(
                id: index,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: -800...(-100)), // Start off-screen
                length: CGFloat.random(in: 10...20), // Shorter drops
                delay: Double(index) * 0.12 // Adjusted for fewer drops
            )
        }
    }
}

// MARK: - Thunderstorm Background (Rain + Lightning Flashes)

struct ThunderstormBackground: View {
    @State private var raindrops: [Raindrop] = []
    @State private var showLightning: Bool = false
    let raindropCount = 30 // Reduced from 40 for performance
    
    var body: some View {
        ZStack {
            // Heavy rain
            ForEach(raindrops) { drop in
                RaindropView(drop: drop)
            }
            .drawingGroup() // Performance optimization
            
            // Lightning flashes - toned down
            if showLightning {
                Color.white.opacity(0.15) // Reduced from 0.3
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onAppear {
            createRaindrops()
            animateLightning()
        }
    }
    
    func createRaindrops() {
        // Create raindrops with staggered delays for smooth cascade
        raindrops = (0..<raindropCount).map { index in
            Raindrop(
                id: index,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: -800...(-100)), // Random starting heights
                length: CGFloat.random(in: 20...40),
                delay: Double(index) * 0.05 // Staggered like regular rain
            )
        }
    }
    
    func animateLightning() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in // Increased from random 3-8
            // Random chance - only flash 60% of the time
            if Double.random(in: 0...1) < 0.6 {
                withAnimation(.easeInOut(duration: 0.1)) {
                    showLightning = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Shorter flash: 0.15 -> 0.1
                    withAnimation(.easeInOut(duration: 0.1)) {
                        showLightning = false
                    }
                }
            }
        }
    }
}

// MARK: - Snowy Background (Falling Snowflakes)

struct SnowyBackground: View {
    @State private var snowflakes: [Snowflake] = []
    let snowflakeCount = 20 // Reduced from 25 for better performance
    
    var body: some View {
        ZStack {
            ForEach(snowflakes) { flake in
                SnowflakeView(flake: flake)
            }
        }
        .drawingGroup() // Performance optimization
        .onAppear {
            createSnowflakes()
        }
    }
    
    func createSnowflakes() {
        snowflakes = (0..<snowflakeCount).map { index in
            Snowflake(
                id: index,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: -600...(-50)), // Start well off-screen
                size: CGFloat.random(in: 8...20),
                delay: Double(index) * 0.25 // Adjusted for fewer flakes
            )
        }
    }
}

struct Snowflake: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let delay: Double
}

struct SnowflakeView: View {
    let flake: Snowflake
    @State private var yOffset: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    
    var body: some View {
        Image(systemName: "snowflake")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: flake.size, height: flake.size)
            .foregroundStyle(Color.white.opacity(0.6))
            .position(x: flake.x + xOffset, y: flake.y + yOffset)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + flake.delay) {
                    // Falling animation - ONE DIRECTION ONLY
                    withAnimation(.linear(duration: Double.random(in: 8...12)).repeatForever(autoreverses: false)) {
                        yOffset = UIScreen.main.bounds.height + 200
                    }
                    
                    // Gentle swaying animation
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        xOffset = CGFloat.random(in: -20...20)
                    }
                }
            }
    }
}

// MARK: - Foggy Background (Drifting Fog Layers)

struct FoggyBackground: View {
    @State private var fogOffset1: CGFloat = 0
    @State private var fogOffset2: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Fog layer 1
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 200)
                .offset(y: fogOffset1)
                .position(x: UIScreen.main.bounds.width / 2, y: 150)
            
            // Fog layer 2
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.03),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 250)
                .offset(y: fogOffset2)
                .position(x: UIScreen.main.bounds.width / 2, y: 300)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                fogOffset1 = 30
            }
            
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                fogOffset2 = -20
            }
        }
    }
}
