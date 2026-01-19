//
//  Font+Extension.swift
//  MinWeather
//
//  Custom fonts for the app
//

import SwiftUI

extension Font {
    // MARK: - Aldrich (Large Temperature Display)
    
    /// Large temperature display - 80pt
    static let temperatureLarge = Font.custom("Aldrich-Regular", size: 80)
    
    /// Medium temperature display - 48pt
    static let temperatureMedium = Font.custom("Aldrich-Regular", size: 48)
    
    /// Small temperature display - 32pt
    static let temperatureSmall = Font.custom("Aldrich-Regular", size: 32)
    
    /// Extra large temperature display - 120pt
    static let temperatureXLarge = Font.custom("Aldrich-Regular", size: 120)
    
    // MARK: - Amiko (Subtitles & Secondary Text)
    
    /// Location and subtitle text - 18pt
    static let subtitle = Font.custom("Amiko-Regular", size: 18)
    
    /// Feels like and secondary info - 16pt
    static let secondaryInfo = Font.custom("Amiko-Regular", size: 16)
    
    /// Small detail text - 14pt
    static let detailText = Font.custom("Amiko-Regular", size: 14)
    
    /// Extra small caption - 12pt
    static let caption = Font.custom("Amiko-Regular", size: 12)
    
    // MARK: - Abel (Forecasts & Lists)
    
    /// Hourly forecast text - 16pt
    static let hourlyForecast = Font.custom("Abel-Regular", size: 16)
    
    /// Weekly forecast text - 18pt
    static let weeklyForecast = Font.custom("Abel-Regular", size: 18)
    
    /// Forecast detail - 14pt
    static let forecastDetail = Font.custom("Abel-Regular", size: 14)
    
    /// Large forecast header - 20pt
    static let forecastHeader = Font.custom("Abel-Regular", size: 20)
}
