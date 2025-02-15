import Foundation

class HomeViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var recordShops: [RecordShop] = []
    @Published var djPicks: [DJPick] = [
        DJPick(name: "Sickmode", imageUrl: "https://example.com/dj1.jpg", likes: 10),
        DJPick(name: "Zedd", imageUrl: "https://example.com/dj2.jpg", likes: 15),
        DJPick(name: "Skrillex", imageUrl: "https://example.com/dj3.jpg", likes: 20),
        DJPick(name: "Diplo", imageUrl: "https://example.com/dj4.jpg", likes: 25),
        DJPick(name: "Calvin Harris", imageUrl: "https://example.com/dj5.jpg", likes: 30),
        DJPick(name: "David Guetta", imageUrl: "https://example.com/dj6.jpg", likes: 35),
        DJPick(name: "Martin Garrix", imageUrl: "https://example.com/dj7.jpg", likes: 40),
        DJPick(name: "Avicii", imageUrl: "https://example.com/dj8.jpg", likes: 45)
    ]
    @Published var popularRecords: [PopularRecord] = []
    @Published var musicTastes: [MusicTaste] = []
    @Published var selectedGenre: String = "All"
    
    let genres = ["All", "Pop", "Jazz", "Japan", "Soul", "Rock"]
    
    init() {
        loadData()
    }
    
    private func loadData() {
        // 매거진 샘플 데이터
        articles = [
            Article(
                id: "1",
                title: "레코드로 듣는 재즈의 매력",
                subtitle: "아날로그 사운드의 따뜻함을 느껴보세요",
                category: "Feature",
                coverImageURL: URL(string: "https://example.com/jazz-cover.jpg")!,
                authorName: "김재즈",
                authorTitle: "음악 칼럼니스트",
                authorImageURL: URL(string: "https://example.com/author.jpg")!,
                date: Date(),
                contents: [
                    ArticleContent(
                        id: "1",
                        type: .text,
                        text: "레코드는 단순한 음악 매체가 아닙니다. 그것은 음악을 경험하는 특별한 방식이자, 예술 작품 그 자체입니다.",
                        imageURL: nil,
                        caption: nil,
                        records: []
                    ),
                    ArticleContent(
                        id: "2",
                        type: .image,
                        text: "",
                        imageURL: URL(string: "https://example.com/record-player.jpg")!,
                        caption: "빈티지 레코드 플레이어",
                        records: []
                    ),
                    ArticleContent(
                        id: "3",
                        type: .text,
                        text: "특히 재즈 음악은 레코드로 들을 때 그 진가를 발휘합니다. 아날로그 사운드의 따뜻함과 풍부한 음색이 재즈의 즉흥성과 완벽한 조화를 이룹니다.",
                        imageURL: nil,
                        caption: nil,
                        records: []
                    ),
                    ArticleContent(
                        id: "4",
                        type: .relatedRecords,
                        text: "",
                        imageURL: nil,
                        caption: nil,
                        records: Record.sampleData
                    )
                ]
            ),
            Article(
                id: "2",
                title: "LP 관리의 모든 것",
                subtitle: "소중한 레코드를 오래도록 보관하는 방법",
                category: "Guide",
                coverImageURL: URL(string: "https://example.com/lp-care.jpg")!,
                authorName: "박컬렉터",
                authorTitle: "레코드 수집가",
                authorImageURL: URL(string: "https://example.com/author2.jpg")!,
                date: Date().addingTimeInterval(-86400),
                contents: [
                    ArticleContent(
                        id: "1",
                        type: .text,
                        text: "레코드는 적절한 관리만 해준다면 수십 년이 지나도 처음과 같은 음질을 유지할 수 있습니다.",
                        imageURL: nil,
                        caption: nil,
                        records: []
                    )
                ]
            )
        ]
        
        // 기존 샘플 데이터
        recordShops = [
            RecordShop(title: "A perfect day in Seoul Record shop",
                      subtitle: "한국에서 최고의 레코드 매장 만나기",
                      imageUrl: "https://example.com/seoul1.jpg",
                      location: "Seoul"),
            RecordShop(title: "A perfect day in Yokohama",
                      subtitle: "요코하마의 숨은 레코드 매장",
                      imageUrl: "https://example.com/yokohama1.jpg",
                      location: "Yokohama")
        ]
        
        popularRecords = [
            PopularRecord(title: "Kind of Blue",
                         artist: "Miles Davis",
                         price: 150000,
                         imageUrl: "https://example.com/record1.jpg",
                         trending: true),
            PopularRecord(title: "Abbey Road",
                         artist: "The Beatles",
                         price: 180000,
                         imageUrl: "https://example.com/record2.jpg",
                         trending: false),
            PopularRecord(title: "Thriller",
                         artist: "Michael Jackson",
                         price: 165000,
                         imageUrl: "https://example.com/record3.jpg",
                         trending: true),
            PopularRecord(title: "Blue Train",
                         artist: "John Coltrane",
                         price: 145000,
                         imageUrl: "https://example.com/record4.jpg",
                         trending: true),
            PopularRecord(title: "Purple Rain",
                         artist: "Prince",
                         price: 175000,
                         imageUrl: "https://example.com/record5.jpg",
                         trending: false)
        ]
        
        musicTastes = [
            MusicTaste(
                title: "Yesterday",
                subtitle: "The Beatles",
                imageUrl: "https://example.com/taste1.jpg",
                record: Record(
                    id: UUID(),
                    title: "Yesterday",
                    artist: "The Beatles",
                    releaseYear: 1965,
                    genre: "Pop",
                    coverImageURL: URL(string: "https://example.com/taste1.jpg"),
                    notes: "클래식한 비틀즈의 명곡을 레코드로 만나보세요.",
                    lowestPrice: 150,
                    price: 150,
                    priceChange: 0,
                    sellersCount: 5,
                    recordDescription: "클래식한 비틀즈의 명곡을 레코드로 만나보세요.",
                    rank: 1,
                    rankChange: 0,
                    trending: true
                )
            ),
            MusicTaste(
                title: "Take Five",
                subtitle: "Dave Brubeck",
                imageUrl: "https://example.com/taste2.jpg",
                record: Record(
                    id: UUID(),
                    title: "Take Five",
                    artist: "Dave Brubeck",
                    releaseYear: 1959,
                    genre: "Jazz",
                    coverImageURL: URL(string: "https://example.com/taste2.jpg"),
                    notes: "재즈의 대표곡을 아날로그 사운드로 즐겨보세요.",
                    lowestPrice: 180,
                    price: 180,
                    priceChange: 0,
                    sellersCount: 3,
                    recordDescription: "재즈의 대표곡을 아날로그 사운드로 즐겨보세요.",
                    rank: 2,
                    rankChange: 0,
                    trending: true
                )
            ),
            MusicTaste(
                title: "Purple Rain",
                subtitle: "Prince",
                imageUrl: "https://example.com/taste3.jpg",
                record: Record(
                    id: UUID(),
                    title: "Purple Rain",
                    artist: "Prince",
                    releaseYear: 1984,
                    genre: "Pop/Rock",
                    coverImageURL: URL(string: "https://example.com/taste3.jpg"),
                    notes: "프린스의 상징적인 앨범을 레코드로 소장하세요.",
                    lowestPrice: 200,
                    price: 200,
                    priceChange: 0,
                    sellersCount: 4,
                    recordDescription: "프린스의 상징적인 앨범을 레코드로 소장하세요.",
                    rank: 3,
                    rankChange: 0,
                    trending: true
                )
            )
        ]
    }
} 