import SwiftUI

// MARK: - 헤더 컴포넌트
struct DJProfileHeader: View {
    let dj: DJ
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // DJ 프로필 카드
            VStack(alignment: .leading, spacing: 12) {
                // DJ 이미지
                KolekttAsyncImage(
                    url: dj.imageURL,
                    width: 160,
                    height: 200,
                    cornerRadius: 12
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    // DJ 이름
                    Text(dj.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    // 장르 태그
                    HStack {
                        Text("House")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        
                        Text("Techno")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding(12)
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5)
        }
        .padding(.horizontal)
    }
}

// MARK: - 컨텐츠 컴포넌트
struct DJContentSection: View {
    let content: InterviewContent
    
    var body: some View {
        switch content.type {
        case .text:
            Text(content.text)
                .font(.body)
                .lineSpacing(6)
                .padding(.horizontal)
        
        case .quote:
            Text(content.text)
                .font(.title3)
                .fontWeight(.medium)
                .italic()
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .padding(.horizontal)
        
        case .recordHighlight:
            DJRecordSection(content: content)
        }
    }
}

// MARK: - 레코드 섹션 컴포넌트
struct DJRecordSection: View {
    let content: InterviewContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("추천 레코드")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(content.records) { record in
                        DJRecordCard(record: record)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - 레코드 카드 컴포넌트
struct DJRecordCard: View {
    let record: Record
    
    var body: some View {
        NavigationLink(destination: RecordDetailView(record: record)) {
            VStack(alignment: .leading, spacing: 12) {
                if let coverURL = record.coverImageURL {
                    KolekttAsyncImage(
                        url: coverURL,
                        width: 200,
                        height: 200,
                        cornerRadius: 12
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(record.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(record.artist)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let price = record.price {
                        HStack {
                            PriceText(price)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            KolekttButton(title: "구매하기", style: .primary) {
                                // 구매 액션
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(width: 200)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 메인 뷰
struct DJsPickDetailView: View {
    let dj: DJ
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DJProfileHeader(dj: dj)
                
                ForEach(dj.interviewContents) { content in
                    DJContentSection(content: content)
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Models
struct DJ: Identifiable {
    let id: String
    let name: String
    let title: String
    let imageURL: URL
    let yearsActive: Int
    let recordCount: Int
    let interviewContents: [InterviewContent]
    
    static let sample = DJ(
        id: "1",
        name: "DJ Sample",
        title: "Club DJ",
        imageURL: URL(string: "https://example.com/dj.jpg")!,
        yearsActive: 10,
        recordCount: 1000,
        interviewContents: [
            InterviewContent(
                id: "1",
                type: .text,
                text: "음악은 저에게 있어서 삶 그 자체입니다.",
                records: []
            ),
            InterviewContent(
                id: "2",
                type: .quote,
                text: "좋은 음악은 시대를 초월합니다.",
                records: []
            ),
            InterviewContent(
                id: "3",
                type: .recordHighlight,
                text: "",
                records: Record.sampleData
            )
        ]
    )
}

struct InterviewContent: Identifiable {
    let id: String
    let type: ContentType
    let text: String
    let records: [Record]
    
    enum ContentType {
        case text
        case quote
        case recordHighlight
    }
}

#Preview {
    NavigationView {
        DJsPickDetailView(dj: .sample)
    }
} 