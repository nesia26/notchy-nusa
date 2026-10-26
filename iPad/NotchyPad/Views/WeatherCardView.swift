import SwiftUI

public struct WeatherCardView: View {
    @ObservedObject var weather: WeatherManager
    
    public var body: some View {
        HStack(spacing: 20) {
            PixelWeatherIcon(
                weatherCode: weather.currentWeather.weatherCode,
                size: 54
            )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(weather.currentWeather.temperature)°")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("C")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Text(weather.currentWeather.conditionText)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                
                Text(weather.currentWeather.city)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "humidity")
                        .font(.system(size: 12))
                    Text("\(weather.currentWeather.humidity)%")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white.opacity(0.75))
                
                Button(action: weather.fetchWeather) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 10))
                        Text("Refresh")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())
                    .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
}
