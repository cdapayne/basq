//  ContentView.swift
//  Basq
//
//  Created by PayneBrain on 8/25/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var currentImageNumber: Int = 3189
    @State private var showClock: Bool = false
    @State private var currentDate: Date = Date()

    // Track button visibility
    @State private var showButton: Bool = true

    // Weather and settings
    @AppStorage("zipCode") private var zipCode: String = ""
    @State private var weather: Weather?
    @State private var showSettings: Bool = false

    // Magic Kingdom hours
    @State private var magicHours: String = "Loading hours..."

    private let minuteTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Background image that refreshes every minute.
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .overlay(Color.black.opacity(0.4)) // <-- dims image ~80%
                case .failure:
                    Image(systemName: "xmark.octagon")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .overlay(Color.black.opacity(0.8))
                @unknown default:
                    EmptyView()
                }
            }
            .onReceive(minuteTimer) { _ in
                currentImageNumber += 1
            }

            VStack {
                HStack {
                    Button(showClock ? "Hide Clock" : "Show Clock") {
                        showClock.toggle()
                        resetButtonFade()
                    }
                    .padding()
                    .opacity(showButton ? 1 : 0.01) // dim after timeout
                    .animation(.easeInOut(duration: 1), value: showButton)

                    Spacer()

                    if let weather {
                        VStack(alignment: .trailing) {
                            Text("Temp: \(Int(weather.temperature))°F")
                            Text("Humidity: \(Int(weather.humidity))%")
                        }
                        .font(.caption)
                        .padding(8)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }

                Spacer()

                // Center magic hours
                Text(magicHours)
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)

                Spacer()

                HStack {
                    // Bottom-left date
                    if showClock {
                        Text(dateString)
                            .font(.caption)
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Spacer()

                    if showClock {
                        // Bottom-right clock
                        Text(timeString)
                            .font(.title2)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .onReceive(clockTimer) { date in
                                currentDate = date
                            }
                    }

                    Button(action: {
                        showSettings = true
                        resetButtonFade()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .opacity(showButton ? 1 : 0.01)
                    .animation(.easeInOut(duration: 1), value: showButton)
                    .sheet(isPresented: $showSettings) {
                        SettingsView(zipCode: $zipCode) {
                            Task { await loadWeather() }
                        }
                    }
                }
                .padding()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .task {
            await loadWeather()
            await loadMagicHours()
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            resetButtonFade()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    // MARK: - Helpers
    private func resetButtonFade() {
        showButton = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showButton = false
            }
        }
    }

    private var imageURL: URL? {
        URL(string: "https://www.paynebrain.com/art/IMG_\(currentImageNumber).JPG")
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: currentDate)
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: currentDate)
    }

    // MARK: - Data Loading
    @MainActor
    private func loadWeather() async {
        guard !zipCode.isEmpty else { return }
        do {
            weather = try await WeatherService().fetchWeather(zipCode: zipCode)
        } catch {
            weather = nil
        }
    }

    @MainActor
    private func loadMagicHours() async {
        do {
            let hours = try await MagicHoursService().fetchTodayHours()
            magicHours = "Magic Kingdom: \(hours.openingTime) - \(hours.closingTime)"
        } catch {
            magicHours = "Magic Kingdom hours unavailable"
        }
    }
}

#Preview {
    ContentView()
}
