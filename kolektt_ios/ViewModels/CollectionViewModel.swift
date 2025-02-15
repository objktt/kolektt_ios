import SwiftUI

@MainActor
class CollectionViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var recognitionResult: RecognitionResult?
    @Published var analytics: CollectionAnalytics?
    
    func recognizeAlbum(from image: UIImage) async throws -> RecognitionResult {
        // 앨범 인식 로직 구현
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
    }
    
    func processBarcode(_ image: UIImage) async {
        // 바코드 처리 로직 구현
    }
    
    func searchBarcode(_ barcode: String) async {
        // 바코드 검색 로직 구현
    }
    
    func searchCatNo(_ catNo: String) async {
        // CatNo 검색 로직 구현
    }
    
    func updateAnalytics(records: [Record]) {
        let totalRecords = records.count
        
        // 장르 분석
        let genreGroups = Dictionary(grouping: records, by: { $0.genre ?? "기타" })
        let genres = genreGroups.map { 
            GenreAnalytics(name: $0.key, count: $0.value.count, totalCount: totalRecords)
        }
        
        // 아티스트 분석
        let artistGroups = Dictionary(grouping: records, by: { $0.artist })
        let mostCollectedArtist = artistGroups
            .max(by: { $0.value.count < $1.value.count })?
            .key ?? ""
        
        // 연도별 분석
        let decadeGroups = Dictionary(grouping: records.filter { $0.releaseYear != nil }, by: { 
            let decade = ($0.releaseYear! / 10) * 10
            return "\(decade)년대"
        })
        let decades = decadeGroups.map {
            DecadeAnalytics(decade: $0.key, count: $0.value.count, totalCount: totalRecords)
        }
        
        // 통계 데이터
        let mostCollectedGenre = genres
            .filter { $0.name != "기타" }
            .max(by: { $0.count < $1.count })?
            .name ?? ""
        
        let oldestRecord = records
            .compactMap { $0.releaseYear }
            .min() ?? 0
        
        let newestRecord = records
            .compactMap { $0.releaseYear }
            .max() ?? 0
        
        analytics = CollectionAnalytics(
            totalRecords: totalRecords,
            genres: genres,
            decades: decades,
            mostCollectedGenre: mostCollectedGenre,
            mostCollectedArtist: mostCollectedArtist,
            oldestRecord: oldestRecord,
            newestRecord: newestRecord
        )
    }
} 