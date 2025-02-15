import SwiftUI

struct MagazineDetailView: View {
    let article: Article
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 헤더 이미지
                AsyncImage(url: article.coverImageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(height: 250)
                .clipped()
                
                VStack(alignment: .leading, spacing: 16) {
                    // 기사 메타 정보
                    HStack {
                        Text(article.category)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        Text(article.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // 제목
                    Text(article.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // 부제목
                    if let subtitle = article.subtitle {
                        Text(subtitle)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    // 작성자 정보
                    HStack {
                        AsyncImage(url: article.authorImageURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(article.authorName)
                                .font(.headline)
                            Text(article.authorTitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    Divider()
                    
                    // 본문
                    ForEach(article.contents, id: \.id) { content in
                        switch content.type {
                        case .text:
                            Text(content.text)
                                .font(.body)
                                .lineSpacing(8)
                        case .image:
                            VStack(alignment: .leading, spacing: 8) {
                                AsyncImage(url: content.imageURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                }
                                .frame(height: 200)
                                .cornerRadius(12)
                                
                                if let caption = content.caption {
                                    Text(caption)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                        case .relatedRecords:
                            VStack(alignment: .leading, spacing: 12) {
                                Text("관련 음반")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        ForEach(content.records) { record in
                                            NavigationLink(destination: RecordDetailView(record: record)) {
                                                RecordCard(record: record)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RecordCard: View {
    let record: Record
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 앨범 커버
            AsyncImage(url: record.coverImageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(width: 150, height: 150)
            .cornerRadius(12)
            
            // 앨범 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(record.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(record.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Text("최저가")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(record.lowestPrice)원")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 150)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

// MARK: - Models
struct Article: Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let category: String
    let coverImageURL: URL
    let authorName: String
    let authorTitle: String
    let authorImageURL: URL
    let date: Date
    let contents: [ArticleContent]
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
    
    static let sample = Article(
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
    )
}

struct ArticleContent: Identifiable {
    let id: String
    let type: ContentType
    let text: String
    let imageURL: URL?
    let caption: String?
    let records: [Record]
    
    enum ContentType {
        case text
        case image
        case relatedRecords
    }
}

#Preview {
    NavigationView {
        MagazineDetailView(article: .sample)
    }
} 