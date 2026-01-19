//
//  BackgroundViewModifier.swift
//  MinWeather
//
//  Created by Thiago Souza on 08/09/24.
//  Updated with Dark Mode support
//

import SwiftUI

struct BackgroundViewModifier: ViewModifier {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            // Base background color
            (isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.12) : Color.white)
                .ignoresSafeArea()
            
            // Purple accent
            Circle()
                .fill(.purple.opacity(isDarkMode ? 0.4 : 1))
                .frame(width: 320, height: 320)
                .blur(radius: 128)
                .offset(x: -128, y: 144)
            
            // Blue accent
            Rectangle()
                .fill(.blue.opacity(isDarkMode ? 0.4 : 1))
                .frame(width: 320, height: 320)
                .blur(radius: 128)
                .offset(x: 144, y: -128)
            
            content
                .padding()
                .foregroundStyle(isDarkMode ? .white : .black)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
