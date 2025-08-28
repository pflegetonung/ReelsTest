import Foundation

protocol APIRequestPerforming {
    func perform<T: Decodable>(_ request: URLRequest, decoder: JSONDecoder) async throws -> T
}

struct APIClient: APIRequestPerforming {
    let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func perform<T: Decodable>(_ request: URLRequest, decoder: JSONDecoder = .apiDecoder()) async throws -> T {
        let (data, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard 200..<300 ~= http.statusCode else { throw URLError(.badServerResponse) }
        return try decoder.decode(T.self, from: data)
    }
}

enum APIEndpoint {
    static let base = URL(string: "https://interesnoitochka.ru")!

    static func recommendations(offset: Int, limit: Int, category: String = "shorts") -> URL {
        var components = URLComponents(url: base.appendingPathComponent("/api/v1/videos/recommendations"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "category", value: category),
            URLQueryItem(name: "date_filter_type", value: "created"),
            URLQueryItem(name: "sort_by", value: "date_created"),
            URLQueryItem(name: "sort_order", value: "desc")
        ]
        return components.url!
    }

    static func hlsPlaylist(videoId: Int) -> URL {
        base.appendingPathComponent("/api/v1/videos/video/\(videoId)/hls/playlist.m3u8")
    }
}


