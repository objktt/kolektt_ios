import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    MagazineSection(articles: viewModel.articles)
                    DJPickSection(djPicks: viewModel.djPicks)
                    PopularRecordsSection(
                        genres: viewModel.genres,
                        selectedGenre: $viewModel.selectedGenre,
                        records: viewModel.popularRecords
                    )
                    MusicTasteSection(musicTastes: viewModel.musicTastes)
                    
                    // 리더보드 섹션
                    LeaderboardView(data: LeaderboardData.sampleData)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                }
                .padding(.vertical)
            }
            .navigationTitle("Kolektt")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HomeToolbar()
                }
            }
        }
    }
}

// MARK: - 섹션 컴포넌트
struct MagazineSection: View {
    let articles: [Article]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(articles) { article in
                    NavigationLink(destination: MagazineDetailView(article: article)) {
                        VStack(alignment: .leading, spacing: 12) {
                            // 커버 이미지
                            KolekttAsyncImage(
                                url: article.coverImageURL,
                                width: 280,
                                height: 180,
                                cornerRadius: 12
                            )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                // 제목
                                Text(article.title)
                                    .font(.headline)
                                    .lineLimit(2)
                                
                                // 부제목
                                if let subtitle = article.subtitle {
                                    Text(subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .frame(width: 280)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

struct DJPickSection: View {
    let djPicks: [DJPick]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("DJ's")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                NavigationLink(destination: DJsPickListView()) {
                    HStack(spacing: 4) {
                        Text("더보기")
                            .font(.subheadline)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(djPicks) { djPick in
                        NavigationLink(
                            destination: DJsPickDetailView(dj: DJ(
                                id: djPick.id.uuidString,
                                name: djPick.name,
                                title: "DJ",
                                imageURL: URL(string: djPick.imageUrl)!,
                                yearsActive: 5,
                                recordCount: djPick.likes * 100,
                                interviewContents: [
                                    InterviewContent(
                                        id: "1",
                                        type: .text,
                                        text: "음악은 저에게 있어서 삶 그 자체입니다. 제가 선별한 레코드들을 통해 여러분도 음악의 진정한 매력을 느끼실 수 있기를 바랍니다.",
                                        records: []
                                    ),
                                    InterviewContent(
                                        id: "2",
                                        type: .quote,
                                        text: "좋은 음악은 시대를 초월하여 우리의 마음을 울립니다.",
                                        records: []
                                    ),
                                    InterviewContent(
                                        id: "3",
                                        type: .recordHighlight,
                                        text: "이번 주 추천 레코드",
                                        records: Record.sampleData
                                    )
                                ]
                            ))
                        ) {
                            DJPickCard(dj: djPick)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct PopularRecordsSection: View {
    let genres: [String]
    @Binding var selectedGenre: String
    let records: [PopularRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "인기", showMore: false)
            
            GenreScrollView(
                genres: genres,
                selectedGenre: $selectedGenre
            )
            
            RecordsList(records: records)
        }
    }
}

struct MusicTasteSection: View {
    let musicTastes: [MusicTaste]
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "추천", showMore: true) {
                // 더보기 액션
            }
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(musicTastes) { musicTaste in
                    MusicTasteCard(musicTaste: musicTaste)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - 보조 컴포넌트
struct GenreScrollView: View {
    let genres: [String]
    @Binding var selectedGenre: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(genres, id: \.self) { genre in
                    GenreButton(
                        title: genre,
                        isSelected: selectedGenre == genre
                    ) {
                        selectedGenre = genre
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct RecordsList: View {
    let records: [PopularRecord]
    
    var body: some View {
        VStack(spacing: 11) {
            ForEach(Array(records.prefix(5).enumerated()), id: \.element.id) { index, record in
                PopularRecordRow(record: record, rank: index + 1)
            }
        }
        .padding(.horizontal)
    }
}

struct HomeToolbar: View {
    @State private var showingSearch = false
    @State private var showingNotifications = false
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                showingSearch = true
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.primary)
            }
            .sheet(isPresented: $showingSearch) {
                SearchView()
            }
            
            Button(action: {
                showingNotifications = true
            }) {
                Image(systemName: "bell")
                    .foregroundColor(.primary)
            }
            .sheet(isPresented: $showingNotifications) {
                NotificationsView()
            }
        }
    }
}

// MARK: - 카드 컴포넌트
struct DJPickCard: View {
    let dj: DJPick
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // DJ 이미지
            KolekttAsyncImage(
                url: URL(string: dj.imageUrl),
                width: 160,
                height: 200,
                cornerRadius: 12
            )
            
            // DJ 정보
            VStack(alignment: .leading, spacing: 8) {
                Text(dj.name)
                    .font(.headline)
                
                // 장르 태그
                HStack(spacing: 8) {
                    Text("House")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Text("Techno")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .frame(width: 160)
    }
}

struct PopularRecordRow: View {
    let record: PopularRecord
    let rank: Int
    
    var body: some View {
        NavigationLink(
            destination: RecordDetailView(
                record: Record(
                    id: UUID(),
                    title: record.title,
                    artist: record.artist,
                    releaseYear: 2024,
                    genre: "Jazz",
                    coverImageURL: URL(string: record.imageUrl),
                    notes: nil,
                    lowestPrice: Int(record.price),
                    price: Int(record.price),
                    priceChange: 0.0,
                    sellersCount: 3,
                    recordDescription: "A beautiful collection of timeless classics",
                    rank: rank,
                    rankChange: 2,
                    trending: record.trending
                )
            )
        ) {
            HStack(spacing: 16) {
                KolekttAsyncImage(
                    url: URL(string: record.imageUrl),
                    width: 60,
                    height: 60,
                    cornerRadius: 8
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.title)
                        .font(.headline)
                        .lineLimit(1)
                    Text(record.artist)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    PriceText(Int(record.price))
                        .font(.subheadline)
                }
                
                Spacer()
                
                Image(systemName: record.trending ? "arrow.up" : "arrow.down")
                    .foregroundColor(record.trending ? .green : .red)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MusicTasteCard: View {
    let musicTaste: MusicTaste
    
    var body: some View {
        NavigationLink(destination: RecordDetailView(record: musicTaste.record)) {
            VStack(alignment: .leading, spacing: 0) {
                KolekttAsyncImage(
                    url: URL(string: musicTaste.imageUrl),
                    width: (UIScreen.main.bounds.width - 48) / 2,
                    height: (UIScreen.main.bounds.width - 48) / 2,
                    cornerRadius: 12
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(musicTaste.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(musicTaste.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GenreButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.black : Color.clear)
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

#Preview {
    HomeView()
} 