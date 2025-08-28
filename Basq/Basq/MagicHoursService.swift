import Foundation

struct ParkHours: Decodable {
    let openingTime: String
    let closingTime: String
}

class MagicHoursService {
    func fetchTodayHours() async throws -> ParkHours {
        let url = URL(string: "https://api.themeparks.wiki/v1/parks/walt-disney-world-magic-kingdom/schedules/today")!
        let (data, _) = try await URLSession.shared.data(from: url)
        struct Response: Decodable {
            struct Day: Decodable {
                let openingTime: String?
                let closingTime: String?
            }
            let schedule: [Day]
        }
        let response = try JSONDecoder().decode(Response.self, from: data)
        guard let day = response.schedule.first,
              let open = day.openingTime,
              let close = day.closingTime else {
            throw URLError(.badServerResponse)
        }
        return ParkHours(openingTime: open, closingTime: close)
    }
}
