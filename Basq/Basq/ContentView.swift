//
//  ContentView.swift
//  Basq
//
//  Created by PayneBrain on 8/25/25.
//

import SwiftUI

/// Root view for the tvOS application. Displays a remote image whose
/// filename increments every minute and optionally shows a large clock
/// centered on the screen.
struct ContentView: View {
    /// Starting index for the image name.
    @State private var currentImageNumber: Int = 3189

    /// Controls whether the clock is visible.
    @State private var showClock: Bool = false

    /// Controls whether the image is wrapped in an art frame.
    @State private var showFrame: Bool = false

    /// Displays the selected category of images.
    @State private var selectedCategoryName: String = "Art"

    /// The current date used for the clock display.
    @State private var currentDate: Date = Date()

    /// A timer that fires every minute to update the image.
    private let minuteTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    /// A timer that fires every second to update the clock text.
    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    /// Available image categories mapped to their path component.
    private let categories: [String: String] = [
        "Art": "art",
        "Nature": "nature",
        "Abstract": "abstract"
    ]

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
                        .artFrame(showFrame)
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

            // Large clock centered on the screen.
            if showClock {
                Text(timeString)
                    .font(.system(size: 150, weight: .bold, design: .monospaced))
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .onReceive(clockTimer) { date in
                        currentDate = date
                    }
            }

            // Overlay containing control buttons.
            VStack {
                HStack {
                    Button(showClock ? "Hide Clock" : "Show Clock") {
                        showClock.toggle()
                    }
                    Button(showFrame ? "Hide Frame" : "Show Frame") {
                        showFrame.toggle()
                    }
                    Spacer()
                    Menu(selectedCategoryName) {
                        ForEach(categories.keys.sorted(), id: \.self) { name in
                            Button(name) {
                                selectedCategoryName = name
                                currentImageNumber = 3189
                            }
                        }
                    }
                }
                .padding()
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    /// Constructs the full URL for the current image number.
    private var imageURL: URL? {
        URL(string: "https://www.paynebrain.com/\(selectedCategoryPath)/IMG_\(currentImageNumber).JPG")
    }

    /// Resolves the currently selected category into its path component.
    private var selectedCategoryPath: String {
        categories[selectedCategoryName] ?? "art"
    }

    /// Formats the current date into a human-readable time string.
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: currentDate)
    }
}

/// View modifier that applies a simple black frame with a white inset.
private struct ArtFrame: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content
                .padding(20)
                .background(Color.white)
                .padding(40)
                .background(Color.black)
        } else {
            content
        }
    }
}

private extension View {
    /// Conditionally wraps the view in the custom art frame.
    func artFrame(_ enabled: Bool) -> some View {
        modifier(ArtFrame(enabled: enabled))
    }
}

#Preview {
    ContentView()
}
