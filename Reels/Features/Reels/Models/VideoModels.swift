import Foundation

// MARK: - API Models

struct RecommendationsResponse: Decodable {
    let total: Int
    let offset: Int
    let limit: Int
    let count: Int
    let items: [VideoItem]
}

struct VideoItem: Decodable, Identifiable, Hashable {
    let videoId: Int
    let title: String
    let previewImage: URL?
    let postImage: URL?
    let channelId: Int
    let channelName: String
    let channelAvatar: URL?
    let numbersViews: Int
    let durationSec: Int
    let free: Bool
    let vertical: Bool
    let datePublication: Date?
    let hasAccess: Bool
    let contentType: String

    var id: Int { videoId }
    var hlsURL: URL? {
        URL(string: "https://interesnoitochka.ru/api/v1/videos/video/\(videoId)/hls/playlist.m3u8")
    }

    enum CodingKeys: String, CodingKey {
        case videoId = "video_id"
        case title
        case previewImage = "preview_image"
        case postImage = "post_image"
        case channelId = "channel_id"
        case channelName = "channel_name"
        case channelAvatar = "channel_avatar"
        case numbersViews = "numbers_views"
        case durationSec = "duration_sec"
        case free
        case vertical
        case datePublication = "date_publication"
        case hasAccess = "has_access"
        case contentType = "content_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        videoId = try container.decode(Int.self, forKey: .videoId)
        title = try container.decode(String.self, forKey: .title)
        previewImage = try container.decodeIfPresent(URL.self, forKey: .previewImage)
        postImage = try container.decodeIfPresent(URL.self, forKey: .postImage)
        channelId = try container.decode(Int.self, forKey: .channelId)
        channelName = try container.decode(String.self, forKey: .channelName)
        channelAvatar = try container.decodeIfPresent(URL.self, forKey: .channelAvatar)
        numbersViews = try container.decode(Int.self, forKey: .numbersViews)
        durationSec = try container.decode(Int.self, forKey: .durationSec)
        free = try container.decode(Bool.self, forKey: .free)
        vertical = try container.decode(Bool.self, forKey: .vertical)
        hasAccess = try container.decode(Bool.self, forKey: .hasAccess)
        contentType = try container.decode(String.self, forKey: .contentType)

        if let dateString = try container.decodeIfPresent(String.self, forKey: .datePublication) {
            datePublication = DateParser.parseAPIDate(from: dateString)
        } else {
            datePublication = nil
        }
    }
}

// MARK: - Date Decoding

extension JSONDecoder {
    static func apiDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        // Keep default; dates are handled manually in VideoItem
        return decoder
    }
}

enum DateParser {
    private static let formatters: [DateFormatter] = {
        let locales = [Locale(identifier: "en_US_POSIX")]
        let timeZones: [TimeZone?] = [TimeZone(secondsFromGMT: 0), nil]
        let patterns = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ", // 3 fraction with TZ
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX", // 3 fraction ISO8601 TZ
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ", // 6 fraction with TZ
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", // 6 fraction no TZ
            "yyyy-MM-dd'T'HH:mm:ss.SSS", // 3 fraction no TZ
            "yyyy-MM-dd'T'HH:mm:ssZZZZZ", // no fraction with TZ
            "yyyy-MM-dd'T'HH:mm:ss" // no fraction no TZ
        ]

        var list: [DateFormatter] = []
        for locale in locales {
            for tz in timeZones {
                for pattern in patterns {
                    let f = DateFormatter()
                    f.locale = locale
                    f.dateFormat = pattern
                    f.timeZone = tz
                    list.append(f)
                }
            }
        }
        return list
    }()

    static func parseAPIDate(from string: String) -> Date? {
        for formatter in formatters {
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return nil
    }
}


