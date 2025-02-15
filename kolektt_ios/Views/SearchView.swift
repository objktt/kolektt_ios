import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedGenre = "전체"
    @State private var sortOption = SortOption.latest
    
    private let genres = ["전체", "House", "Techno", "Disco", "Jazz", "Hip-Hop"]
    
    enum SortOption: String, CaseIterable {
        case latest = "최신순"
        case popularity = "인기순"
        case priceLow = "낮은 가격순"
        case priceHigh = "높은 가격순"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 검색 바
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("레코드 검색", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                // 장르 필터
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(genres, id: \.self) { genre in
                            Button(action: { selectedGenre = genre }) {
                                Text(genre)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedGenre == genre ? Color(hex: "0036FF") : Color.gray.opacity(0.1))
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
                .padding()
                
                // 검색 결과
                if !searchText.isEmpty {
                    List {
                        ForEach(Record.sampleData.filter {
                            searchText.isEmpty ? true :
                                $0.title.localizedCaseInsensitiveContains(searchText) ||
                                $0.artist.localizedCaseInsensitiveContains(searchText)
                        }) { record in
                            NavigationLink(destination: RecordDetailView(record: record)) {
                                HStack(spacing: 12) {
                                    AsyncImageView(
                                        url: record.coverImageURL,
                                        size: CGSize(width: 50, height: 50),
                                        cornerRadius: 8
                                    )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(record.title)
                                            .font(.headline)
                                        Text(record.artist)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                } else {
                    // 최근 검색어 및 추천 검색어
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // 최근 검색어
                            VStack(alignment: .leading, spacing: 12) {
                                Text("최근 검색어")
                                    .font(.headline)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(["Bicep", "Burial", "Four Tet", "Jamie xx"], id: \.self) { term in
                                            Button(action: { searchText = term }) {
                                                HStack(spacing: 4) {
                                                    Text(term)
                                                    Image(systemName: "xmark")
                                                        .font(.caption)
                                                }
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(Color(.systemGray6))
                                                .cornerRadius(16)
                                            }
                                            .foregroundColor(.primary)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // 추천 검색어
                            VStack(alignment: .leading, spacing: 12) {
                                Text("추천 검색어")
                                    .font(.headline)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(["Aphex Twin", "Boards of Canada", "Autechre", "Squarepusher"], id: \.self) { term in
                                            Button(action: { searchText = term }) {
                                                Text(term)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                    .background(Color(.systemGray6))
                                                    .cornerRadius(16)
                                            }
                                            .foregroundColor(.primary)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("검색")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
} 