import Foundation

struct MusicTaste: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageUrl: String
    let record: Record
} 