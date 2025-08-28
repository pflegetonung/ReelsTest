import Foundation

@MainActor
final class ReelsViewModel: ObservableObject {
    @Published private(set) var videos: [VideoItem] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published private(set) var hasMore: Bool = true

    private let api: APIRequestPerforming
    private var offset: Int = 0
    private let pageSize: Int = 10
    private let maxCacheSize: Int = 5

    init(api: APIRequestPerforming = APIClient()) {
        self.api = api
    }

    func refresh() async {
        offset = 0
        hasMore = true
        videos = []
        await loadMoreIfNeeded(currentIndex: 0)
    }

    func loadMoreIfNeeded(currentIndex: Int) async {
        guard !isLoading, hasMore else { return }
        
        // Load more when we're 2 videos away from the end
        if currentIndex >= videos.count - 2 {
            await fetchPage()
        }
        
        // Clean up cache - keep only current + next 4 videos
        cleanupCache(currentIndex: currentIndex)
    }

    private func cleanupCache(currentIndex: Int) {
        guard videos.count > maxCacheSize else { return }
        
        let startIndex = max(0, currentIndex - 1)
        let endIndex = min(videos.count, startIndex + maxCacheSize)
        
        if startIndex > 0 || endIndex < videos.count {
            videos = Array(videos[startIndex..<endIndex])
        }
    }

    private func fetchPage() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var request = URLRequest(url: APIEndpoint.recommendations(offset: offset, limit: pageSize))
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "accept")
            let response: RecommendationsResponse = try await api.perform(request, decoder: .apiDecoder())
            
            if response.items.isEmpty { 
                hasMore = false 
            } else {
                videos.append(contentsOf: response.items)
                offset += response.items.count
            }
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }
    }
}


