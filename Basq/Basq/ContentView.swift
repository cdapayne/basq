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
                }

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

                        Spacer()

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
                }
                .padding()
            }
        }
        .edgesIgnoringSafeArea(.all)
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
}

#Preview {
    ContentView()
}
