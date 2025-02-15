import Foundation
import SwiftData

@Model
final class Record: Identifiable {
    var id: UUID
    var title: String
    var artist: String
    var releaseYear: Int?
    var genre: String?
    var coverImageURL: URL?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    // Discogs 메타데이터
    var catalogNumber: String?
    var label: String?
    var format: String?
    var country: String?
    var style: String?
    var condition: String?
    var conditionNotes: String?
    
    // 판매 관련 정보
    var lowestPrice: Int = 0
    var price: Int?
    var priceChange: Double?
    var sellersCount: Int = 0
    var recordDescription: String?
    
    // 순위 관련 정보
    var rank: Int?
    var rankChange: Int?
    var trending: Bool?
    
    // 미리보기 URL
    var previewUrl: String?
    
    init(id: UUID = UUID(),
         title: String,
         artist: String,
         releaseYear: Int? = nil,
         genre: String? = nil,
         coverImageURL: URL? = nil,
         notes: String? = nil,
         catalogNumber: String? = nil,
         label: String? = nil,
         format: String? = nil,
         country: String? = nil,
         style: String? = nil,
         condition: String? = nil,
         conditionNotes: String? = nil,
         lowestPrice: Int = 0,
         price: Int? = nil,
         priceChange: Double? = nil,
         sellersCount: Int = 0,
         recordDescription: String? = nil,
         rank: Int? = nil,
         rankChange: Int? = nil,
         trending: Bool? = nil,
         previewUrl: String? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.releaseYear = releaseYear
        self.genre = genre
        self.coverImageURL = coverImageURL
        self.notes = notes
        self.catalogNumber = catalogNumber
        self.label = label
        self.format = format
        self.country = country
        self.style = style
        self.condition = condition
        self.conditionNotes = conditionNotes
        self.createdAt = Date()
        self.updatedAt = Date()
        self.lowestPrice = lowestPrice
        self.price = price
        self.priceChange = priceChange
        self.sellersCount = sellersCount
        self.recordDescription = recordDescription
        self.rank = rank
        self.rankChange = rankChange
        self.trending = trending
        self.previewUrl = previewUrl
    }
}

// MARK: - Sample Data
extension Record {
    static var sampleData: [Record] = [
        // Rock (5장)
        Record(
            title: "Abbey Road",
            artist: "The Beatles",
            releaseYear: 1969,
            genre: "Rock",
            coverImageURL: URL(string: "https://example.com/abbey-road.jpg"),
            catalogNumber: "PCS 7088",
            label: "Apple Records",
            format: "LP, Album",
            country: "UK",
            style: "Classic Rock",
            condition: "NM"
        ),
        Record(
            title: "Nevermind",
            artist: "Nirvana",
            releaseYear: 1991,
            genre: "Rock",
            coverImageURL: URL(string: "https://example.com/nevermind.jpg"),
            catalogNumber: "DGC-24425",
            label: "DGC",
            format: "LP, Album",
            country: "US",
            style: "Grunge",
            condition: "VG+"
        ),
        Record(
            title: "OK Computer",
            artist: "Radiohead",
            releaseYear: 1997,
            genre: "Rock",
            coverImageURL: URL(string: "https://example.com/ok-computer.jpg"),
            catalogNumber: "NODATA 02",
            label: "Parlophone",
            format: "LP, Album",
            country: "UK",
            style: "Alternative Rock",
            condition: "NM"
        ),
        Record(
            title: "The Dark Side of the Moon",
            artist: "Pink Floyd",
            releaseYear: 1973,
            genre: "Rock",
            coverImageURL: URL(string: "https://example.com/dark-side.jpg"),
            catalogNumber: "SHVL 804",
            label: "Harvest",
            format: "LP, Album",
            country: "UK",
            style: "Progressive Rock",
            condition: "VG+"
        ),
        Record(
            title: "Led Zeppelin IV",
            artist: "Led Zeppelin",
            releaseYear: 1971,
            genre: "Rock",
            coverImageURL: URL(string: "https://example.com/ledzep-4.jpg"),
            catalogNumber: "SD 7208",
            label: "Atlantic",
            format: "LP, Album",
            country: "US",
            style: "Hard Rock",
            condition: "VG"
        ),
        
        // Electronic (7장)
        Record(
            title: "Discovery",
            artist: "Daft Punk",
            releaseYear: 2001,
            genre: "Electronic",
            coverImageURL: URL(string: "https://example.com/discovery.jpg"),
            catalogNumber: "7243 8 50797 1 8",
            label: "Virgin",
            format: "LP, Album",
            country: "FR",
            style: "House",
            condition: "VG+"
        ),
        Record(
            title: "Random Access Memories",
            artist: "Daft Punk",
            releaseYear: 2013,
            genre: "Electronic",
            coverImageURL: URL(string: "https://example.com/ram.jpg"),
            catalogNumber: "88883716861",
            label: "Columbia",
            format: "LP, Album",
            country: "US",
            style: "Disco",
            condition: "M"
        ),
        Record(
            title: "Selected Ambient Works 85-92",
            artist: "Aphex Twin",
            releaseYear: 1992,
            genre: "Electronic",
            coverImageURL: URL(string: "https://example.com/saw85-92.jpg"),
            catalogNumber: "AMB 3922",
            label: "Apollo",
            format: "2×LP, Album",
            country: "UK",
            style: "Ambient",
            condition: "NM"
        ),
        Record(
            title: "Homework",
            artist: "Daft Punk",
            releaseYear: 1997,
            genre: "Electronic",
            coverImageURL: URL(string: "https://example.com/homework.jpg"),
            catalogNumber: "7243 8 42609 1 0",
            label: "Virgin",
            format: "2×LP, Album",
            country: "FR",
            style: "House",
            condition: "VG+"
        ),
        Record(
            title: "Trans-Europe Express",
            artist: "Kraftwerk",
            releaseYear: 1977,
            genre: "Electronic",
            coverImageURL: URL(string: "https://example.com/trans-europe.jpg"),
            catalogNumber: "1C 064-82 306",
            label: "Kling Klang",
            format: "LP, Album",
            country: "DE",
            style: "Synth-pop",
            condition: "VG"
        ),
        Record(
            title: "Music Has the Right to Children",
            artist: "Boards of Canada",
            releaseYear: 1998,
            genre: "Electronic",
            coverImageURL: URL(string: "https://example.com/mhtrtc.jpg"),
            catalogNumber: "WARPCD55",
            label: "Warp Records",
            format: "2×LP, Album",
            country: "UK",
            style: "IDM",
            condition: "NM"
        ),
        Record(
            title: "Untrue",
            artist: "Burial",
            releaseYear: 2007,
            genre: "Electronic",
            coverImageURL: URL(string: "https://example.com/untrue.jpg"),
            catalogNumber: "HDBCD002",
            label: "Hyperdub",
            format: "2×LP, Album",
            country: "UK",
            style: "Dubstep",
            condition: "NM"
        ),
        
        // Jazz (3장)
        Record(
            title: "Kind of Blue",
            artist: "Miles Davis",
            releaseYear: 1959,
            genre: "Jazz",
            coverImageURL: URL(string: "https://example.com/kind-of-blue.jpg"),
            catalogNumber: "CL 1355",
            label: "Columbia",
            format: "LP, Album",
            country: "US",
            style: "Modal",
            condition: "VG+"
        ),
        Record(
            title: "Blue Train",
            artist: "John Coltrane",
            releaseYear: 1957,
            genre: "Jazz",
            coverImageURL: URL(string: "https://example.com/blue-train.jpg"),
            catalogNumber: "BLP 1577",
            label: "Blue Note",
            format: "LP, Album",
            country: "US",
            style: "Hard Bop",
            condition: "VG"
        ),
        Record(
            title: "Time Out",
            artist: "The Dave Brubeck Quartet",
            releaseYear: 1959,
            genre: "Jazz",
            coverImageURL: URL(string: "https://example.com/time-out.jpg"),
            catalogNumber: "CS 8192",
            label: "Columbia",
            format: "LP, Album",
            country: "US",
            style: "Cool Jazz",
            condition: "VG+"
        ),
        
        // Pop (2장)
        Record(
            title: "Thriller",
            artist: "Michael Jackson",
            releaseYear: 1982,
            genre: "Pop",
            coverImageURL: URL(string: "https://example.com/thriller.jpg"),
            catalogNumber: "QE 38112",
            label: "Epic",
            format: "LP, Album",
            country: "US",
            style: "Pop Rock",
            condition: "VG+"
        ),
        Record(
            title: "Purple Rain",
            artist: "Prince",
            releaseYear: 1984,
            genre: "Pop",
            coverImageURL: URL(string: "https://example.com/purple-rain.jpg"),
            catalogNumber: "925 110-1",
            label: "Warner Bros.",
            format: "LP, Album",
            country: "US",
            style: "Funk",
            condition: "NM"
        )
    ]
} 