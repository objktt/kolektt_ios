import SwiftUI
import AVKit

struct ForYourMusicTasteView: View {
    @State private var selectedRecord: Record?
    @State private var showingRecordDetail = false
    @State private var isPlaying = false
    @State private var currentlyPlayingIndex: Int?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 헤더
                VStack(alignment: .leading, spacing: 8) {
                    Text("당신의 음악 취향")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("최근 감상한 음악과 구매한 레코드를 기반으로 추천해드려요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // 추천 레코드 리스트
                LazyVStack(spacing: 20) {
                    ForEach(0..<10) { index in
                        RecommendedRecordCard(
                            record: Record.sampleData[0],
                            isPlaying: isPlaying && currentlyPlayingIndex == index,
                            onPlayTap: {
                                if currentlyPlayingIndex == index {
                                    isPlaying.toggle()
                                } else {
                                    currentlyPlayingIndex = index
                                    isPlaying = true
                                }
                            },
                            onCardTap: {
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
        .navigationTitle("음악 취향")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingRecordDetail) {
            if let record = selectedRecord {
                RecordSellersView(record: record)
            }
        }
    }
}

struct RecommendedRecordCard: View {
    let record: Record
    let isPlaying: Bool
    let onPlayTap: () -> Void
    let onCardTap: () -> Void
    
    var body: some View {
        Button(action: onCardTap) {
            VStack(spacing: 16) {
                // 앨범 커버 및 재생 버튼
                ZStack {
                    AsyncImage(url: record.coverImageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(height: 200)
                    .cornerRadius(16)
                    
                    // 재생 버튼
                    Button(action: onPlayTap) {
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            )
                    }
                }
                
                // 레코드 정보
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.title)
                                .font(.headline)
                                .lineLimit(1)
                            
                            Text(record.artist)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
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
                    
                    // 추천 이유
                    Text("'\(record.artist)'의 다른 앨범을 좋아하시는 것 같아요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 판매자 정보
                    HStack {
                        Text("최저가")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(record.lowestPrice)원")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text("\(record.sellersCount)개 매물")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
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

struct MusicPlayer: View {
    let record: Record
    @Binding var isPlaying: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // 앨범 커버
            AsyncImage(url: record.coverImageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8)
            
            // 곡 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(record.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(record.artist)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 재생 컨트롤
            HStack(spacing: 24) {
                Button(action: {}) {
                    Image(systemName: "backward.fill")
                        .font(.title3)
                }
                
                Button(action: { isPlaying.toggle() }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                
                Button(action: {}) {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                }
            }
            .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationView {
        ForYourMusicTasteView()
    }
} 