//
//  ContentView.swift
//  Basq
//
//  Created by PayneBrain on 8/25/25.
//

import SwiftUI
import UIKit

/// Root view for the tvOS application. Displays a remote image whose
/// filename increments every minute and optionally shows a clock in the
/// bottom-right corner.
struct ContentView: View {
    /// Starting index for the image name.
    @State private var currentImageNumber: Int = 3189

    /// Controls whether the clock is visible.
    @State private var showClock: Bool = false

    /// The current date used for the clock display.
    @State private var currentDate: Date = Date()

    /// A timer that fires every minute to update the image.
    private let minuteTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    /// A timer that fires every second to update the clock text.
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
                case .failure:
                    Image(systemName: "xmark.octagon")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .onReceive(minuteTimer) { _ in
                currentImageNumber += 1
            }

            // Overlay containing the toggle button and optional clock.
            VStack {
                HStack {
                    Button(showClock ? "Hide Clock" : "Show Clock") {
                        showClock.toggle()
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
                if showClock {
                    HStack {
                        Spacer()
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
                    .padding()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    /// Constructs the full URL for the current image number.
    private var imageURL: URL? {
        URL(string: "https://www.paynebrain.com/art/IMG_\(currentImageNumber).JPG")
    }

    /// Formats the current date into a human-readable time string.
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: currentDate)
    }
}

#Preview {
    ContentView()
}
