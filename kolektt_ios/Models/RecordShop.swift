import Foundation

struct RecordShop: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageUrl: String
    let location: String
}

struct PopularRecord: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let price: Double
    let imageUrl: String
    let trending: Bool // true for up, false for down
} 