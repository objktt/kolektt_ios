import SwiftUI

struct PopularRecordsView: View {
    @State private var selectedGenre = "전체"
    @State private var sortOption: SortOption = .popularity
    @State private var selectedRecord: Record?
    @State private var showingRecordDetail = false
    
    let genres = ["전체", "Rock", "Jazz", "Classical", "Hip-Hop", "Electronic"]
    
    enum SortOption: String, CaseIterable {
        case popularity = "인기순"
        case priceAsc = "가격 낮은순"
        case priceDesc = "가격 높은순"
        case newest = "최신순"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 장르 필터
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(genres, id: \.self) { genre in
                            Button(action: { selectedGenre = genre }) {
                                Text(genre)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedGenre == genre ? Color.blue : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedGenre == genre ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 정렬 옵션
                HStack {
                    Spacer()
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: { sortOption = option }) {
                                Text(option.rawValue)
                            }
                        }
                    } label: {
                        HStack {
                            Text(sortOption.rawValue)
                            Image(systemName: "chevron.down")
                        }
                        .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                
                // 인기 레코드 리스트
                LazyVStack(spacing: 16) {
                    ForEach(0..<10) { index in
                        PopularRecordCard(
                            rank: index + 1,
                            rankChange: .up(2),
                            record: Record.sampleData[0],
                            onTap: {
                                selectedRecord = Record.sampleData[0]
                                showingRecordDetail = true
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("인기 레코드")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingRecordDetail) {
            if let record = selectedRecord {
                RecordSellersView(record: record)
            }
        }
    }
}

struct PopularRecordCard: View {
    let rank: Int
    let rankChange: RankChange
    let record: Record
    let onTap: () -> Void
    
    enum RankChange {
        case up(Int)
        case down(Int)
        case same
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .same: return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .same: return "minus"
            }
        }
        
        var text: String {
            switch self {
            case .up(let value): return "+\(value)"
            case .down(let value): return "-\(value)"
            case .same: return "-"
            }
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 순위
                VStack(spacing: 4) {
                    Text("\(rank)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 4) {
                        Image(systemName: rankChange.icon)
                        Text(rankChange.text)
                    }
                    .font(.caption)
                    .foregroundColor(rankChange.color)
                }
                .frame(width: 50)
                
                // 앨범 커버
                AsyncImage(url: record.coverImageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                
                // 정보
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
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                // 가격 변동
                VStack(alignment: .trailing, spacing: 4) {
                    if let priceChange = record.priceChange {
                        Text(priceChange > 0 ? "+\(priceChange)%" : "\(priceChange)%")
                            .font(.caption)
                            .foregroundColor(priceChange > 0 ? .red : .blue)
                    }
                    
                    Text("\(record.sellersCount)개 매물")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecordSellersView: View {
    let record: Record
    @State private var sortOption: SortOption = .priceAsc
    
    enum SortOption: String, CaseIterable {
        case priceAsc = "가격 낮은순"
        case priceDesc = "가격 높은순"
        case rating = "판매자 평점순"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 레코드 정보
                    HStack(spacing: 16) {
                        AsyncImage(url: record.coverImageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                        }
                        .frame(width: 100, height: 100)
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.title)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text(record.artist)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if let genre = record.genre {
                                Text(genre)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 5)
                    
                    // 정렬 옵션
                    HStack {
                        Text("\(record.sellersCount)개의 매물")
                            .font(.headline)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: { sortOption = option }) {
                                    Text(option.rawValue)
                                }
                            }
                        } label: {
                            HStack {
                                Text(sortOption.rawValue)
                                Image(systemName: "chevron.down")
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 판매자 리스트
                    LazyVStack(spacing: 16) {
                        ForEach(0..<5) { _ in
                            SellerCard()
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("판매자 목록")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SellerCard: View {
    var body: some View {
        VStack(spacing: 16) {
            // 판매자 정보
            HStack {
                AsyncImage(url: URL(string: "https://example.com/seller.jpg")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("판매자명")
                        .font(.headline)
                    
                    HStack {
                        ForEach(0..<5) { index in
                            Image(systemName: index < 4 ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                        Text("(123)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("50,000원")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("배송비 3,000원")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 상품 상태
            HStack(spacing: 16) {
                Label("VG+", systemImage: "record.circle")
                Label("국내반", systemImage: "flag")
                Label("즉시 배송", systemImage: "shippingbox")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            // 구매 버튼
            Button(action: {}) {
                Text("구매하기")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

#Preview {
    NavigationView {
        PopularRecordsView()
    }
} 