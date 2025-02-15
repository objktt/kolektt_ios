import Foundation

struct CollectionAnalytics {
    let totalRecords: Int
    let genres: [GenreAnalytics]
    let decades: [DecadeAnalytics]
    let mostCollectedGenre: String
    let mostCollectedArtist: String
    let oldestRecord: Int
    let newestRecord: Int
}

struct GenreAnalytics {
    let name: String
    let count: Int
    private let totalCount: Int
    
    init(name: String, count: Int, totalCount: Int) {
        self.name = name
        self.count = count
        self.totalCount = totalCount
    }
    
    var percentage: Double {
        Double(count) / Double(totalCount) * 100
    }
}

struct DecadeAnalytics {
    let decade: String
    let count: Int
    private let totalCount: Int
    
    init(decade: String, count: Int, totalCount: Int) {
        self.decade = decade
        self.count = count
        self.totalCount = totalCount
    }
    
    var percentage: Double {
        Double(count) / Double(totalCount) * 100
    }
} 